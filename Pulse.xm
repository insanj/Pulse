#import "PLView.h"

#ifdef DEBUG
	#define PLLOG(fmt, ...) NSLog((@"[Pulse] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define PLLOG(fmt, ...) 
#endif

#define PULSE_INTERVAL 0.75 // Shared interval for wait and animation

@interface UISlider (Pulse)
- (void)pulse_beginPulsed;
- (void)pulse_checkPulsed;
- (void)pulse_triggerPulse;
- (void)pulse_endPulsed;
@end

%hook UISlider

static char * kPulseSliderValueKey;
static char * kPulseOverrideKey;

// Injects the Pulse value observer to new instances of UISlider
- (id)initWithFrame:(CGRect)frame {
	UISlider *slider = (UISlider *) %orig();

	PLLOG(@"Adding Pulse observers to UISlider instance: %@", slider);
	[slider addTarget:slider action:@selector(pulse_beginPulsed) forControlEvents:UIControlEventTouchDown];
	[slider addTarget:slider action:@selector(pulse_checkPulsed) forControlEvents:UIControlEventValueChanged];
	[slider addTarget:slider action:@selector(pulse_endPulsed) forControlEvents:UIControlEventTouchUpInside];

	return slider;
}

// Marks a UISlider as valid for Pulsing
%new - (void)pulse_beginPulsed {
	objc_setAssociatedObject(self, &kPulseOverrideKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Checks if a UISlider should be locked into place by Pulse (has already been Pulsed)
%new - (void)pulse_checkPulsed {
	if ([objc_getAssociatedObject(self, &kPulseOverrideKey) boolValue]) {
		self.value = [objc_getAssociatedObject(self, &kPulseSliderValueKey) floatValue];
	}
	
	else {
		CGFloat pulseSliderValue = self.value;
		objc_setAssociatedObject(self, &kPulseSliderValueKey, @(self.value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

		// Waits for the expanded interval to see if a Pulse should occur (user held on UISlider)
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PULSE_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			if (pulseSliderValue == [objc_getAssociatedObject(self, &kPulseSliderValueKey) floatValue]) {
				[self pulse_triggerPulse];
			}
		});
	}
}

// Pretty Pulse trigger and associated object assignment
%new - (void)pulse_triggerPulse {
	NSNumber *pulseOverrideValue = objc_getAssociatedObject(self, &kPulseOverrideKey);
	if (!pulseOverrideValue || [pulseOverrideValue boolValue]) {
		return;
	}

	PLLOG(@"Triggering Pulse from UISlider instance: %@", self);
	objc_setAssociatedObject(self, &kPulseOverrideKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:self.value];
	PLView *circle = [[PLView alloc] initWithFrame:thumbRect];
	circle.center = [self.superview convertPoint:CGPointMake(CGRectGetMidX(thumbRect), CGRectGetMidY(thumbRect)) fromView:self];
	circle.backgroundColor = [self respondsToSelector:@selector(tintColor)] ? [self tintColor] : [UIColor blueColor];
	[self.superview insertSubview:circle belowSubview:self];

	[circle animateWithDuration:PULSE_INTERVAL];
}

%new - (void)pulse_endPulsed {
	PLLOG(@"[Pulse] Guaranteeing Pulse-lock from UISlider instance: %@", self);
	objc_setAssociatedObject(self, &kPulseOverrideKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end