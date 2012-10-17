//
//  ControllablePageFlipper.m
//  Raizlabs
//
//  Created by Nick Donaldson on 3/29/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//


#import "ControllablePageFlipper.h"
#import "UIView+Utils.h"
#import "UIImage+RetinaUtils.h"
#import <QuartzCore/QuartzCore.h>

CFTimeInterval const kCPFPageTurnSmoothingTime = 0.01; // animation duration for control updates
CFTimeInterval const kCPFTotalFlipAnimationTime = 0.5;

CGFloat const kCPFDropShadowRadius = 18.0f;
CGFloat const kCPFDropShadowMaxOpacity = 0.5f;
CGFloat const kCPFPageZDistance = 1500.0f;
CGFloat const kCPFPageShadowMaxOpacity = 0.8;
CGFloat const kCPFFlipGradientMaxOpacity = 0.15;

float normalize(float input, float min, float max){
    float range = max - min;
    float retval = (input-min)/range;
    if (retval < 0.0) retval = 0.0;
    if (retval > 1.0) retval = 1.0;
    return retval;
};

@interface ControllablePageFlipper ()

@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) UIImage *targetImage;
@property (strong, nonatomic) CALayer *originalFoldLayer;
@property (strong, nonatomic) CALayer *targetUnderFoldLayer;
@property (strong, nonatomic) CALayer *targetFoldLayer;
@property (strong, nonatomic) CALayer *underFoldShadowLayer;
@property (strong, nonatomic) CAGradientLayer *leftFlipPageGradientLayer;
@property (strong, nonatomic) CAGradientLayer *rightFlipPageGradientLayer;
@property (strong, nonatomic) CALayer *flipLayer;

@property (assign, nonatomic) CPFFlipState targetState;
@property (assign, nonatomic) CGFloat percentOpen;

- (CGPathRef)newShadowPathFromRect:(CGRect)rect;

@end

@implementation ControllablePageFlipper

@synthesize shadowMask = _shadowMask;
@synthesize opensFromRight = _opensFromRight;
@synthesize delegate = _delegate;
@synthesize originalImage = _originalImage;
@synthesize targetImage = _targetImage;
@synthesize originalFoldLayer = _originalFoldLayer;
@synthesize targetUnderFoldLayer = _targetUnderFoldLayer;
@synthesize targetFoldLayer = _targetFoldLayer;
@synthesize underFoldShadowLayer = _underFoldShadowLayer;
@synthesize leftFlipPageGradientLayer = _leftFlipPageGradientLayer;
@synthesize rightFlipPageGradientLayer = _rightFlipPageGradientLayer;
@synthesize flipLayer = _flipLayer;
@synthesize targetView = _targetView;
@synthesize targetState = _targetState;
@synthesize percentOpen = _percentOpen;
@synthesize animationTime = _animationTime;

