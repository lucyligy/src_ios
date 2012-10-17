//
//  UIImage+RetinaUtils.m
//  Raizlabs
//
//  Created by Nick Donaldson on 4/10/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "UIImage+RetinaUtils.h"

@implementation UIImage (RetinaUtils)

- (UIImage*)imageDrawnInRect:(CGRect)rect{
    
    CGRect scaledRect = rect;
    CGFloat imgScale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0;
    scaledRect.origin.x *= imgScale;
    scaledRect.origin.y *= imgScale;
    scaledRect.size.width *= imgScale;
    scaledRect.size.height *= imgScale;
    CGImageRef scaledImgRef = CGImageCreateWithImageInRect(self.CGImage, scaledRect);
    UIImage *scaledImg = [UIImage imageWithCGImage:scaledImgRef scale:imgScale orientation:self.imageOrientation];
    CGImageRelease(scaledImgRef);
    return scaledImg;
}

@end
