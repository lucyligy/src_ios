//
//  UIBezierPath+CirclePath.m
//  Raizlabs
//
//  Created by Nick Donaldson on 5/22/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "UIBezierPath+CirclePath.h"

@implementation UIBezierPath (CirclePath)

+ (UIBezierPath*)circlePathWithRadius:(CGFloat)radius{
    return [UIBezierPath circlePathWithRadius:radius center:CGPointMake(radius, radius)];
}

+ (UIBezierPath*)circlePathWithRadius:(CGFloat)radius center:(CGPoint)center{
    return [UIBezierPath bezierPathWithArcCenter:center
                                          radius:radius
                                      startAngle:0.0 
                                        endAngle:M_PI*2.0 
                                       clockwise:YES];
}

@end
