//
//  PLView.m
//  Pulse
//
//  Created by Julian Weiss on 1/21/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "PLView.h"

@implementation PLView
@synthesize scale;

- (PLView *)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		self.alpha = 0.75;
		self.backgroundColor = [UIColor blackColor];
		self.layer.cornerRadius = frame.size.height * 0.5;

		scale = frame.size.height / 7.5;
	}
	
	return self;
}


- (void)animateWithDuration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^(void) {
		self.transform = CGAffineTransformMakeScale(scale, scale);
		self.alpha = 0.0;
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
	}];
}

@end