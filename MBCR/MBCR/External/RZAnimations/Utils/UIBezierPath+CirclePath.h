//
//  UIBezierPath+CirclePath.h
//  Raizlabs
//
//  Created by Nick Donaldson on 5/22/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (CirclePath)

+ (UIBezierPath*)circlePathWithRadius:(CGFloat)radius;
+ (UIBezierPath*)circlePathWithRadius:(CGFloat)radius center:(CGPoint)center;

@end
