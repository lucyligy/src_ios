//
//  UIViewFactory.h
//
//  Created by jkaufman on 9/15/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (UIViewFactory)
+ (UIView *)view;
@end

@interface UIViewFactory : NSObject {
    UIView *_view;
}

@property (nonatomic, strong) IBOutlet UIView *view;

+ (UIView *)viewWithNibNamed:(NSString *)nibName;

@end
