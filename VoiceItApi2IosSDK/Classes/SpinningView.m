//
//  SpinningView.m
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/4/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import "SpinningView.h"
#import "Utilities.h"

@implementation SpinningView
CAShapeLayer * circleLayer;

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    circleLayer = [[CAShapeLayer alloc] init];
    circleLayer.lineWidth = 8;
    circleLayer.fillColor = nil;
    circleLayer.strokeColor = [Utilities cgColorFromHexString:@"#FBC132"];
    [[self layer] addSublayer:circleLayer];
}

-(void)startAnimation{

    CABasicAnimation * strokeEndAnimation = [CABasicAnimation animation];
    strokeEndAnimation.keyPath = @"strokeEnd";
    strokeEndAnimation.fromValue = [NSNumber numberWithFloat:0];
    strokeEndAnimation.toValue = [NSNumber numberWithFloat:1];
        strokeEndAnimation.duration = 2.0;
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    CAAnimationGroup * group1 = [CAAnimationGroup animation];
    group1.duration = 2.5;
    group1.repeatCount = MAXFLOAT;
    group1.animations = [[NSArray alloc] initWithObjects:strokeEndAnimation, nil];
    [circleLayer addAnimation: group1 forKey:@"strokeEnd"];
    
    CABasicAnimation * strokeStartAnimation = [CABasicAnimation animation];
    strokeStartAnimation.keyPath = @"strokeStart";
    strokeStartAnimation.beginTime = 0.5;
    strokeStartAnimation.fromValue = [NSNumber numberWithFloat:0];
    strokeStartAnimation.toValue = [NSNumber numberWithFloat:1];
    strokeStartAnimation.duration = 2.0;
    strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    CAAnimationGroup * group2 = [CAAnimationGroup animation];
    group2.duration = 2.5;
    group2.repeatCount = MAXFLOAT;
    group2.animations = [[NSArray alloc] initWithObjects:strokeStartAnimation, nil];
    [circleLayer addAnimation:group2 forKey:@"strokeStart"];
    
        CABasicAnimation * rotationAnimation = [CABasicAnimation animation];
        rotationAnimation.keyPath = @"transform.rotation.z";
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI_2];
        rotationAnimation.duration = 4.0;
        rotationAnimation.repeatCount = MAXFLOAT;
        [circleLayer addAnimation:rotationAnimation forKey:@"rotation"];
}

-(void)endAnimation{
    [circleLayer removeAnimationForKey:@"strokeStart"];
    [circleLayer removeAnimationForKey:@"strokeEnd"];
    [circleLayer removeAnimationForKey:@"rotation"];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat yPoint = [self frame].size.height * 0.75;
    CGPoint bottomPoint = CGPointMake([self center].x, yPoint );
    CGFloat radius = 80.0 / 2 - circleLayer.lineWidth /2;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle + (M_PI * 2);
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [circleLayer setPosition:bottomPoint];
    [circleLayer setPath:[path CGPath]];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