- (id)initWithOriginalImage:(UIImage *)originalImage targetImage:(UIImage *)targetImage frame:(CGRect)frame fromState:(CPFFlipState)state fromRight:(BOOL)fromRight
{
    self =[super initWithFrame:frame];
    
    self.opensFromRight = fromRight;
    self.animationTime = kCPFTotalFlipAnimationTime;
    
    if (self){
        
        CGFloat pixScale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [UIScreen mainScreen].scale : 1.0;
        
        self.percentOpen = state == kCPF_Closed ? 0.0 : 1.0;
        self.shadowMask = kCPF_NoShadow;
        
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        // init layer
        CGPathRef shadowPath = CGPathCreateWithRect(self.bounds, NULL);
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = state == kCPF_Closed ? 0.0 : kCPFDropShadowMaxOpacity;
        self.layer.shadowRadius = kCPFDropShadowRadius;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowPath = shadowPath;
        CGPathRelease(shadowPath);
        
        self.originalImage = originalImage;
        self.targetImage = targetImage;
        
        [CATransaction setDisableActions:YES];
        
        // create the pre and post image layers
        self.originalFoldLayer = [CALayer layer];
        self.originalFoldLayer.contentsGravity = self.opensFromRight ? kCAGravityTopRight : kCAGravityTopLeft;
        self.originalFoldLayer.backgroundColor = [UIColor whiteColor].CGColor;
        self.originalFoldLayer.masksToBounds = YES;
        self.originalFoldLayer.doubleSided = NO;
        self.originalFoldLayer.contentsScale = pixScale;
        
        self.targetUnderFoldLayer = [CALayer layer];
        self.targetUnderFoldLayer.contentsGravity = self.opensFromRight ? kCAGravityTopRight : kCAGravityTopLeft;
        self.targetUnderFoldLayer.backgroundColor = [UIColor whiteColor].CGColor;
        self.targetUnderFoldLayer.masksToBounds = YES;
        self.targetUnderFoldLayer.doubleSided = NO;
        self.targetUnderFoldLayer.contentsScale = pixScale;
        
        self.targetFoldLayer = [CALayer layer];
        self.targetFoldLayer.contentsGravity =self.opensFromRight ? kCAGravityTopLeft : kCAGravityTopRight;
        self.targetFoldLayer.backgroundColor = [UIColor whiteColor].CGColor;
        self.targetFoldLayer.masksToBounds = YES;
        self.targetFoldLayer.doubleSided = NO;
        self.targetFoldLayer.contentsScale = pixScale;
        self.targetFoldLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        
        // create shadow layers
        self.underFoldShadowLayer = [CALayer layer];
        self.underFoldShadowLayer.backgroundColor = [UIColor blackColor].CGColor;
        self.underFoldShadowLayer.opacity = 0.0;
        self.underFoldShadowLayer.doubleSided = NO;
        self.underFoldShadowLayer.contentsScale = pixScale;
        
        CGColorRef blackColor = [UIColor blackColor].CGColor;
        CGColorRef clearColor = [UIColor clearColor].CGColor;
        NSArray *pageGradientColors = [NSArray arrayWithObjects:(__bridge id)blackColor, (__bridge id)clearColor, nil];
        
        self.leftFlipPageGradientLayer = [[CAGradientLayer alloc] init];
        self.leftFlipPageGradientLayer.startPoint = CGPointMake(0.0, 0.5);
        self.leftFlipPageGradientLayer.endPoint = CGPointMake(1.0, 0.5);
        self.leftFlipPageGradientLayer.colors = pageGradientColors;
        self.leftFlipPageGradientLayer.opacity = 0.0;
        self.leftFlipPageGradientLayer.doubleSided = NO;
        self.leftFlipPageGradientLayer.contentsScale = pixScale;

        
        self.rightFlipPageGradientLayer = [[CAGradientLayer alloc] init];
        self.rightFlipPageGradientLayer.startPoint = CGPointMake(1.0, 0.5);
        self.rightFlipPageGradientLayer.endPoint = CGPointMake(0.0, 0.5);
        self.rightFlipPageGradientLayer.colors = pageGradientColors;
        self.rightFlipPageGradientLayer.opacity = 0.0;
        self.rightFlipPageGradientLayer.doubleSided = NO;
        self.rightFlipPageGradientLayer.contentsScale = pixScale;
        
        
        // create the transformable layer
        self.flipLayer = [CATransformLayer layer];
        self.flipLayer.anchorPoint = self.opensFromRight ? CGPointMake(0.0, 0.5) : CGPointMake(1.0, 0.5);
        self.flipLayer.doubleSided = YES;
        
        // set frames
        CGRect integralFrame = CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width/2.0, self.bounds.size.height));
        CGRect rightSideIntegralFrame = CGRectIntegral(CGRectMake(self.bounds.size.width/2.0, 0, self.bounds.size.width/2.0, self.bounds.size.height));
        rightSideIntegralFrame.origin.x = integralFrame.size.width;
        
        self.originalFoldLayer.frame = integralFrame;
        self.targetUnderFoldLayer.frame = self.opensFromRight ? rightSideIntegralFrame : integralFrame;
        self.targetFoldLayer.frame =  integralFrame;
        self.underFoldShadowLayer.frame = integralFrame;
        self.leftFlipPageGradientLayer.frame = integralFrame;
        self.rightFlipPageGradientLayer.frame = integralFrame;
        self.flipLayer.frame = self.opensFromRight ? rightSideIntegralFrame : integralFrame;
        
        // set contents
        self.originalFoldLayer.contents = (__bridge id)self.originalImage.CGImage;
        self.targetUnderFoldLayer.contents = (__bridge id)self.targetImage.CGImage;
        self.targetFoldLayer.contents = (__bridge id)self.targetImage.CGImage;
        
        if (self.opensFromRight){
            // add shadow layers as sublayers
            [self.targetUnderFoldLayer addSublayer:self.underFoldShadowLayer];
            [self.targetFoldLayer addSublayer:self.rightFlipPageGradientLayer];
            [self.originalFoldLayer addSublayer:self.leftFlipPageGradientLayer];
            
            // add layers to transformable layer
            [self.flipLayer addSublayer:self.originalFoldLayer];
            [self.flipLayer addSublayer:self.targetFoldLayer];
            
            [self.layer addSublayer:self.targetUnderFoldLayer];
            [self.layer addSublayer:self.flipLayer];
        }
        else{
            // add shadow layers as sublayers
            [self.targetUnderFoldLayer addSublayer:self.underFoldShadowLayer];
            [self.targetFoldLayer addSublayer:self.leftFlipPageGradientLayer];
            [self.originalFoldLayer addSublayer:self.rightFlipPageGradientLayer];
            
            // add layers to transformable layer
            [self.flipLayer addSublayer:self.originalFoldLayer];
            [self.flipLayer addSublayer:self.targetFoldLayer];
            
            [self.layer addSublayer:self.targetUnderFoldLayer];
            [self.layer addSublayer:self.flipLayer];
        }
        
        CATransform3D aTransform = CATransform3DIdentity;
        aTransform.m34 = -1.0 / kCPFPageZDistance;
        self.layer.sublayerTransform = aTransform;
        
        if (state == kCPF_Open){
            self.flipLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        }
        
        [CATransaction setDisableActions:NO];
        
        [self.layer setNeedsDisplay];
        
    }
    return self;
}

