//
//  RZHudBoxView.h
//  Rue La La
//
//  Created by Nick Donaldson on 6/12/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RZHudBoxStyleInfo,
    RZHudBoxStyleLoading,
    RZHudBoxStyleProgress  // not implemented yet
} RZHudBoxStyle;

@interface RZHudBoxView : UIView

/// @name style
@property (nonatomic, assign) RZHudBoxStyle style;

/// @name Appearance Properties
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) UIColor *color;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) UIColor *borderColor;
@property (nonatomic, copy)   NSString *labelText;
@property (nonatomic, assign) UIColor *labelColor;
@property (nonatomic, assign) UIFont *labelFont;
@property (nonatomic, assign) UIColor *spinnerColor;

- (id)initWithStyle:(RZHudBoxStyle)style color:(UIColor*)color cornerRadius:(CGFloat)cornerRadius;

@end
