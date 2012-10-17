//
//  ImageFlipper.m
//  Raizlabs
//
//  Created by Craig Spitzkoff on 1/26/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "ImageFlipper.h"
#import <QuartzCore/QuartzCore.h>

NSString* const kRightAnimKey = @"rightAnim";
NSString* const kLeftAnimKey  = @"leftAnim";
CFTimeInterval const kFlipperDuration = 0.5;
CFTimeInterval const kFlipperPageSpacing = kFlipperDuration/4.0;
CGFloat const kFlipperMaxShadowOpacity = 0.8;
CGFloat const kFlipperMaxGradientOpacity = 0.25;

@interface ImageFlipper()

@property (nonatomic, weak) id<ImageFlipperDelegate> delegate;

// Images
@property (nonatomic, strong) UIImage *originalImage; 
@property (nonatomic, strong) UIImage *targetImage;

// Image Section Layers
@property (nonatomic, strong) CALayer *originalLeftLayer;
@property (nonatomic, strong) CALayer *originalRightLayer;
@property (nonatomic, strong) CALayer *targetLeftLayer;
@property (nonatomic, strong) CALayer *targetRightLayer;

// Image Section Shadow Layers
@property (nonatomic, strong) CALayer *leftShadowLayer;
@property (nonatomic, strong) CALayer *rightShadowLayer;
@property (nonatomic, strong) NSMutableArray *leftPageGradientLayers;
@property (nonatomic, strong) NSMutableArray *rightPageGradientLayers;
@property (nonatomic, strong) NSMutableArray *leftPageBlankLayers;
@property (nonatomic, strong) NSMutableArray *rightPageBlankLayers;

// Transform layer for animating
@property (nonatomic, strong) NSMutableArray *flipTransformLayers;

// is the animation running in reverse (right to left)?
@property (nonatomic, assign) BOOL reverse;

// is the animation multiple pages?
@property (nonatomic, assign) NSInteger nPages;

@end

@implementation ImageFlipper
@synthesize delegate = _delegate;

// Images
@synthesize originalImage = _originalImage;
@synthesize targetImage = _targetImage;

// Image Section Layers
@synthesize originalLeftLayer = _originalLeftLayer;
@synthesize originalRightLayer = _originalRightLayer;
@synthesize targetLeftLayer = _targetLeftLayer;
@synthesize targetRightLayer = _targetRigthLayer;

// Image Section Shadow Layers
@synthesize leftShadowLayer = _leftShadowLayer;
@synthesize rightShadowLayer = _rightShadowLayer;
@synthesize leftPageGradientLayers = _leftPageGradientLayers;
@synthesize rightPageGradientLayers = _taretRightShadowLaters;
@synthesize leftPageBlankLayers = _leftPageBlankLayers;
@synthesize rightPageBlankLayers = _rightPageBlankLayers;

// Transform layer for animating
@synthesize flipTransformLayers = _flipTransformLayers;

@synthesize reverse = _reverse;
@synthesize nPages = _nPages;
@synthesize duration = _duration;