-(id)initWithOriginalView:(UIView *)originalView targetView:(UIView *)targetView fromState:(CPFFlipState)state fromRight:(BOOL)fromRight{
    
    self.targetView = targetView;
    
    // capture left and right images for the host view within the target frame and the target view
    self.targetView.layer.hidden = YES;
    UIImage* fullHostImage = [originalView imageByRenderingView];
    self.targetView.layer.hidden = NO;

    UIImage* partialHostImage = [fullHostImage imageDrawnInRect:targetView.frame];
    
    UIImage* targetImage = [targetView imageByRenderingView];
    
    return [self initWithOriginalImage:partialHostImage targetImage:targetImage frame:targetView.frame fromState:state fromRight:fromRight];
}

- (void)maskToCircleWithRadius:(CGFloat)radius{
    
    // content layers
    if (self.opensFromRight){
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.frame = self.originalFoldLayer.bounds;
        mask.path = [[UIBezierPath bezierPathWithArcCenter:CGPointMake(0, mask.frame.size.height/2) radius:radius startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES] CGPath];
        self.originalFoldLayer.mask = mask;
        
        mask = [CAShapeLayer layer];
        mask.frame = self.targetFoldLayer.bounds;
        mask.path = [[UIBezierPath bezierPathWithArcCenter:CGPointMake(mask.frame.size.width, mask.frame.size.height/2) radius:radius-1 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:NO] CGPath];
        self.targetFoldLayer.mask = mask;
        
        mask = [CAShapeLayer layer];
        mask.frame = self.targetUnderFoldLayer.bounds;
        mask.path = [[UIBezierPath bezierPathWithArcCenter:CGPointMake(0, mask.frame.size.height/2) radius:radius-1 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES] CGPath];
        self.targetUnderFoldLayer.mask = mask;
    }
    else{
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.frame = self.originalFoldLayer.bounds;
        mask.path =  [[UIBezierPath bezierPathWithArcCenter:CGPointMake(mask.frame.size.width, mask.frame.size.height/2) radius:radius startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:NO] CGPath];
        self.originalFoldLayer.mask = mask;
        
        mask = [CAShapeLayer layer];
        mask.frame = self.targetFoldLayer.bounds;
        mask.path = [[UIBezierPath bezierPathWithArcCenter:CGPointMake(0, mask.frame.size.height/2) radius:radius-1 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES] CGPath];
        self.targetFoldLayer.mask = mask;
        
        mask = [CAShapeLayer layer];
        mask.frame = self.targetUnderFoldLayer.bounds;
        mask.path = [[UIBezierPath bezierPathWithArcCenter:CGPointMake(0, mask.frame.size.height/2) radius:radius-1 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES] CGPath];
        self.targetUnderFoldLayer.mask = mask;
    }
}

- (void)setPercentOpen:(CGFloat)percentOpen{
    [self setPercentOpen:percentOpen withAnimationTime:kCPFPageTurnSmoothingTime];
}

