//
//  RZHud.h
//  Raizlabs
//
//  Created by Nick Donaldson on 5/21/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControllablePageFlipper.h"

typedef void (^HUDDismissBlock)();

typedef enum {
    RZHudStyleCircle,
    RZHudStyleBoxInfo,
    RZHudStyleBoxLoading,
    RZHudStyleOverlay
} RZHudStyle;

@interface RZHud : UIView <CPFlipperDelegate>

/// @name Style properties
@property (strong, nonatomic) UIView  *customView;
@property (strong, nonatomic) UIColor *overlayColor;
@property (strong, nonatomic) UIColor *hudColor;
@property (strong, nonatomic) UIColor *spinnerColor;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (assign, nonatomic) CGFloat hudAlpha;
@property (assign, nonatomic) CGFloat shadowAlpha;

// these apply to circle hud style only
@property (assign, nonatomic) CGFloat circleRadius;

// these apply to box hud style only
@property (assign, nonatomic) CGFloat cornerRadius;
@property (strong, nonatomic) UIColor* labelColor;
@property (strong, nonatomic) UIFont* labelFont;
@property (strong, nonatomic) NSString* labelText;

- (id)initWithStyle:(RZHudStyle)style;
- (void)presentInView:(UIView*)view withFold:(BOOL)fold;
- (void)presentInView:(UIView *)view withFold:(BOOL)fold afterDelay:(NSTimeInterval)delay;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)dismissWithCompletionBlock:(HUDDismissBlock)block;
- (void)dismissWithCompletionBlock:(HUDDismissBlock)block animated:(BOOL)animated;

@end