-(id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage delegate:(id<ImageFlipperDelegate>)delegate frame:(CGRect)frame
{
    return [self initWithOriginalImage:originalImage targetImage:targetImage delegate:delegate frame:frame pages:1 allowRetina:YES];
}

-(id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage delegate:(id<ImageFlipperDelegate>)delegate frame:(CGRect)frame pages:(NSInteger)nPages
{
    return [self initWithOriginalImage:originalImage targetImage:targetImage delegate:delegate frame:frame pages:nPages allowRetina:YES];
}

-(id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage delegate:(id<ImageFlipperDelegate>)delegate frame:(CGRect)frame pages:(NSInteger)nPages allowRetina:(BOOL)allowRetina
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.nPages = nPages;
        self.leftPageGradientLayers = [[NSMutableArray alloc] initWithCapacity:nPages];
        self.rightPageGradientLayers = [[NSMutableArray alloc] initWithCapacity:nPages];
        self.flipTransformLayers = [[NSMutableArray alloc] initWithCapacity:nPages];
        self.leftPageBlankLayers = [[NSMutableArray alloc] initWithCapacity:nPages];
        self.rightPageBlankLayers = [[NSMutableArray alloc] initWithCapacity:nPages];
        
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.delegate = delegate;
        self.targetImage = targetImage;
        self.originalImage = originalImage;
        
        self.duration = kFlipperDuration;
        
        [CATransaction setDisableActions:YES];
        
        CGFloat imgScale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && allowRetina ? [[UIScreen mainScreen] scale] : 1.0;
        
        // Setup Original Left Layer
        self.originalLeftLayer = [CALayer layer];
        self.originalLeftLayer.frame = CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height));
        self.originalLeftLayer.contents = (__bridge id)[originalImage CGImage];
        self.originalLeftLayer.contentsGravity = kCAGravityLeft;
        self.originalLeftLayer.masksToBounds = YES;
        self.originalLeftLayer.doubleSided = NO;
        self.originalLeftLayer.contentsScale = imgScale;
        
        
        // Setup Original Right Layer
        self.originalRightLayer = [CALayer layer];
        self.originalRightLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
        self.originalRightLayer.contentsGravity = kCAGravityRight;
        self.originalRightLayer.contents = (__bridge id)[originalImage CGImage];
        self.originalRightLayer.masksToBounds = YES;
        self.originalRightLayer.doubleSided = NO;
        self.originalRightLayer.contentsScale = imgScale;
        
        
        // Setup Target Left Layer
        self.targetLeftLayer = [CALayer layer];
        self.targetLeftLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
        self.targetLeftLayer.contentsGravity = kCAGravityLeft;
        self.targetLeftLayer.contents = (__bridge id)[targetImage CGImage];
        self.targetLeftLayer.masksToBounds = YES;
        self.targetLeftLayer.doubleSided = NO;
        self.targetLeftLayer.contentsScale = imgScale;
        // configure for Transform layer
        self.targetLeftLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        
        // Setup Target Right Layer
        self.targetRightLayer = [CALayer layer];
        self.targetRightLayer.frame = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
        self.targetRightLayer.contentsGravity = kCAGravityRight;
        self.targetRightLayer.contents = (__bridge id)[targetImage CGImage];
        self.targetRightLayer.masksToBounds = YES;
        self.targetRightLayer.doubleSided = NO;
        self.targetRightLayer.contentsScale = imgScale;
        
        
        CGColorRef blackColor = [UIColor blackColor].CGColor;
        CGColorRef clearColor = [UIColor clearColor].CGColor;
        NSArray *pageGradientColors = [NSArray arrayWithObjects:(__bridge id)blackColor, (__bridge id)clearColor, nil];
        
        // Setup Left Shadow Layer
        self.leftShadowLayer = [CALayer layer];
        self.leftShadowLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
        self.leftShadowLayer.backgroundColor = [[UIColor blackColor] CGColor];
        self.leftShadowLayer.opacity = 0.0;
        
        [self.originalLeftLayer addSublayer:self.leftShadowLayer];
        
        
        // Setup Right Shadow Layer
        self.rightShadowLayer = [CALayer layer];
        self.rightShadowLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
        self.rightShadowLayer.backgroundColor = [[UIColor blackColor] CGColor];
        self.rightShadowLayer.opacity = 0.0;
        
        [self.targetRightLayer addSublayer:self.rightShadowLayer];
        
        
        // Setup Transform Layers
        for (int n=0; n<self.nPages; n++){
            CATransformLayer *flipTransformLayer = [CATransformLayer layer];
            flipTransformLayer.anchorPoint = CGPointMake(0, 0.5);
            flipTransformLayer.frame = self.targetRightLayer.frame;
            [self.flipTransformLayers addObject:flipTransformLayer];
        }
        
        // add original layers to transform layers
        [[self.flipTransformLayers objectAtIndex:0] addSublayer:self.originalRightLayer];
        [[self.flipTransformLayers lastObject] addSublayer:self.targetLeftLayer];
        
        // Setup Left Page Gradient Layers and blank layers for transform layers
        for (int n=0; n<self.nPages; n++){
            CAGradientLayer *leftGradientLayer = [[CAGradientLayer alloc] init];
            leftGradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
            leftGradientLayer.startPoint = CGPointMake(0.0, 0.5);
            leftGradientLayer.endPoint = CGPointMake(1.0, 0.5);
            leftGradientLayer.colors = pageGradientColors;
            leftGradientLayer.opacity = 0.0;
            leftGradientLayer.doubleSided = NO;
            [self.leftPageGradientLayers addObject:leftGradientLayer];
            
            if (n > 0){
                CALayer *blankLayer = [CALayer layer];
                blankLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
                blankLayer.backgroundColor = [UIColor whiteColor].CGColor;
                blankLayer.doubleSided = NO;
                blankLayer.opacity = 1.0;
                blankLayer.contentsScale = imgScale;
                [self.leftPageBlankLayers addObject:blankLayer];
                [[self.flipTransformLayers objectAtIndex:n] addSublayer:blankLayer];
            }
            
            [[self.flipTransformLayers objectAtIndex:n] addSublayer:leftGradientLayer];
        }
        
        // Setup Right Page Gradient Layers
        for (int n=0; n<self.nPages; n++){
            CAGradientLayer *rightGradientLayer = [[CAGradientLayer alloc] init];
            rightGradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
            rightGradientLayer.startPoint = CGPointMake(1.0, 0.5);
            rightGradientLayer.endPoint = CGPointMake(0.0, 0.5);
            rightGradientLayer.colors = pageGradientColors;
            rightGradientLayer.opacity = 0.0;
            rightGradientLayer.doubleSided = NO;
            rightGradientLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
            [self.rightPageGradientLayers addObject:rightGradientLayer];
            
            if (n < self.nPages - 1){
                CALayer *blankLayer = [CALayer layer];
                blankLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
                blankLayer.backgroundColor = [UIColor whiteColor].CGColor;
                blankLayer.doubleSided = NO;
                blankLayer.opacity = 1.0;
                blankLayer.contentsScale = imgScale;
                blankLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
                [self.rightPageBlankLayers addObject:blankLayer];
                [[self.flipTransformLayers objectAtIndex:n] addSublayer:blankLayer];
            }
            
            [[self.flipTransformLayers objectAtIndex:n] addSublayer:rightGradientLayer];

        }
        
        [self.layer addSublayer:self.originalLeftLayer];
        [self.layer addSublayer:self.targetRightLayer];
        
        for (int n=0; n<self.nPages; n++)
            [self.layer addSublayer:[self.flipTransformLayers objectAtIndex:n]];
                
        CATransform3D aTransform = CATransform3DIdentity;
        float zDistance = 2500;
        aTransform.m34 = -1.0 / zDistance;
        self.layer.sublayerTransform = aTransform;
        
        [CATransaction setDisableActions:NO];
        
        [self.layer setNeedsDisplay];
    }
    
    return self;
}

