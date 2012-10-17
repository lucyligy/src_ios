//
//  UIView+Utils.m
//  Raizlabs
//
//  Created by Craig Spitzkoff on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+Utils.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Utils)

- (UIImage *) imageByRenderingView
{
   return [self imageByRenderingViewWithRetina:YES];
}

- (UIImage *) imageByRenderingViewWithRetina:(BOOL)allowRetina {
	CGFloat oldAlpha = self.alpha;
	
	self.alpha = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && allowRetina)
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    else    
        UIGraphicsBeginImageContext(self.bounds.size);
    
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.alpha = oldAlpha;
	
	return resultingImage;
}


+ (CGRect)interpolateRectFrom:(CGRect)sourceRect to:(CGRect)destRect progress:(CGFloat)progress{
    
    CGFloat originX = ((destRect.origin.x - sourceRect.origin.x)*progress) + sourceRect.origin.x;
    CGFloat originY = ((destRect.origin.y - sourceRect.origin.y)*progress) + sourceRect.origin.y;
    CGFloat width = ((destRect.size.width - sourceRect.size.width)*progress) + sourceRect.size.width;
    CGFloat height = ((destRect.size.height - sourceRect.size.height)*progress) + sourceRect.size.height;
    
    return CGRectMake(originX, originY, width, height);
}

@end