- (void)setPercentOpen:(CGFloat)percentOpen withAnimationTime:(CFTimeInterval)time{
    
    _percentOpen = percentOpen;
    
    // caluclate angle via acos() so the edge follows our finger
    CGFloat scaledFlipX = (2.0 * percentOpen) - 1.0;
    CGFloat flipAngle = M_PI - acosf(scaledFlipX);//self.pctOpen*M_PI;
    flipAngle = flipAngle < 0.0 ? 0.0 : flipAngle;
    flipAngle = flipAngle > M_PI ? M_PI : flipAngle;
    flipAngle = self.opensFromRight ? -flipAngle : flipAngle;
    CATransform3D updatedFlipTransform = CATransform3DMakeRotation(flipAngle, 0, 1, 0);
    
    CGFloat dropShadowOpacity = normalize(percentOpen - 0.5, 0, 0.5)*kCPFDropShadowMaxOpacity;
    CGFloat leftSideShadowOpacity = (1.0 - normalize(percentOpen, 0, 0.5))*kCPFPageShadowMaxOpacity;
    CGFloat leftPageShadowOpacity;
    CGFloat rightPageShadowOpacity;
    if (self.opensFromRight){
        leftPageShadowOpacity = percentOpen > 0.5 ? 0 : normalize(percentOpen, 0, 0.5)*kCPFFlipGradientMaxOpacity;
        rightPageShadowOpacity = percentOpen < 0.5 ? 0 : (1.0 - normalize(percentOpen, 0.5, 1.0))*kCPFFlipGradientMaxOpacity;
    }
    else {
        leftPageShadowOpacity = percentOpen < 0.5 ? 0 : (1.0 - normalize(percentOpen, 0.5, 1.0))*kCPFFlipGradientMaxOpacity;
        rightPageShadowOpacity = percentOpen > 0.5 ? 0 : normalize(percentOpen, 0, 0.5)*kCPFFlipGradientMaxOpacity;
    }

    
    // calculate shadow path explicitly = much faster performance
    if (dropShadowOpacity > 0.0){
        
        CGFloat pageX = self.flipLayer.bounds.size.width * cosf(M_PI - flipAngle);
        CGFloat pageY = self.flipLayer.bounds.size.width * sinf(M_PI - flipAngle);
        CGFloat parallaxTheta = atan2f(pageX, kCPFPageZDistance - pageY);
        
        CGFloat shadowX = pageX + (pageY * tanf(parallaxTheta));
        
        CGRect shadowRect = self.bounds;
        shadowRect.size.width = (self.bounds.size.width/2.0f) + shadowX;
        if (self.opensFromRight){
            shadowRect.origin.x += (self.bounds.size.width/2.0f) - shadowX;
        }
        
        // constrain to bounds
        if (shadowRect.size.width > self.bounds.size.width)
            shadowRect.size.width = self.bounds.size.width;
        CGPathRef shadowPath = [self newShadowPathFromRect:shadowRect];
        self.layer.shadowPath = shadowPath;
        CGPathRelease(shadowPath);
    }
    
    // this gets updated a LOT so shortening the anim duration
    // greatly improves the responsiveness
    [CATransaction begin];
    [CATransaction setAnimationDuration:time];
    self.flipLayer.transform = updatedFlipTransform;
    self.underFoldShadowLayer.opacity = leftSideShadowOpacity;
    self.leftFlipPageGradientLayer.opacity = leftPageShadowOpacity;
    self.rightFlipPageGradientLayer.opacity = rightPageShadowOpacity;
    self.layer.shadowOpacity = dropShadowOpacity;
    [CATransaction commit];
    
}

