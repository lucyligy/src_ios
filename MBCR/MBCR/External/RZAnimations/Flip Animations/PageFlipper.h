//
//  PageFlipper.h
//  Raizlabs
//
//  Created by Craig Spitzkoff on 1/24/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Utils.h"
#import "ImageFlipper.h"

@protocol PageFlipperDelegate

-(void) didFinishPageFlipWithTargetView:(UIView *)targetView wasCloseFlip:(BOOL)closeFlip;
@end

@interface PageFlipper : NSObject <ImageFlipperDelegate>

-(id) initWithHostView:(UIView*)hostView targetView:(UIView*)targetView; 

-(void) flip;
-(void) flipWithDelay:(CFTimeInterval)delay;

-(void) flipBack;
-(void) flipBackWithDelay:(CFTimeInterval)delay;

-(void) closeFlipViewBackDirection:(BOOL)back;

@property (nonatomic, assign) CFTimeInterval flipDuration;
@property(weak, nonatomic) id<PageFlipperDelegate> delegate;
@property (nonatomic, strong) UIView* backgroundView;

@end
