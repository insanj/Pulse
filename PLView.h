//
//  PLView.h
//  Pulse
//
//  Created by Julian Weiss on 1/21/14.
//  Copyright (c) 2014 insanj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLView : UIView 

@property(nonatomic, readwrite) CGFloat scale;

- (PLView *)initWithFrame:(CGRect)frame;
- (void)animateWithDuration:(NSTimeInterval)duration;

@end
