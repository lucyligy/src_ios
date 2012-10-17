//
//  ImageFlipper.h
//  Raizlabs
//
//  Created by Craig Spitzkoff on 1/26/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kRightAnimKey;
extern NSString* const kLeftAnimKey;
extern CFTimeInterval const kFlipperDuration;
extern CFTimeInterval const kFlipperPageSpacing;
extern CGFloat const kFlipperMaxShadowOpacity;
extern CGFloat const kFlipperMaxGradientOpacity;

@class ImageFlipper;

@protocol ImageFlipperDelegate <NSObject>

-(void) imageFlipperComplete:(ImageFlipper*)flipper; 

@end

@interface ImageFlipper : UIView

@property (nonatomic, assign) CFTimeInterval duration;

-(id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage delegate:(id<ImageFlipperDelegate>)delegate frame:(CGRect)frame;

-(id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage delegate:(id<ImageFlipperDelegate>)delegate frame:(CGRect)frame pages:(NSInteger)nPages;

-(id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage delegate:(id<ImageFlipperDelegate>)delegate frame:(CGRect)frame pages:(NSInteger)nPages allowRetina:(BOOL)allowRetina;

-(void) flip;
-(void) flipWithDelay:(CFTimeInterval)delay;
-(void) flipWithDelay:(CFTimeInterval)delay duration:(CFTimeInterval)duration;

-(void) flipBack;
-(void) flipBackWithDelay:(CFTimeInterval)delay;
-(void) flipBackWithDelay:(CFTimeInterval)delay duration:(CFTimeInterval)duration;

-(UIImage*)originalImage;
-(UIImage*)targetImage;

@end
