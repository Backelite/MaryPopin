//
// The MIT License (MIT)
//
// Copyright (c) 2013 Backelite
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

@import Accelerate;

#import "UIViewController+MaryPopin.h"
#import <objc/runtime.h>

//Standard margin value on iOS
#define kMaryPopinStandardMargin 20.0f

CG_INLINE CGRect    BkRectCenterInRect(CGRect myRect, CGRect refRect)
{
	myRect.origin.x = refRect.origin.x + roundf(refRect.size.width / 2.0  - myRect.size.width / 2.0);
	myRect.origin.y = refRect.origin.y + roundf(refRect.size.height / 2.0 - myRect.size.height / 2.0);
	return myRect;
}

CG_INLINE CGRect    BkRectAlignLeftInRect(CGRect myRect, CGRect refRect)
{
	myRect.origin.x = 0.0f;
	myRect.origin.y = refRect.origin.y + roundf(refRect.size.height / 2.0 - myRect.size.height / 2.0);
	return myRect;
}

CG_INLINE CGRect    BkRectAlignUpInRect(CGRect myRect, CGRect refRect)
{
	myRect.origin.x = refRect.origin.x + roundf(refRect.size.width / 2.0  - myRect.size.width / 2.0);
	myRect.origin.y = 0.0f;
	return myRect;
}

CG_INLINE CGRect    BkRectAlignDownInRect(CGRect myRect, CGRect refRect)
{
	myRect.origin.x = refRect.origin.x + roundf(refRect.size.width / 2.0  - myRect.size.width / 2.0);
	myRect.origin.y = refRect.origin.y + roundf(refRect.size.height - myRect.size.height);
	return myRect;
}

CG_INLINE CGRect    BkRectAlignRightInRect(CGRect myRect, CGRect refRect)
{
	myRect.origin.x = refRect.origin.x + roundf(refRect.size.width - myRect.size.width);
	myRect.origin.y = refRect.origin.y + roundf(refRect.size.height / 2.0 - myRect.size.height / 2.0);
	return myRect;
}

CG_INLINE CGRect    BkRectInRectWithAlignementOption(CGRect myRect, CGRect refRect,BKTPopinAlignementOption option)
{
    switch (option) {
        case BKTPopinAlignementOptionCentered:
            return BkRectCenterInRect(myRect,refRect);
            break;
            
        case BKTPopinAlignementOptionUp:
            return BkRectAlignUpInRect(myRect,refRect);
            break;
            
        case BKTPopinAlignementOptionLeft:
            return BkRectAlignLeftInRect(myRect,refRect);
            break;
            
        case BKTPopinAlignementOptionDown:
            return BkRectAlignDownInRect(myRect,refRect);
            break;
            
        case BKTPopinAlignementOptionRight:
            return BkRectAlignRightInRect(myRect,refRect);
            break;
            
        default:
            return BkRectCenterInRect(myRect,refRect);
            break;
    }
}


@implementation BKTBlurParameters
- (id)init
{
    self = [super init];
    if (self) {
        self.alpha = 1.0f;
        self.radius = 20.f;
        self.saturationDeltaFactor = 1.8f;
        self.tintColor = [UIColor clearColor];
    }
    return self;
}
@end

@interface UIImage (MaryPopinBlur)

- (UIImage *)marypopin_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end

@implementation UIViewController (MaryPopin)

#pragma mark - Popin presentation methods

- (void)presentPopinController:(UIViewController *)popinController animated:(BOOL)animated
                    completion:(void(^)(void))completion
{
    [self presentPopinController:popinController fromRect:self.view.bounds animated:animated completion:completion];
}