- (void)setReverse:(BOOL)reverse
{
    
    if (_reverse  == reverse) return;
    
    _reverse = reverse;
    
    [CATransaction setDisableActions:YES];
    
    [self.originalLeftLayer removeFromSuperlayer];
    [self.originalRightLayer removeFromSuperlayer];
    [self.targetLeftLayer removeFromSuperlayer];
    [self.targetRightLayer removeFromSuperlayer];
    [self.leftShadowLayer removeFromSuperlayer];
    [self.rightShadowLayer removeFromSuperlayer];
    [self.flipTransformLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    // Configure layers for reverse
    if (reverse)
    {
        self.targetLeftLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
        self.targetLeftLayer.transform = CATransform3DIdentity;
        [self.targetLeftLayer addSublayer:self.leftShadowLayer];
        [self.layer addSublayer:self.targetLeftLayer];
        
        self.originalRightLayer.frame = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
        self.originalRightLayer.transform = CATransform3DIdentity;
        [self.originalRightLayer addSublayer:self.rightShadowLayer];
        [self.layer addSublayer:self.originalRightLayer];
        
        // first page
        self.originalLeftLayer.frame = [[self.flipTransformLayers objectAtIndex:0] bounds];
        self.originalLeftLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        [[self.flipTransformLayers objectAtIndex:0] insertSublayer:self.originalLeftLayer below:[self.rightPageGradientLayers objectAtIndex:0]];

        if (self.nPages > 1){
            CALayer *blankLayer = [self.leftPageBlankLayers lastObject];
            [self.leftPageBlankLayers removeLastObject];
            [blankLayer removeFromSuperlayer];
            [[self.flipTransformLayers objectAtIndex:0] insertSublayer:blankLayer below:[self.leftPageGradientLayers objectAtIndex:0]];
            [self.leftPageBlankLayers insertObject:blankLayer atIndex:0];
        }

        
        // last page
        self.targetRightLayer.frame = [[self.flipTransformLayers lastObject] bounds];
        self.targetRightLayer.transform = CATransform3DIdentity;
        [[self.flipTransformLayers lastObject] insertSublayer:self.targetRightLayer below:[self.leftPageGradientLayers lastObject]];
        
        if (self.nPages > 1){
            CALayer *blankLayer = [self.rightPageBlankLayers objectAtIndex:0];
            [blankLayer removeFromSuperlayer];
            [self.rightPageBlankLayers removeObjectAtIndex:0];
            [[self.flipTransformLayers lastObject] insertSublayer:blankLayer below:[self.rightPageGradientLayers lastObject]];
            [self.rightPageBlankLayers addObject:blankLayer];
        }
        
        // set all transforms and add, set opacities
        for (int n=0; n<self.nPages; n++){
            [(CATransformLayer*)[self.flipTransformLayers objectAtIndex:n] setTransform:CATransform3DMakeRotation(M_PI, 0, 1, 0)];
            [self.layer addSublayer:[self.flipTransformLayers objectAtIndex:n]];
            [[self.leftPageGradientLayers objectAtIndex:n] setOpacity:kFlipperMaxGradientOpacity];
            [[self.rightPageGradientLayers objectAtIndex:n] setOpacity:0];
        }
        
        
        self.leftShadowLayer.opacity = 0.0;
        self.rightShadowLayer.opacity = 0.0;
    }
    else
    {
        self.originalLeftLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
        self.originalLeftLayer.transform = CATransform3DIdentity;
        [self.originalLeftLayer addSublayer:self.leftShadowLayer];
        [self.layer addSublayer:self.originalLeftLayer];
        
        self.targetRightLayer.frame = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
        self.targetRightLayer.transform = CATransform3DIdentity;
        [self.targetRightLayer addSublayer:self.rightShadowLayer];
        [self.layer addSublayer:self.targetRightLayer];
        
        // first page
        self.originalRightLayer.frame = [[self.flipTransformLayers objectAtIndex:0] bounds];
        self.originalRightLayer.transform = CATransform3DIdentity;
        [[self.flipTransformLayers objectAtIndex:0] addSublayer:self.originalRightLayer];
        
        if (self.nPages > 1){
            CALayer *blankLayer = [self.rightPageBlankLayers lastObject];
            [self.rightPageBlankLayers removeLastObject];
            [blankLayer removeFromSuperlayer];
            [[self.flipTransformLayers objectAtIndex:0] insertSublayer:blankLayer atIndex:0];
            [self.rightPageBlankLayers insertObject:blankLayer atIndex:0];
        }

        // last page
        self.targetLeftLayer.frame = [[self.flipTransformLayers lastObject] bounds];
        self.targetLeftLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        [[self.flipTransformLayers lastObject] addSublayer:self.targetLeftLayer];
        
        if (self.nPages > 1){
            CALayer *blankLayer = [self.leftPageBlankLayers objectAtIndex:0];
            [blankLayer removeFromSuperlayer];
            [self.leftPageBlankLayers removeObjectAtIndex:0];
            [[self.flipTransformLayers lastObject] insertSublayer:blankLayer atIndex:0];
            [self.leftPageBlankLayers addObject:blankLayer];
        }
        
        // set all transforms and add, set opacities
        for (int n=0; n<self.nPages; n++){
            [(CATransformLayer*)[self.flipTransformLayers objectAtIndex:n] setTransform:CATransform3DIdentity];
            [self.layer addSublayer:[self.flipTransformLayers objectAtIndex:n]];
            [[self.leftPageGradientLayers objectAtIndex:n] setOpacity:0.0];
            [[self.rightPageGradientLayers objectAtIndex:n] setOpacity:kFlipperMaxGradientOpacity];
        }
    
        self.leftShadowLayer.opacity = 0.0;
        self.rightShadowLayer.opacity = 0.0;
    }
    
    [self.layer setNeedsDisplay];
    
    [CATransaction setDisableActions:NO];
}

-(void) flipWithDelay:(CFTimeInterval)delay{
    [self flipWithDelay:delay duration:kFlipperDuration];
}

-(void) flipWithDelay:(CFTimeInterval)delay duration:(CFTimeInterval)duration
{
    
    self.duration = duration;
    
    CFTimeInterval beginTime = CACurrentMediaTime() + delay;
    
    if(self.reverse)
    {
        CATransform3D fromTransform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        CATransform3D toTransform = CATransform3DIdentity;

//        CATransform3D fromTransform = CATransform3DIdentity;
       // CATransform3D middleTransform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
       // CATransform3D reverseMiddleTransform = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
//        CATransform3D toTransform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        

        
        for (int n=0; n<self.nPages; n++){
            CABasicAnimation *flipAnimation = [CABasicAnimation animation];
            flipAnimation.duration = self.duration;
            flipAnimation.beginTime = beginTime + n*kFlipperPageSpacing;
            flipAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            flipAnimation.fromValue = [NSValue valueWithCATransform3D:fromTransform];
            flipAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
            flipAnimation.keyPath = @"transform";
            flipAnimation.fillMode = kCAFillModeBoth;
            
            if (n == self.nPages-1)
                flipAnimation.delegate = self;
            
            [(CATransformLayer*)[self.flipTransformLayers objectAtIndex:n] setTransform:toTransform];
            [[self.flipTransformLayers objectAtIndex:n] addAnimation:flipAnimation forKey:@"transform"];
        }
        
        CABasicAnimation *rightShadowAnimation = [CABasicAnimation animation];
        rightShadowAnimation.duration = self.duration / 2.0;
        rightShadowAnimation.beginTime = beginTime + self.duration/2.0;
        rightShadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        rightShadowAnimation.fromValue = [NSNumber numberWithDouble:0.0];
        rightShadowAnimation.toValue = [NSNumber numberWithDouble:kFlipperMaxShadowOpacity];
        rightShadowAnimation.fillMode = kCAFillModeBoth;
        rightShadowAnimation.keyPath = @"opacity";
        
        self.rightShadowLayer.opacity = kFlipperMaxShadowOpacity;
        [self.rightShadowLayer addAnimation:rightShadowAnimation forKey:@"opacity"];
        
        CABasicAnimation *leftShadowAnimation = [CABasicAnimation animation];
        leftShadowAnimation.beginTime = beginTime + ((self.nPages-1)*kFlipperPageSpacing);
        leftShadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        leftShadowAnimation.duration = (self.duration / 2.0);
        leftShadowAnimation.fromValue = [NSNumber numberWithDouble:kFlipperMaxShadowOpacity];
        leftShadowAnimation.toValue = [NSNumber numberWithDouble:0.0];
        leftShadowAnimation.fillMode = kCAFillModeBoth;
        leftShadowAnimation.keyPath = @"opacity";
        
        self.leftShadowLayer.opacity = 0.0;
        [self.leftShadowLayer addAnimation:leftShadowAnimation forKey:@"opacity"];
    
        for (int n=0; n<self.nPages; n++){
            
            CABasicAnimation *rightPageGradientAnimation = [CABasicAnimation animation];
            rightPageGradientAnimation.duration = self.duration / 2.0;
            rightPageGradientAnimation.beginTime = beginTime + n*kFlipperPageSpacing;
            rightPageGradientAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            rightPageGradientAnimation.fromValue = [NSNumber numberWithDouble:0.0];
            rightPageGradientAnimation.toValue = [NSNumber numberWithDouble:kFlipperMaxGradientOpacity];
            rightPageGradientAnimation.fillMode = kCAFillModeBoth;
            rightPageGradientAnimation.keyPath = @"opacity";
            [[self.rightPageGradientLayers objectAtIndex:n] setOpacity:kFlipperMaxGradientOpacity];
            [[self.rightPageGradientLayers objectAtIndex:n] addAnimation:rightPageGradientAnimation forKey:@"opacity"];
        }
    
        
        for (int n=0; n<self.nPages; n++){
            CABasicAnimation *leftPageGradientAnimation = [CABasicAnimation animation];
            leftPageGradientAnimation.beginTime = beginTime + (self.duration/2.0) + (n*kFlipperPageSpacing);
            leftPageGradientAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            leftPageGradientAnimation.duration = self.duration / 2.0;
            leftPageGradientAnimation.fromValue = [NSNumber numberWithDouble:kFlipperMaxGradientOpacity];
            leftPageGradientAnimation.toValue = [NSNumber numberWithDouble:0.0];
            leftPageGradientAnimation.fillMode = kCAFillModeBoth;
            leftPageGradientAnimation.keyPath = @"opacity";
            [[self.leftPageGradientLayers objectAtIndex:n] setOpacity:0.0];
            [[self.leftPageGradientLayers objectAtIndex:n] addAnimation:leftPageGradientAnimation forKey:@"opacity"];
        }
        
        // original method
        /*
        CABasicAnimation *leftShadowAnimation = [CABasicAnimation animation];
        leftShadowAnimation.duration = self.duration / 2.0;
        leftShadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        leftShadowAnimation.fromValue = [NSNumber numberWithDouble:0.0];
        leftShadowAnimation.toValue = [NSNumber numberWithDouble:kFlipperMaxShadowOpacity];
        leftShadowAnimation.keyPath = @"opacity";
        
        self.leftShadowLayer.opacity = kFlipperMaxShadowOpacity;
        [self.leftShadowLayer addAnimation:leftShadowAnimation forKey:@"opacity"];
        
        CABasicAnimation *leftPageGradientAnimation = [CABasicAnimation animation];
        leftPageGradientAnimation.duration = self.duration / 2.0 - (self.duration * 0.2);
        leftPageGradientAnimation.beginTime = CACurrentMediaTime() + (self.duration * 0.2);
        leftPageGradientAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        leftPageGradientAnimation.fromValue = [NSValue valueWithCATransform3D:fromTransform];
        leftPageGradientAnimation.toValue = [NSValue valueWithCATransform3D:middleTransform];
        leftPageGradientAnimation.keyPath = @"transform";
        
        self.leftPageGradientLayer.transform = middleTransform;
        [self.leftPageGradientLayer addAnimation:leftPageGradientAnimation forKey:@"transform"];
        
        CABasicAnimation *rightShadowAnimation = [CABasicAnimation animation];
        rightShadowAnimation.beginTime = CACurrentMediaTime() + (self.duration / 2.0);
        rightShadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        rightShadowAnimation.duration = (self.duration / 2.0) - (self.duration * 0.2);
        rightShadowAnimation.fromValue = [NSValue valueWithCATransform3D:reverseMiddleTransform];
        rightShadowAnimation.toValue = [NSValue valueWithCATransform3D:fromTransform];
        rightShadowAnimation.keyPath = @"transform";
        rightShadowAnimation.fillMode = kCAFillModeBackwards;
        
        self.rightShadowLayer.transform = fromTransform;
        [self.rightShadowLayer addAnimation:rightShadowAnimation forKey:@"transform"];
        
        CABasicAnimation *rightPageGradientAnimation = [CABasicAnimation animation];
        rightPageGradientAnimation.beginTime = CACurrentMediaTime() + (self.duration / 2.0);
        rightPageGradientAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        rightPageGradientAnimation.duration = self.duration / 2.0;
        rightPageGradientAnimation.fromValue = [NSNumber numberWithDouble:kFlipperMaxShadowOpacity];
        rightPageGradientAnimation.toValue = [NSNumber numberWithDouble:0.0];
        rightPageGradientAnimation.keyPath = @"opacity";
        rightPageGradientAnimation.fillMode = kCAFillModeBackwards;
        
        self.rightPageGradientLayer.opacity = 0.0;
        [self.rightPageGradientLayer addAnimation:rightPageGradientAnimation forKey:@"opacity"];
         */
    }
    else
    {
        CATransform3D fromTransform = CATransform3DIdentity;
        CATransform3D toTransform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        
        for (int n=0; n<self.nPages; n++){
            CABasicAnimation *flipAnimation = [CABasicAnimation animation];
            flipAnimation.beginTime = beginTime + n*kFlipperPageSpacing;
            flipAnimation.duration = self.duration;
            flipAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            flipAnimation.fromValue = [NSValue valueWithCATransform3D:fromTransform];
            flipAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
            flipAnimation.fillMode = kCAFillModeBoth;
            flipAnimation.keyPath = @"transform";
            
            if (n == self.nPages-1)
                flipAnimation.delegate = self;
            
            [(CATransformLayer*)[self.flipTransformLayers objectAtIndex:n] setTransform:toTransform];
            [[self.flipTransformLayers objectAtIndex:n] addAnimation:flipAnimation forKey:@"transform"];
        }
        
        CABasicAnimation *rightShadowAnimation = [CABasicAnimation animation];
        rightShadowAnimation.duration = self.duration / 2.0;
        rightShadowAnimation.beginTime = beginTime + ((self.nPages-1)*kFlipperPageSpacing);
        rightShadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        rightShadowAnimation.fromValue = [NSNumber numberWithDouble:kFlipperMaxShadowOpacity];
        rightShadowAnimation.toValue = [NSNumber numberWithDouble:0.0];
        rightShadowAnimation.fillMode = kCAFillModeBoth;
        rightShadowAnimation.keyPath = @"opacity";
        
        self.rightShadowLayer.opacity = 0.0;
        [self.rightShadowLayer addAnimation:rightShadowAnimation forKey:@"opacity"];
        
        CABasicAnimation *leftShadowAnimation = [CABasicAnimation animation];
        leftShadowAnimation.beginTime = beginTime + self.duration/2.0;
        leftShadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        leftShadowAnimation.duration = (self.duration / 2.0);
        leftShadowAnimation.fromValue = [NSNumber numberWithDouble:0.0];
        leftShadowAnimation.toValue = [NSNumber numberWithDouble:kFlipperMaxShadowOpacity];
        leftShadowAnimation.fillMode = kCAFillModeBoth;
        leftShadowAnimation.keyPath = @"opacity";
        
        self.leftShadowLayer.opacity = kFlipperMaxShadowOpacity;
        [self.leftShadowLayer addAnimation:leftShadowAnimation forKey:@"opacity"];
        
        for (int n=0; n<self.nPages; n++){
            CABasicAnimation *rightPageGradientAnimation = [CABasicAnimation animation];
            rightPageGradientAnimation.duration = self.duration / 2.0;
            rightPageGradientAnimation.beginTime = beginTime + (self.duration/2.0) + (n*kFlipperPageSpacing);
            rightPageGradientAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            rightPageGradientAnimation.fromValue = [NSNumber numberWithDouble:kFlipperMaxGradientOpacity];
            rightPageGradientAnimation.toValue = [NSNumber numberWithDouble:0.0];
            rightPageGradientAnimation.fillMode = kCAFillModeBoth;
            rightPageGradientAnimation.keyPath = @"opacity";
            
            [[self.rightPageGradientLayers objectAtIndex:n] setOpacity:0.0];
            [[self.rightPageGradientLayers objectAtIndex:n] addAnimation:rightPageGradientAnimation forKey:@"opacity"];
        }
            
        for (int n=0; n<self.nPages; n++){
            CABasicAnimation *leftPageGradientAnimation = [CABasicAnimation animation];
            leftPageGradientAnimation.beginTime = beginTime + n*kFlipperPageSpacing;
            leftPageGradientAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            leftPageGradientAnimation.duration = self.duration / 2.0;
            leftPageGradientAnimation.fromValue = [NSNumber numberWithDouble:0.0];
            leftPageGradientAnimation.toValue = [NSNumber numberWithDouble:kFlipperMaxGradientOpacity];
            leftPageGradientAnimation.fillMode = kCAFillModeBoth;
            leftPageGradientAnimation.keyPath = @"opacity";
            
            [[self.leftPageGradientLayers objectAtIndex:n] setOpacity:kFlipperMaxGradientOpacity];
            [[self.leftPageGradientLayers objectAtIndex:n] addAnimation:leftPageGradientAnimation forKey:@"opacity"];
        }
            
        // original method
        /*
        CABasicAnimation *rightShadowAnimation = [CABasicAnimation animation];
        rightShadowAnimation.duration = self.duration / 2.0;
        rightShadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        rightShadowAnimation.fromValue = [NSNumber numberWithDouble:0.0];
        rightShadowAnimation.toValue = [NSNumber numberWithDouble:kFlipperMaxShadowOpacity];
        rightShadowAnimation.keyPath = @"opacity";
        
        self.rightShadowLayer.opacity = kFlipperMaxShadowOpacity;
        [self.rightShadowLayer addAnimation:rightShadowAnimation forKey:@"opacity"];
        
        CABasicAnimation *rightPageGradientAnimation = [CABasicAnimation animation];
        rightPageGradientAnimation.duration = self.duration / 2.0 - (self.duration * 0.2);
        rightPageGradientAnimation.beginTime = CACurrentMediaTime() + (self.duration * 0.2);
        rightPageGradientAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        rightPageGradientAnimation.fromValue = [NSValue valueWithCATransform3D:fromTransform];
        rightPageGradientAnimation.toValue = [NSValue valueWithCATransform3D:middleTransform];
        rightPageGradientAnimation.keyPath = @"transform";
        
        self.rightPageGradientLayer.transform = middleTransform;
        [self.rightPageGradientLayer addAnimation:rightPageGradientAnimation forKey:@"transform"];
        
        CABasicAnimation *leftShadowAnimation = [CABasicAnimation animation];
        leftShadowAnimation.beginTime = CACurrentMediaTime() + (self.duration / 2.0);
        leftShadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        leftShadowAnimation.duration = (self.duration / 2.0) - (self.duration * 0.2);
        leftShadowAnimation.fromValue = [NSValue valueWithCATransform3D:reverseMiddleTransform];
        leftShadowAnimation.toValue = [NSValue valueWithCATransform3D:fromTransform];
        leftShadowAnimation.keyPath = @"transform";
        leftShadowAnimation.fillMode = kCAFillModeBackwards;
        
        self.leftShadowLayer.transform = fromTransform;
        [self.leftShadowLayer addAnimation:leftShadowAnimation forKey:@"transform"];
        
        CABasicAnimation *leftPageGradientAnimation = [CABasicAnimation animation];
        leftPageGradientAnimation.beginTime = CACurrentMediaTime() + (self.duration / 2.0);
        leftPageGradientAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        leftPageGradientAnimation.duration = self.duration / 2.0;
        leftPageGradientAnimation.fromValue = [NSNumber numberWithDouble:kFlipperMaxShadowOpacity];
        leftPageGradientAnimation.toValue = [NSNumber numberWithDouble:0.0];
        leftPageGradientAnimation.keyPath = @"opacity";
        leftPageGradientAnimation.fillMode = kCAFillModeBackwards;
        
        self.leftPageGradientLayer.opacity = 0.0;
        [self.leftPageGradientLayer addAnimation:leftPageGradientAnimation forKey:@"opacity"];
         */
    }
    
    
    
}
-(void) flip
{
    [self flipWithDelay:0];
}

-(void) flipBack
{
    [self flipBackWithDelay:0];
}

-(void) flipBackWithDelay:(CFTimeInterval)delay
{
    self.reverse = YES;
    [self flipWithDelay:delay duration:kFlipperDuration];
}

-(void) flipBackWithDelay:(CFTimeInterval)delay duration:(CFTimeInterval)duration{
    self.reverse = YES;
    [self flipWithDelay:delay duration:duration];
}

#pragma mark - CAAnimation Delegate
-(void) animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [self.delegate imageFlipperComplete:self];
}


@end
