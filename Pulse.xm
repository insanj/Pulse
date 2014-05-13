#import "PLView.h"

#ifdef DEBUG
	#define PLLOG(fmt, ...) NSLog((@"[Pulse] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define PLLOG(fmt, ...) 
#endif

#define PULSE_INTERVAL 0.75 // Shared interval for wait and animation

@interface UISlider (Pulse)
- (void)checkPulse:(NSNumber *)value;
- (void)endPulse;
@end

%hook UISlider

// If the value stored is nil, no interactions have occured for this UISlider touch
// If the value stored isn't nil, then the UISlider should be locked to it
static char * kPulseSliderValueKey; 

// Injects the Pulse value observer to new instances of UISlider
- (id)initWithFrame:(CGRect)frame {
	UISlider *slider = (UISlider *) %orig();

	PLLOG(@"Adding Pulse observers to UISlider instance: %@", slider);
	[slider addTarget:slider action:@selector(checkPulse:) forControlEvents:UIControlEventValueChanged];
	[slider addTarget:slider action:@selector(endPulse) forControlEvents:UIControlEventTouchUpInside];

	return slider;
}

// Checks if a UISlider should be locked into place by Pulse (has already been Pulsed)
%new - (void)checkPulse:(NSNumber *)value {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	NSNumber *pulseSliderValue = objc_getAssociatedObject(self, &kPulseSliderValueKey);
	BOOL valueIsNumber = value && [value isKindOfClass:NSNumber.class];

	// If we've already checked before...
	if (pulseSliderValue) { 
		PLLOG(@"Looks like we've already checked %@ and it should be locked by Pulse!", self);
		self.value = [pulseSliderValue floatValue];
	}

	// If we've prompted a check, after the expanded interval...
	else if (valueIsNumber && !pulseSliderValue) {
		PLLOG(@"Checking if we should lock %@ into place and Pulse...", self);

		// Pretty Pulse trigger and associated object assignment
		if ([value floatValue] == self.value) {
			PLLOG(@"Triggering Pulse from UISlider instance: %@", self);
			objc_setAssociatedObject(self, &kPulseSliderValueKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
			CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:self.value];
			PLView *circle = [[PLView alloc] initWithFrame:thumbRect];
			circle.center = [self.superview convertPoint:CGPointMake(CGRectGetMidX(thumbRect), CGRectGetMidY(thumbRect)) fromView:self];
			circle.backgroundColor = [self respondsToSelector:@selector(tintColor)] ? [self tintColor] : [UIColor blueColor];
			[self.superview insertSubview:circle belowSubview:self];

			[circle animateWithDuration:PULSE_INTERVAL];
		}
	}
	
	// If we've done nothing whatsoever before...
	else {
		PLLOG(@"Queuing fresh Pulse check from %@", self);
		[self performSelector:@selector(checkPulse:) withObject:@(self.value) afterDelay:PULSE_INTERVAL];
	}
}

%new - (void)endPulse {
	PLLOG(@"Ended Pulse lock on slider %@", self);
	objc_setAssociatedObject(self, &kPulseSliderValueKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end