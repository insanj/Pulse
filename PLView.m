//
//  PLView.m
//  Pulse
//
//  Created by Julian Weiss on 1/21/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import "PLView.h"

@implementation PLView

-(PLView *)initWithFrame:(CGRect)frame{
	if((self = [super initWithFrame:frame])){
		self.alpha = 0.75;
		self.layer.cornerRadius = frame.size.height * 0.5;
		
		[self setColor:[UIColor blackColor]];
		[self setDrasticity:frame.size.height/7.5];
	}
	
	return self;
}

-(void)setColor:(UIColor *)color{
	_color = color;
	self.backgroundColor = color;
}

-(void)setDrasticity:(CGFloat)drasticity{
	_drasticity = drasticity;
}

-(void)animateWithDuration:(CGFloat)duration{
	[UIView animateWithDuration:duration animations:^(void){
		[self setTransform:CGAffineTransformMakeScale(_drasticity, _drasticity)];
		[self setAlpha:0.0];
	} completion:^(BOOL finished){
		[self removeFromSuperview];
	}];
}

@end