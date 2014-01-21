//
//  PLView.h
//  Pulse
//
//  Created by Julian Weiss on 1/21/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLView : UIView

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, readwrite) CGFloat thickness, drasticity;

-(PLView *)initWithFrame:(CGRect)frame;
-(void)setColor:(UIColor *)color;
-(void)setDrasticity:(CGFloat)drasticity;

-(void)animateWithDuration:(CGFloat)duration;
@end