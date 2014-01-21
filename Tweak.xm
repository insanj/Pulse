#include <UIKit/UIKit.h>
#import "PLView.h"

@interface UISlider (Pulse)
-(void)pulse_beginPulsed;
-(void)pulse_checkPulsed;
-(void)pulse_triggerPulse;
-(void)pulse_endPulsed;
@end

%hook UISlider
static char * kPulseSliderValueKey;
static char * kPulseOverrideKey;

-(UISlider *)initWithFrame:(CGRect)frame{
	UISlider *slider = %orig();

	NSLog(@"[Pulse] Adding Pulse observers to UISlider instance: %@", slider);
	[slider addTarget:slider action:@selector(pulse_beginPulsed) forControlEvents:UIControlEventTouchDown];
	[slider addTarget:slider action:@selector(pulse_checkPulsed) forControlEvents:UIControlEventValueChanged];
	[slider addTarget:slider action:@selector(pulse_endPulsed) forControlEvents:UIControlEventTouchUpInside];

	return slider;
}

%new -(void)pulse_beginPulsed{
	objc_setAssociatedObject(self, &kPulseOverrideKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new -(void)pulse_checkPulsed{
	if([objc_getAssociatedObject(self, &kPulseOverrideKey) boolValue])
		self.value = [objc_getAssociatedObject(self, &kPulseSliderValueKey) floatValue];
	
	else{
		CGFloat pulseSliderValue = self.value;
		objc_setAssociatedObject(self, &kPulseSliderValueKey, @(self.value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			if(pulseSliderValue == [objc_getAssociatedObject(self, &kPulseSliderValueKey) floatValue])
				[self pulse_triggerPulse];
		});
	}
}

%new -(void)pulse_triggerPulse{
	if(objc_getAssociatedObject(self, &kPulseOverrideKey) == nil || [objc_getAssociatedObject(self, &kPulseOverrideKey) boolValue])
		return;

	NSLog(@"[Pulse] Triggering Pulse from UISlider instance: %@", self);

	objc_setAssociatedObject(self, &kPulseOverrideKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:self.value];
	PLView *circle = [[PLView alloc] initWithFrame:thumbRect];
	circle.center = [self.superview convertPoint:CGPointMake(CGRectGetMidX(thumbRect), CGRectGetMidY(thumbRect)) fromView:self];
	[circle setColor:self.tintColor];
	[self.superview insertSubview:circle belowSubview:self];

	[circle animateWithDuration:0.75];
}

%new -(void)pulse_endPulsed{
	NSLog(@"[Pulse] Guaranteeing Pulse-lock from UISlider instance: %@", self);
	objc_setAssociatedObject(self, &kPulseOverrideKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%end