- (void)animateToState:(CPFFlipState)state{
    
    self.targetState = state;
    
    // calculate duration based on current position and total animation time constant
    CFTimeInterval duration = state == kCPF_Closed ? self.percentOpen*self.animationTime : (1.0-self.percentOpen)*self.animationTime;
    
    if (fabsf(_percentOpen - 0.5) <= 0.01){
        [self setPercentOpen:state == kCPF_Closed ? 0.49 : 0.51];
    }
    
    // will we cross over the center of the fold?
    BOOL crossingCenter = (self.percentOpen < 0.5 && self.targetState == kCPF_Open) || (self.percentOpen >= 0.5 && self.targetState == kCPF_Closed);
    
    CGFloat fullAngle = self.opensFromRight ? -M_PI : M_PI;
    
    CATransform3D targetTransform = state == kCPF_Closed ? CATransform3DIdentity : CATransform3DMakeRotation(fullAngle, 0, 1, 0);
    CATransform3D halfwayTransform = CATransform3DMakeRotation(fullAngle/2.0, 0, 1, 0);

    
    // animate the shadows and such
    if (crossingCenter){
        
        // this is the case where we're animating fully open or closed
        
        CGFloat distFromCenter = fabsf(self.percentOpen-0.5);
        CGFloat totalDist = self.targetState == kCPF_Open ? 1.0 - self.percentOpen : self.percentOpen;
        CFTimeInterval timeToCenter = duration*(distFromCenter/totalDist);
        CFTimeInterval timeCenterToTarget = duration-timeToCenter;
        
        CABasicAnimation *flipAnimation1 = [CABasicAnimation animation];
        flipAnimation1.duration = timeToCenter;
        flipAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        flipAnimation1.fromValue = [NSValue valueWithCATransform3D:self.flipLayer.transform];
        flipAnimation1.toValue = [NSValue valueWithCATransform3D:halfwayTransform];
        flipAnimation1.keyPath = @"transform";
        flipAnimation1.removedOnCompletion = NO;
        flipAnimation1.fillMode = kCAFillModeForwards;
        
        [self.flipLayer addAnimation:flipAnimation1 forKey:@"firstHalfFlip"];
        
        CABasicAnimation *flipAnimation2 = [CABasicAnimation animation];
        flipAnimation2.duration = timeCenterToTarget;
        flipAnimation2.beginTime = CACurrentMediaTime() + timeToCenter;
        flipAnimation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        flipAnimation2.fromValue = [NSValue valueWithCATransform3D:halfwayTransform];
        flipAnimation2.toValue = [NSValue valueWithCATransform3D:targetTransform];
        flipAnimation2.keyPath = @"transform";
        flipAnimation2.removedOnCompletion = NO;
        flipAnimation2.fillMode = kCAFillModeForwards;
        flipAnimation2.delegate = self;
        
        [self.flipLayer addAnimation:flipAnimation2 forKey:@"secondHalfFlip"];
        
        if (self.targetState == kCPF_Closed){
            
            // first animate to half open state
            
            if (self.opensFromRight){
                CABasicAnimation *rightSidePageGrad = [CABasicAnimation animation];
                rightSidePageGrad.duration = timeToCenter;
                rightSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                rightSidePageGrad.fromValue = [NSNumber numberWithDouble:self.rightFlipPageGradientLayer.opacity];
                rightSidePageGrad.toValue = [NSNumber numberWithDouble:kCPFFlipGradientMaxOpacity];
                rightSidePageGrad.keyPath = @"opacity";
                rightSidePageGrad.fillMode = kCAFillModeForwards;
                rightSidePageGrad.removedOnCompletion = NO;
                
                self.rightFlipPageGradientLayer.opacity = kCPFFlipGradientMaxOpacity;
                [self.rightFlipPageGradientLayer addAnimation:rightSidePageGrad forKey:@"rightGradOpacity"];
            }
            else{
                CABasicAnimation *leftSidePageGrad = [CABasicAnimation animation];
                leftSidePageGrad.duration = timeToCenter;
                leftSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                leftSidePageGrad.fromValue = [NSNumber numberWithDouble:self.leftFlipPageGradientLayer.opacity];
                leftSidePageGrad.toValue = [NSNumber numberWithDouble:kCPFFlipGradientMaxOpacity];
                leftSidePageGrad.keyPath = @"opacity";
                leftSidePageGrad.fillMode = kCAFillModeForwards;
                leftSidePageGrad.removedOnCompletion = NO;
                
                self.leftFlipPageGradientLayer.opacity = kCPFFlipGradientMaxOpacity;
                [self.leftFlipPageGradientLayer addAnimation:leftSidePageGrad forKey:@"leftGradOpacity"];
            }
            
            
            CAMediaTimingFunction *shadowTiming = [CAMediaTimingFunction functionWithControlPoints:0.71 :0.0 :1.0 :0.29];
            CGRect shadowTargetRect = self.opensFromRight ? CGRectMake(self.bounds.size.width/2.0f, 0, self.bounds.size.width/2.0f, self.bounds.size.height) : CGRectMake(0, 0, self.bounds.size.width/2.0f, self.bounds.size.height);
            CGPathRef shadowTargetPath = [self newShadowPathFromRect:shadowTargetRect];
            
            
            CABasicAnimation *dropShadowPath = [CABasicAnimation animation];
            dropShadowPath.duration = timeToCenter;
            dropShadowPath.timingFunction = shadowTiming;
            dropShadowPath.fromValue = (__bridge id)self.layer.shadowPath;
            dropShadowPath.toValue = (__bridge id)shadowTargetPath;
            dropShadowPath.keyPath = @"shadowPath";
            dropShadowPath.removedOnCompletion = NO;
            
            CABasicAnimation *dropShadowAlpha = [CABasicAnimation animation];
            dropShadowAlpha.duration = timeToCenter;
            dropShadowAlpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            dropShadowAlpha.fromValue = [NSNumber numberWithDouble:self.layer.shadowOpacity];
            dropShadowAlpha.toValue = [NSNumber numberWithDouble:0.0];
            dropShadowAlpha.keyPath = @"shadowOpacity";
            dropShadowAlpha.fillMode = kCAFillModeForwards;
            dropShadowAlpha.removedOnCompletion = NO;
            
            self.layer.shadowPath = shadowTargetPath;
            self.layer.shadowOpacity = 0.0;
            
            [self.layer addAnimation:dropShadowPath forKey:@"shadowPath"];
            [self.layer addAnimation:dropShadowAlpha forKey:@"shadowOpacity"];
            CGPathRelease(shadowTargetPath);
            
            
            // then animate the rest of the way to closed
            
            CABasicAnimation *shadowOpacity = [CABasicAnimation animation];
            shadowOpacity.duration = timeCenterToTarget;
            shadowOpacity.beginTime = CACurrentMediaTime() + timeToCenter;
            shadowOpacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            shadowOpacity.fromValue = [NSNumber numberWithDouble:0.0];
            shadowOpacity.toValue = [NSNumber numberWithDouble:kCPFPageShadowMaxOpacity];
            shadowOpacity.keyPath = @"opacity";
            
            self.underFoldShadowLayer.opacity = 0.0;
            [self.underFoldShadowLayer addAnimation:shadowOpacity forKey:@"leftShadowOpacity"];
            
            if (self.opensFromRight){
                CABasicAnimation *leftSidePageGrad = [CABasicAnimation animation];
                leftSidePageGrad.beginTime = CACurrentMediaTime() + timeToCenter;
                leftSidePageGrad.duration = timeCenterToTarget;
                leftSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                leftSidePageGrad.fromValue = [NSNumber numberWithDouble:kCPFFlipGradientMaxOpacity];
                leftSidePageGrad.toValue = [NSNumber numberWithDouble:0.0];
                leftSidePageGrad.keyPath = @"opacity";
                leftSidePageGrad.fillMode = kCAFillModeForwards;
                leftSidePageGrad.removedOnCompletion = NO;
                
                self.leftFlipPageGradientLayer.opacity = 0.0;
                [self.leftFlipPageGradientLayer addAnimation:leftSidePageGrad forKey:@"leftGradOpacity"];
                
            }
            else{
                CABasicAnimation *rightSidePageGrad = [CABasicAnimation animation];
                rightSidePageGrad.duration = timeCenterToTarget;
                rightSidePageGrad.beginTime = CACurrentMediaTime() + timeToCenter;
                rightSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                rightSidePageGrad.fromValue = [NSNumber numberWithDouble:kCPFFlipGradientMaxOpacity];
                rightSidePageGrad.toValue = [NSNumber numberWithDouble:0.0];
                rightSidePageGrad.keyPath = @"opacity";
            
                self.rightFlipPageGradientLayer.opacity = 0.0;
                [self.rightFlipPageGradientLayer addAnimation:rightSidePageGrad forKey:@"rightGradOpacity"];
            }
            
            
            
        }
        else {
            
            // first animate to half open state
            
            CABasicAnimation *shadowOpacity = [CABasicAnimation animation];
            shadowOpacity.duration = timeToCenter;
            shadowOpacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            shadowOpacity.fromValue = [NSNumber numberWithDouble:self.underFoldShadowLayer.opacity];
            shadowOpacity.toValue = [NSNumber numberWithDouble:0.0];
            shadowOpacity.keyPath = @"opacity";
            shadowOpacity.fillMode = kCAFillModeForwards;
            shadowOpacity.removedOnCompletion = NO;
            
            self.underFoldShadowLayer.opacity = 0.0;
            [self.underFoldShadowLayer addAnimation:shadowOpacity forKey:@"leftShadowOpacity"];
            
            if (self.opensFromRight){
                CABasicAnimation *leftSidePageGrad = [CABasicAnimation animation];
                leftSidePageGrad.duration = timeToCenter;
                leftSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                leftSidePageGrad.fromValue = [NSNumber numberWithDouble:self.leftFlipPageGradientLayer.opacity];
                leftSidePageGrad.toValue = [NSNumber numberWithDouble:kCPFFlipGradientMaxOpacity];
                leftSidePageGrad.keyPath = @"opacity";
                leftSidePageGrad.fillMode = kCAFillModeForwards;
                leftSidePageGrad.removedOnCompletion = NO;
                
                self.leftFlipPageGradientLayer.opacity = kCPFFlipGradientMaxOpacity;
                [self.leftFlipPageGradientLayer addAnimation:leftSidePageGrad forKey:@"leftGradOpacity"];
            }
            else{
                CABasicAnimation *rightSidePageGrad = [CABasicAnimation animation];
                rightSidePageGrad.duration = timeToCenter;
                rightSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                rightSidePageGrad.fromValue = [NSNumber numberWithDouble:self.rightFlipPageGradientLayer.opacity];
                rightSidePageGrad.toValue = [NSNumber numberWithDouble:kCPFFlipGradientMaxOpacity];
                rightSidePageGrad.keyPath = @"opacity";
                rightSidePageGrad.fillMode = kCAFillModeForwards;
                rightSidePageGrad.removedOnCompletion = NO;
                
                self.rightFlipPageGradientLayer.opacity = kCPFFlipGradientMaxOpacity;
                [self.rightFlipPageGradientLayer addAnimation:rightSidePageGrad forKey:@"rightGradOpacity"];
            }
            
            // then animate all the way open
            
            CAMediaTimingFunction *shadowTiming = [CAMediaTimingFunction functionWithControlPoints:0.0 :0.71 :0.29 :1.0];
            CGRect shadowSourceRect = self.opensFromRight ? CGRectMake(self.bounds.size.width/2.0f, 0, self.bounds.size.width/2.0f, self.bounds.size.height) : CGRectMake(0, 0, self.bounds.size.width/2.0f, self.bounds.size.height);
            CGPathRef shadowSourcePath = [self newShadowPathFromRect:shadowSourceRect];
            
            
            if (self.opensFromRight){
                CABasicAnimation *rightSidePageGrad = [CABasicAnimation animation];
                rightSidePageGrad.duration = timeCenterToTarget;
                rightSidePageGrad.beginTime = CACurrentMediaTime() + timeToCenter;
                rightSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                rightSidePageGrad.fromValue = [NSNumber numberWithDouble:kCPFFlipGradientMaxOpacity];
                rightSidePageGrad.toValue = [NSNumber numberWithDouble:0.0];
                rightSidePageGrad.keyPath = @"opacity";
                
                self.rightFlipPageGradientLayer.opacity = 0.0;
                [self.rightFlipPageGradientLayer addAnimation:rightSidePageGrad forKey:@"rightGradOpacity"];
            }
            else {
                CABasicAnimation *leftSidePageGrad = [CABasicAnimation animation];
                leftSidePageGrad.beginTime = CACurrentMediaTime() + timeToCenter;
                leftSidePageGrad.duration = timeCenterToTarget;
                leftSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                leftSidePageGrad.fromValue = [NSNumber numberWithDouble:kCPFFlipGradientMaxOpacity];
                leftSidePageGrad.toValue = [NSNumber numberWithDouble:0.0];
                leftSidePageGrad.keyPath = @"opacity";
                leftSidePageGrad.fillMode = kCAFillModeForwards;
                leftSidePageGrad.removedOnCompletion = NO;
                
                self.leftFlipPageGradientLayer.opacity = 0.0;
                [self.leftFlipPageGradientLayer addAnimation:leftSidePageGrad forKey:@"leftGradOpacity"];
            }

            CGPathRef shadowPath = [self newShadowPathFromRect:self.bounds];
            CABasicAnimation *dropShadowPath = [CABasicAnimation animation];
            dropShadowPath.beginTime = CACurrentMediaTime() + timeToCenter;
            dropShadowPath.duration = timeCenterToTarget;
            dropShadowPath.timingFunction = shadowTiming;
            dropShadowPath.fromValue = (__bridge id)shadowSourcePath;
            dropShadowPath.toValue = (__bridge id)shadowPath;
            dropShadowPath.keyPath = @"shadowPath";
            dropShadowPath.fillMode = kCAFillModeForwards;
            dropShadowPath.removedOnCompletion = NO;
            CGPathRelease(shadowPath);
            
            CABasicAnimation *dropShadowAlpha = [CABasicAnimation animation];
            dropShadowAlpha.beginTime = CACurrentMediaTime() + timeToCenter;
            dropShadowAlpha.duration = timeCenterToTarget;
            dropShadowAlpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            dropShadowAlpha.fromValue = [NSNumber numberWithDouble:0.0];
            dropShadowAlpha.toValue = [NSNumber numberWithDouble:kCPFDropShadowMaxOpacity];
            dropShadowAlpha.keyPath = @"shadowOpacity";
            dropShadowAlpha.fillMode = kCAFillModeForwards;
            dropShadowAlpha.removedOnCompletion = NO;
            
            CGPathRef layerShadowPath = [self newShadowPathFromRect:self.bounds];
            self.layer.shadowPath = layerShadowPath;
            self.layer.shadowOpacity = 0.0;
            [self.layer addAnimation:dropShadowPath forKey:@"shadowPath"];
            [self.layer addAnimation:dropShadowAlpha forKey:@"shadowOpacity"];
            CGPathRelease(layerShadowPath);
            CGPathRelease(shadowSourcePath);
        }
    }
    else{
                
        CABasicAnimation *flipAnimation = [CABasicAnimation animation];
        flipAnimation.duration = duration;
        flipAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        flipAnimation.fromValue = [NSValue valueWithCATransform3D:self.flipLayer.transform];
        flipAnimation.toValue = [NSValue valueWithCATransform3D:targetTransform];
        flipAnimation.keyPath = @"transform";
        flipAnimation.fillMode = kCAFillModeForwards;
        flipAnimation.removedOnCompletion = NO;
        flipAnimation.delegate = self;
        
        self.flipLayer.transform = targetTransform;
        [self.flipLayer addAnimation:flipAnimation forKey:@"fullFlip"];
        
        if (self.targetState == kCPF_Closed){
            
            CABasicAnimation *shadowOpacity = [CABasicAnimation animation];
            shadowOpacity.duration = duration;
            shadowOpacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            shadowOpacity.fromValue = [NSNumber numberWithDouble:self.underFoldShadowLayer.opacity];
            shadowOpacity.toValue = [NSNumber numberWithDouble:kCPFPageShadowMaxOpacity];
            shadowOpacity.fillMode = kCAFillModeForwards;
            shadowOpacity.keyPath = @"opacity";
            
            self.underFoldShadowLayer.opacity = kCPFPageShadowMaxOpacity;
            [self.underFoldShadowLayer addAnimation:shadowOpacity forKey:@"leftShadowOpacity"];
            
            if (self.opensFromRight){
                CABasicAnimation *leftSidePageGrad = [CABasicAnimation animation];
                leftSidePageGrad.duration = duration;
                leftSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                leftSidePageGrad.toValue = [NSNumber numberWithDouble:0.0];
                leftSidePageGrad.keyPath = @"opacity";
                leftSidePageGrad.fillMode = kCAFillModeForwards;
                
                self.leftFlipPageGradientLayer.opacity = 0.0;
                [self.leftFlipPageGradientLayer addAnimation:leftSidePageGrad forKey:@"leftGradOpacity"];
            }
            else {
                CABasicAnimation *rightSidePageGrad = [CABasicAnimation animation];
                rightSidePageGrad.duration = duration;
                rightSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                rightSidePageGrad.fromValue = [NSNumber numberWithDouble:self.rightFlipPageGradientLayer.opacity];
                rightSidePageGrad.toValue = [NSNumber numberWithDouble:0.0];
                rightSidePageGrad.fillMode = kCAFillModeForwards;
                rightSidePageGrad.keyPath = @"opacity";
                
                self.rightFlipPageGradientLayer.opacity = 0.0;
                [self.rightFlipPageGradientLayer addAnimation:rightSidePageGrad forKey:@"rightGradOpacity"];
            }
            
        }
        else {
            
            if (self.opensFromRight){
                CABasicAnimation *rightSidePageGrad = [CABasicAnimation animation];
                rightSidePageGrad.duration = duration;
                rightSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                rightSidePageGrad.fromValue = [NSNumber numberWithDouble:self.rightFlipPageGradientLayer.opacity];
                rightSidePageGrad.toValue = [NSNumber numberWithDouble:0.0];
                rightSidePageGrad.fillMode = kCAFillModeForwards;
                rightSidePageGrad.keyPath = @"opacity";
                
                self.rightFlipPageGradientLayer.opacity = 0.0;
                [self.rightFlipPageGradientLayer addAnimation:rightSidePageGrad forKey:@"rightGradOpacity"];
            }
            else {
                CABasicAnimation *leftSidePageGrad = [CABasicAnimation animation];
                leftSidePageGrad.duration = duration;
                leftSidePageGrad.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                leftSidePageGrad.toValue = [NSNumber numberWithDouble:0.0];
                leftSidePageGrad.keyPath = @"opacity";
                leftSidePageGrad.fillMode = kCAFillModeForwards;
                
                self.leftFlipPageGradientLayer.opacity = 0.0;
                [self.leftFlipPageGradientLayer addAnimation:leftSidePageGrad forKey:@"leftGradOpacity"];
            }
            
            CGPathRef shadowPath = [self newShadowPathFromRect:self.bounds];
            CABasicAnimation *dropShadowPath = [CABasicAnimation animation];
            dropShadowPath.duration = duration;
            dropShadowPath.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            dropShadowPath.fromValue = (__bridge id)self.layer.shadowPath;
            dropShadowPath.toValue = (__bridge id)shadowPath;
            dropShadowPath.fillMode = kCAFillModeForwards;
            dropShadowPath.keyPath = @"shadowPath";
            CGPathRelease(shadowPath);
            
            CABasicAnimation *dropShadowAlpha = [CABasicAnimation animation];
            dropShadowAlpha.duration = duration;
            dropShadowAlpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            dropShadowAlpha.fromValue = [NSNumber numberWithDouble:self.layer.shadowOpacity];
            dropShadowAlpha.toValue = [NSNumber numberWithDouble:kCPFDropShadowMaxOpacity];
            dropShadowAlpha.fillMode = kCAFillModeForwards;
            dropShadowAlpha.keyPath = @"shadowOpacity";
            
            CGPathRef layerShadowPath = [self newShadowPathFromRect:self.bounds]; 
            self.layer.shadowPath = layerShadowPath;
            self.layer.shadowOpacity = kCPFDropShadowMaxOpacity;
            [self.layer addAnimation:dropShadowPath forKey:@"shadowPath"];
            [self.layer addAnimation:dropShadowAlpha forKey:@"shadowOpacity"];
            CGPathRelease(layerShadowPath);
        }
    }
}

