//
//  UIViewFactory.m
//
//  Created by jkaufman on 9/15/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "UIViewFactory.h"


@implementation UIViewFactory

@synthesize view = _view;

+ (UIView *)viewWithNibNamed:(NSString *)nibName
{
    UIViewFactory *viewFactory = [[UIViewFactory alloc] init];
    [[NSBundle mainBundle] loadNibNamed:nibName owner:viewFactory options:nil];
    return viewFactory.view;
}

@end

@implementation UIView (UIViewFactory)

+ (UIView *)view
{
    // Guess nib name.
    Class cellClass = [self class];
    NSString *classString = NSStringFromClass(cellClass);
    return [UIViewFactory viewWithNibNamed:classString];
}

@end