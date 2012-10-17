//
//  UIView+Utils.h
//  Raizlabs
//
//  Created by Craig Spitzkoff on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Utils)

- (UIImage *) imageByRenderingView;
- (UIImage *) imageByRenderingViewWithRetina:(BOOL)allowRetina;
+ (CGRect)interpolateRectFrom:(CGRect)sourceRect to:(CGRect)destRect progress:(CGFloat)progress;

@end