- (void)presentPopinController:(UIViewController *)popinController fromRect:(CGRect)rect animated:(BOOL)animated
                    completion:(void(^)(void))completion
{
    NSAssert(nil != popinController, @"Popin controller cannot be nil");
    
    if (self.presentedPopinViewController == nil) {
        
        //Background dimming view
        UIView *dimmingView = [[UIView alloc] initWithFrame:self.view.bounds];
        [dimmingView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        BKTPopinOption options = [popinController popinOptions];
        if (! (options & BKTPopinDisableAutoDismiss)) {
            UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCurrentPopinController)];
            [dimmingView addGestureRecognizer:tapGesture];
        }
        
        if (options & BKTPopinDimmingViewStyleNone) {
            [dimmingView setBackgroundColor:[UIColor clearColor]];
        } else if (options & BKTPopinBlurryDimmingView && [self.view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            UIImage *bgImage = [self createImageFromView:self.view];
            BKTBlurParameters *parameters = [popinController blurParameters];
            bgImage = [bgImage marypopin_applyBlurWithRadius:parameters.radius tintColor:parameters.tintColor saturationDeltaFactor:parameters.saturationDeltaFactor maskImage:nil];
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
            bgImageView.alpha = parameters.alpha;
            [dimmingView addSubview:bgImageView];
        } else {
            [dimmingView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
        }
        
        [self setDimmingView:dimmingView];
        
        if (YES == animated) {
            dimmingView.alpha = 0.0f;
            [self.view addSubview:dimmingView];
            
            [UIView animateWithDuration:-1
                             animations:^{
                dimmingView.alpha = 1.0f;
            }];
            
            [self forwardAppearanceBeginningIfNeeded:popinController appearing:YES animated:YES];
            [self addPopinToHierarchy:popinController];
            CGRect popinFrame = [self computePopinFrame:popinController inRect:rect];
            [popinController.view setFrame:popinFrame];
            
            if ([popinController popinTransitionUsesDynamics] ) {
                [self snapInAnimationForPopinController:popinController toPosition:popinFrame withDirection:popinController.popinTransitionDirection completion:completion];
            } else {
                if ([UIView respondsToSelector:@selector(animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:)]) {
                [UIView animateWithDuration:[UIViewController animationDurationForTransitionStyle:popinController.popinTransitionStyle]
                                      delay:0.0
                     usingSpringWithDamping:[UIViewController dampingValueForTransitionStyle:popinController.popinTransitionStyle]
                      initialSpringVelocity:1.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:[self inAnimationForPopinController:popinController toPosition:popinFrame]
                                 completion:^(BOOL finished) {
                                     [popinController didMoveToParentViewController:self];
                                     [self forwardAppearanceEndingIfNeeded:popinController];
                                     if (completion) {
                                         completion();
                                     }
                                 }];
                    
                }
                else {
                    [UIView animateWithDuration:[UIViewController animationDurationForTransitionStyle:popinController.popinTransitionStyle]
                                     animations:[self inAnimationForPopinController:popinController toPosition:popinFrame]
                                     completion:^(BOOL finished) {
                        [popinController didMoveToParentViewController:self];
                        [self forwardAppearanceEndingIfNeeded:popinController];
                        if (completion) {
                            completion();
                        }
                    }];
                }
            }
        } else {
            //Adding
            [self.view addSubview:dimmingView];
            
            //Adding controller
            [self forwardAppearanceBeginningIfNeeded:popinController appearing:YES animated:NO];
            [self addPopinToHierarchy:popinController];
            CGRect popinFrame = [self computePopinFrame:popinController inRect:rect];
            popinController.view.frame = popinFrame;
            [popinController didMoveToParentViewController:self];
            [self forwardAppearanceEndingIfNeeded:popinController];
            if (completion) {
                completion();
            }
        }
        
        //Keyboard notification
        if (! (options & BKTPopinIgnoreKeyboardNotification)) {
            [[NSNotificationCenter defaultCenter] addObserver:popinController selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        }
    }
}

- (void)dismissCurrentPopinController
{
    [self dismissCurrentPopinControllerAnimated:YES];
}

- (void)dismissCurrentPopinControllerAnimated:(BOOL)animated
{
    [self dismissCurrentPopinControllerAnimated:animated completion:nil];
}

- (void)dismissCurrentPopinControllerAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    UIViewController *presentedPopin = self.presentedPopinViewController;

    [[NSNotificationCenter defaultCenter] removeObserver:presentedPopin name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:presentedPopin name:UIKeyboardWillShowNotification object:nil];
    
    if (YES == animated) {
        //Remove child with animation
        [UIView animateWithDuration:0.3
                         animations:^{
            self.dimmingView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            //Removing background
            if (self.presentedPopinViewController == nil) {
                [self.dimmingView removeFromSuperview];
                [self setDimmingView:nil];
            }
        }];
        
        if ([presentedPopin popinTransitionUsesDynamics]) {
            [self snapOutAnimationForPopinController:presentedPopin withDirection:presentedPopin.popinTransitionDirection completion:completion];
        } else {
            [self forwardAppearanceBeginningIfNeeded:presentedPopin appearing:NO animated:YES];
            [UIView animateWithDuration:0.3
                                  delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:[self outAnimationForPopinController:presentedPopin]
                             completion:^(BOOL finished) {
                                 [self removePopinFromHierarchy:presentedPopin];
                                 if (completion) {
                                     completion();
                                 }
                                 [self forwardAppearanceEndingIfNeeded:presentedPopin];
                             }];
        }
    } else {
        [self forwardAppearanceBeginningIfNeeded:presentedPopin appearing:NO animated:NO];
        [self removePopinFromHierarchy:presentedPopin];
        //Removing background
        [self.dimmingView removeFromSuperview];
        [self setDimmingView:nil];
        
        if (completion) {
            completion();
        }
        [self forwardAppearanceEndingIfNeeded:presentedPopin];
    }
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)keyboardNotif
{
    NSDictionary *keyboardInfo = [keyboardNotif userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    [[keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //Move frame
        [self.view setFrame:CGRectOffset(self.view.frame, 0.0f, 70.0f - CGRectGetMinY(self.view.frame))];
    } completion:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillHide:(NSNotification *)keyboardNotif
{
    NSDictionary *keyboardInfo = [keyboardNotif userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    [[keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //Move frame
        [self.view setFrame:[self originalPopinFrame]];
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }];
}

#pragma mark - Popin frame computation

- (CGRect)computePopinFrame:(UIViewController *)popinViewController inRect:(CGRect)containerRect
{
    //First get popin prefered size
    CGRect popinPreferedFrame = CGRectZero;
    if (NO == CGSizeEqualToSize([popinViewController preferedPopinContentSize], CGSizeZero)) {
        popinPreferedFrame.size = [popinViewController preferedPopinContentSize];
    } else {
        popinPreferedFrame.size = popinViewController.view.bounds.size;
    }
    
    //Then get container rect
    CGRect preferedContainerRect = containerRect;
    if (CGRectEqualToRect(containerRect, CGRectZero)) {
        preferedContainerRect = self.view.bounds;
    }
    
    //Check that popin rect is included inside container rect
    if (NO == CGRectEqualToRect(preferedContainerRect, CGRectUnion(preferedContainerRect, popinPreferedFrame))) {
        //Resize popin frame to fit inside container rect
        if (CGRectGetHeight(popinPreferedFrame) >= CGRectGetHeight(preferedContainerRect)) {
            popinPreferedFrame.size.height = CGRectGetHeight(preferedContainerRect) - kMaryPopinStandardMargin * 2; //Standard margins
        }
        
        if (CGRectGetWidth(popinPreferedFrame) >= CGRectGetWidth(preferedContainerRect)) {
            popinPreferedFrame.size.width = CGRectGetWidth(preferedContainerRect) - kMaryPopinStandardMargin * 2; //Standard margins
        }
    }
    
    //Align popin in container rect
    popinPreferedFrame = BkRectInRectWithAlignementOption(popinPreferedFrame, preferedContainerRect,[popinViewController popinAlignment]);
    
    //Save popin frame in case of displacement with keyboard
    [popinViewController setOriginalPopinFrame:popinPreferedFrame];
    
    return popinPreferedFrame;
}

- (CGRect)animationFrameForPopinController:(UIViewController *)popinController margin:(CGFloat)margin
{
    BKTPopinTransitionDirection direction = popinController.popinTransitionDirection;
    CGRect frame = popinController.view.frame;
    if (direction == BKTPopinTransitionDirectionTop || direction == BKTPopinTransitionDirectionBottom) {
        CGFloat multiplier = (direction == BKTPopinTransitionDirectionBottom) ? 1.0 : -1.0;
        CGFloat popinPosition = 0.0f;
        
        if (direction == BKTPopinTransitionDirectionTop) {
            popinPosition = CGRectGetMaxY(frame);
        } else if (direction == BKTPopinTransitionDirectionBottom) {
            popinPosition = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame);
        }
        
        CGFloat yOffset = (popinPosition + margin) * multiplier;
        frame = CGRectOffset(frame, 0.0f, yOffset);
    } else {
        CGFloat multiplier = (direction == BKTPopinTransitionDirectionRight) ? 1.0 : -1.0;
        CGFloat popinPosition = 0.0f;
        
        if (direction == BKTPopinTransitionDirectionLeft) {
            popinPosition = CGRectGetMaxX(frame);
        } else if (direction == BKTPopinTransitionDirectionRight) {
            popinPosition = CGRectGetWidth(self.view.frame) - CGRectGetMinX(frame);
        }
        
        CGFloat xOffset = (popinPosition + margin) * multiplier;
        frame = CGRectOffset(frame, xOffset, 0.0f);
    }
    return frame;
}

#pragma mark - Popin hierarchy management

- (void)removePopinFromHierarchy:(UIViewController *)presentedPopin
{
    if (NO == [self.presentedPopinViewController popinTransitionUsesDynamics] || self.animator == nil) {
        [presentedPopin willMoveToParentViewController:nil];
        [presentedPopin.view removeFromSuperview];
        [presentedPopin removeFromParentViewController];
        [self setPresentedPopinViewController:nil];
        [presentedPopin setPresentingPopinViewController:nil];
    }
}

- (void)addPopinToHierarchy:(UIViewController *)popinController
{
    //Add child with animation
    [self addChildViewController:popinController];
    
    //Remove autoresizing mask
    [popinController.view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|
     UIViewAutoresizingFlexibleRightMargin|
     UIViewAutoresizingFlexibleTopMargin|
     UIViewAutoresizingFlexibleBottomMargin];
    
    //Add motion effect
    BKTPopinOption options = [popinController popinOptions];
    if (NO == (options & BKTPopinDisableParallaxEffect)) {
        [UIViewController registerParalaxEffectForView:popinController.view WithDepth:10.0f];
    }
    
    [self.view addSubview:popinController.view];
    //Create animator if needed
    if (YES == [popinController popinTransitionUsesDynamics]) {
        UIDynamicAnimator *dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        [self setAnimator:dynamicAnimator];
    }
    
    //Set popin hierarchy accessors
    [self setPresentedPopinViewController:popinController];
    [popinController setPresentingPopinViewController:self];
}

- (void)forwardAppearanceBeginningIfNeeded:(UIViewController *)popinController appearing:(BOOL)isAppearing animated:(BOOL)animated
{
    if ([self bk_shouldAutomaticallyForwardAppearanceMethods] == NO) {
        [popinController beginAppearanceTransition:isAppearing animated:animated];
    }
}

- (void)forwardAppearanceEndingIfNeeded:(UIViewController *)popinController
{
    if ([self bk_shouldAutomaticallyForwardAppearanceMethods] == NO) {
        [popinController endAppearanceTransition];
    }
}

- (BOOL)bk_shouldAutomaticallyForwardAppearanceMethods
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    return [self shouldAutomaticallyForwardAppearanceMethods];
#else
    return [self automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers];
#endif
}

+ (void)registerParalaxEffectForView:(UIView *)aView WithDepth:(CGFloat)depth;
{
    if ([aView respondsToSelector:@selector(motionEffects)]) {
        if ([[aView motionEffects] count] == 0) {
            UIInterpolatingMotionEffect *effectX;
            UIInterpolatingMotionEffect *effectY;
            effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                      type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                      type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            
            
            effectX.maximumRelativeValue = @(depth);
            effectX.minimumRelativeValue = @(-depth);
            effectY.maximumRelativeValue = @(depth);
            effectY.minimumRelativeValue = @(-depth);
            
            UIMotionEffectGroup *motionGroup = [[UIMotionEffectGroup alloc] init];
            [motionGroup setMotionEffects:@[effectX, effectY]];
            [aView addMotionEffect:motionGroup];
        }
    }
}

#pragma mark - Accessors

- (UIViewController *)presentedPopinViewController
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPresentedPopinViewController:(UIViewController *)presentedPopinController
{
    objc_setAssociatedObject(self, @selector(presentedPopinViewController), presentedPopinController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)presentingPopinViewController
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPresentingPopinViewController:(UIViewController *)presentingPopinController
{
    objc_setAssociatedObject(self, @selector(presentingPopinViewController), presentingPopinController, OBJC_ASSOCIATION_ASSIGN);
}

- (CGSize)preferedPopinContentSize
{
    return [objc_getAssociatedObject(self, _cmd) CGSizeValue];
}

- (void)setPreferedPopinContentSize:(CGSize)preferredSize
{
    objc_setAssociatedObject(self, @selector(preferedPopinContentSize), [NSValue valueWithCGSize:preferredSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)originalPopinFrame
{
    return [objc_getAssociatedObject(self, _cmd) CGRectValue];
}

- (void)setOriginalPopinFrame:(CGRect)originalPopinFrame
{
    objc_setAssociatedObject(self, @selector(originalPopinFrame), [NSValue valueWithCGRect:originalPopinFrame], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BKTPopinTransitionStyle)popinTransitionStyle
{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

- (void)setPopinTransitionStyle:(BKTPopinTransitionStyle)transitionStyle
{
    objc_setAssociatedObject(self, @selector(popinTransitionStyle), [NSNumber numberWithInt:transitionStyle], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BKTPopinTransitionDirection)popinTransitionDirection
{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

- (void)setPopinTransitionDirection:(BKTPopinTransitionDirection)transitionDirection
{
    objc_setAssociatedObject(self, @selector(popinTransitionDirection), [NSNumber numberWithInt:transitionDirection], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BKTPopinOption)popinOptions
{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

- (void)setPopinOptions:(BKTPopinOption)popinOptions
{
    objc_setAssociatedObject(self, @selector(popinOptions),  [NSNumber numberWithInt:popinOptions], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BKTBlurParameters *)blurParameters
{
    BKTBlurParameters *param = objc_getAssociatedObject(self, _cmd);
    if (nil == param) {
        return [[BKTBlurParameters alloc] init];
    }
    
    return param;
}

- (void)setBlurParameters:(BKTBlurParameters *)blurParameters
{
    objc_setAssociatedObject(self, @selector(blurParameters), blurParameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(UIViewController * popinController,CGRect initialFrame,CGRect finalFrame))popinCustomInAnimation
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPopinCustomInAnimation:(void (^)(UIViewController * popinController,CGRect initialFrame,CGRect finalFrame))popinCustomInAnimation
{
    objc_setAssociatedObject(self, @selector(popinCustomInAnimation),  popinCustomInAnimation, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (void (^)(UIViewController * popinController,CGRect initialFrame,CGRect finalFrame))popinCustomOutAnimation
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPopinCustomOutAnimation:(void (^)(UIViewController * popinController,CGRect initialFrame,CGRect finalFrame))popinCustomOutAnimation
{
    objc_setAssociatedObject(self, @selector(popinCustomOutAnimation),  popinCustomOutAnimation, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BKTPopinAlignementOption)popinAlignment
{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

- (void)setPopinAlignment:(BKTPopinAlignementOption)popinAlignment
{
    objc_setAssociatedObject(self, @selector(popinAlignment),  [NSNumber numberWithInt:popinAlignment], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)dimmingView
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDimmingView:(UIView *)dimmingView
{
    objc_setAssociatedObject(self, @selector(dimmingView), dimmingView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIDynamicAnimator *)animator
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAnimator:(UIDynamicAnimator *)animator
{
    objc_setAssociatedObject(self, @selector(animator), animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Animations

- (void (^)(void))inAnimationForPopinController:(UIViewController *)popinController toPosition:(CGRect)finalFrame
{
    BKTPopinTransitionStyle transitionStyle = popinController.popinTransitionStyle;
    BKTPopinTransitionDirection direction = popinController.popinTransitionDirection;
    switch (transitionStyle) {
        case BKTPopinTransitionStyleCrossDissolve:
            return [self alphaInAnimationForPopinController:popinController toPosition:finalFrame];
        case BKTPopinTransitionStyleSpringySlide:
        case BKTPopinTransitionStyleSlide:
            return [self slideInAnimationForPopinController:popinController toPosition:finalFrame withDirection:direction];
        case BKTPopinTransitionStyleSpringyZoom:
        case BKTPopinTransitionStyleZoom:
            return [self zoomInAnimationForPopinController:popinController toPosition:finalFrame];
        case BKTPopinTransitionStyleCustom:
            if ([popinController popinCustomInAnimation])
                return [self customInAnimationForPopinController:popinController toPosition:finalFrame withDirection:direction];
        default:
            return [self alphaInAnimationForPopinController:popinController toPosition:finalFrame];
    }
}

- (void (^)(void))outAnimationForPopinController:(UIViewController *)popinController
{
    BKTPopinTransitionStyle transitionStyle = popinController.popinTransitionStyle;
    BKTPopinTransitionDirection direction = popinController.popinTransitionDirection;
    switch (transitionStyle) {
        case BKTPopinTransitionStyleCrossDissolve:
            return [self alphaOutAnimationForPopinController:popinController];
        case BKTPopinTransitionStyleSpringySlide:
        case BKTPopinTransitionStyleSlide:
            return [self slideOutAnimationForPopinController:popinController withDirection:direction];
        case BKTPopinTransitionStyleSpringyZoom:
        case BKTPopinTransitionStyleZoom:
            return [self zoomOutAnimationForPopinController:popinController];
        case BKTPopinTransitionStyleCustom:
            if ([popinController popinCustomOutAnimation])
                return [self customOutAnimationForPopinController:popinController withDirection:direction];
        default:
            return [self alphaOutAnimationForPopinController:popinController];
    }
}

//Cross dissolve
- (void (^)(void))alphaInAnimationForPopinController:(UIViewController *)popinController toPosition:(CGRect)finalFrame
{
    //Animation setup
    popinController.view.frame = finalFrame;
    popinController.view.alpha = 0.0f;
    
    //Change properties values
    void (^animation)(void) = ^{
        popinController.view.alpha = 1.0f;
    };
    return animation;
}

- (void (^)(void))alphaOutAnimationForPopinController:(UIViewController *)popinController
{
    //Change properties values
    void (^animation)(void) = ^{
        popinController.view.alpha = 0.0f;
    };
    return animation;
}

//Zoom
- (void (^)(void))zoomInAnimationForPopinController:(UIViewController *)popinController toPosition:(CGRect)finalFrame
{
    //Animation setup
    popinController.view.frame = finalFrame;
    popinController.view.alpha = 0.0f;
    popinController.view.transform = CGAffineTransformMakeScale(5.0f, 5.0f);
    
    //Change properties values
    void (^animation)(void) = ^{
        popinController.view.alpha = 1.0f;
        popinController.view.transform = CGAffineTransformIdentity;
    };
    return animation;
}

- (void (^)(void))zoomOutAnimationForPopinController:(UIViewController *)popinController
{
    //Change properties values
    void (^animation)(void) = ^{
        popinController.view.alpha = 0.0f;
        popinController.view.transform = CGAffineTransformMakeScale(5.0f, 5.0f);
    };
    return animation;
}

//Slides
- (void (^)(void))slideInAnimationForPopinController:(UIViewController *)popinController toPosition:(CGRect)finalFrame withDirection:(BKTPopinTransitionDirection)direction
{
    //Animation setup
    popinController.view.frame = [self animationFrameForPopinController:popinController margin:0.0f];
    
    //Change properties values
    void (^animation)(void) = ^{
        popinController.view.frame = finalFrame;
    };
    return animation;
}

- (void (^)(void))slideOutAnimationForPopinController:(UIViewController *)popinController withDirection:(BKTPopinTransitionDirection)direction
{
    //Change properties values
    void (^animation)(void) = ^{
        popinController.view.frame = [self animationFrameForPopinController:popinController margin:0.0f];
    };
    return animation;
}

//Snap
- (void (^)(void))snapInAnimationForPopinController:(UIViewController *)popinController toPosition:(CGRect)finalFrame withDirection:(BKTPopinTransitionDirection)direction completion:(void(^)(void))completion
{
    //Animation setup
    popinController.view.frame = [self animationFrameForPopinController:popinController margin:30.0f];
    
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:popinController.view snapToPoint:CGPointMake(CGRectGetMidX(finalFrame), CGRectGetMidY(finalFrame))];
    [snap setDamping:0.6f];
    __weak UISnapBehavior *weakSnap = snap;
    snap.action = ^ {
        if (CGRectEqualToRect(popinController.view.frame, finalFrame)) {
            [self forwardAppearanceEndingIfNeeded:popinController];
            if (completion) {
                completion();
            }
            weakSnap.action = nil;
        }
    };
    [self.animator addBehavior:snap];
    
    //Change properties values
    return NULL;
}

- (void (^)(void))snapOutAnimationForPopinController:(UIViewController *)popinController withDirection:(BKTPopinTransitionDirection)direction completion:(void(^)(void))completion
{
    [self.animator removeAllBehaviors];
    
    //Animation setup
    CGRect finalFrame = [self animationFrameForPopinController:popinController margin:30.0f];
    
    //Animation setup
    [self.animator setDelegate:self];
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:popinController.view snapToPoint:CGPointMake(CGRectGetMidX(finalFrame), CGRectGetMidY(finalFrame))];
    [snap setDamping:0.8f];
    snap.action = ^ {
        CGRect popinFrame = popinController.view.frame;
        if (CGRectIntersectsRect(popinFrame, self.view.frame) == NO) {
            [self.animator removeAllBehaviors];
            [self setAnimator:nil];
            [self removePopinFromHierarchy:self.presentedPopinViewController];
            if (completion) {
                completion();
            }
            [self forwardAppearanceEndingIfNeeded:popinController];
        }
    };
    
    [self forwardAppearanceBeginningIfNeeded:popinController appearing:NO animated:YES];
    [self.animator addBehavior:snap];
    
    return NULL;
}


- (void (^)(void))customInAnimationForPopinController:(UIViewController *)popinController toPosition:(CGRect)finalFrame withDirection:(BKTPopinTransitionDirection)direction
{
    CGRect initialFrame = [self animationFrameForPopinController:popinController margin:0.0f];
    popinController.view.frame = initialFrame;
    
    void (^animation)(void) = ^{

        popinController.popinCustomInAnimation(popinController,initialFrame,finalFrame);
        
    };
    
    return animation;
}
- (void (^)(void))customOutAnimationForPopinController:(UIViewController *)popinController withDirection:(BKTPopinTransitionDirection)direction
{
    CGRect initialFrame = popinController.view.frame;
    CGRect finalFrame = [self animationFrameForPopinController:popinController margin:0.0f];
    
    //Change properties values
    void (^animation)(void) = ^{
        
        popinController.popinCustomOutAnimation(popinController,initialFrame,finalFrame);
        
    };
    return animation;
}

#pragma mark - Dynamic transition helper methods

- (BOOL)popinTransitionUsesDynamics
{
    return self.popinTransitionStyle == BKTPopinTransitionStyleSnap && [self popinCanUseDynamics];
}

- (BOOL)popinCanUseDynamics
{
    return (nil != NSClassFromString(@"UIDynamicBehavior"));
}

+ (CGFloat)dampingValueForTransitionStyle:(BKTPopinTransitionStyle)transitionStyle
{
    CGFloat damping;
    switch (transitionStyle) {
        case BKTPopinTransitionStyleSpringySlide:
            damping = 0.6f;
            break;
        case BKTPopinTransitionStyleSpringyZoom:
            damping = 0.75f;
            break;
        default:
            damping = 1.0f;
            break;
    }
    return damping;
}

+ (NSTimeInterval)animationDurationForTransitionStyle:(BKTPopinTransitionStyle)transitionStyle
{
    NSTimeInterval animationDuration;
    switch (transitionStyle) {
        case BKTPopinTransitionStyleSpringySlide:
            animationDuration = 0.8;
            break;
        case BKTPopinTransitionStyleSpringyZoom:
            animationDuration = 0.5;
            break;
        default:
            animationDuration = 0.5;
            break;
    }
    return animationDuration;
}

#pragma mark - Helpers

- (UIImage *)createImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

#pragma mark - UImage Category for Blur

@implementation UIImage (MaryPopinBlur)

- (UIImage *)marypopin_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