- (void)setShadowMask:(NSInteger)shadowMask{
    _shadowMask = shadowMask;
    CGPathRef shadowPath = [self newShadowPathFromRect:self.bounds];
    self.layer.shadowPath =  shadowPath;
    CGPathRelease(shadowPath);
}

- (CGPathRef)newShadowPathFromRect:(CGRect)rect{
    
    if (self.shadowMask == kCPF_NoShadow){
        return CGPathCreateWithRect((CGRect){self.center, CGSizeZero}, NULL);
    }
    
    if (self.shadowMask == kCPF_FullShadow){
        return CGPathCreateWithRect(rect, NULL);
    }
    
    
    // bit mask
    if (!(self.shadowMask & kCPF_LeftShadow)){
        rect.origin.x += kCPFDropShadowRadius;
        rect.size.width -= kCPFDropShadowRadius;
    }
    if (!(self.shadowMask & kCPF_RightShadow)){
        rect.size.width -= kCPFDropShadowRadius;
    }
    if (!(self.shadowMask & kCPF_TopShadow)){
        rect.origin.y += kCPFDropShadowRadius;
        rect.size.height -= kCPFDropShadowRadius;
    }
    if (!(self.shadowMask & kCPF_BottomShadow)){
        rect.size.height -= kCPFDropShadowRadius;
    }
    
    return CGPathCreateWithRect(rect, NULL);
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{    
    [self removeFromSuperview];
    [self.layer removeAllAnimations];
    [self.flipLayer removeAllAnimations];
    [self.leftFlipPageGradientLayer removeAllAnimations];
    [self.rightFlipPageGradientLayer removeAllAnimations];
    [self.underFoldShadowLayer removeAllAnimations];
    
    self.percentOpen = self.targetState == kCPF_Closed ? 0.0 : 1.0;
    
    if ([self.delegate respondsToSelector:@selector(didFinishAnimatingToState:withTargetView:)]){
        [self.delegate didFinishAnimatingToState:self.targetState withTargetView:self.targetView];
    }
}

@end
