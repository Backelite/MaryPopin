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

#import "UIViewController+MaryPopin.h"
#import <objc/runtime.h>

CG_INLINE CGRect	BkRectCenterInRect(CGRect myRect, CGRect refRect)
{
	myRect.origin.x = refRect.origin.x + roundf(refRect.size.width / 2.0  - myRect.size.width / 2.0);
	myRect.origin.y = refRect.origin.y + roundf(refRect.size.height / 2.0 - myRect.size.height / 2.0);
	return myRect;
}

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
        } else {
            [dimmingView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.1f]];
        }
        
        [self setDimmingView:dimmingView];
        
        CGRect popinFrame = [self computePopinFrame:popinController inRect:rect];
        
        if (YES == animated) {
            dimmingView.alpha = 0.0f;
            [self.view addSubview:dimmingView];
            
            [UIView animateWithDuration:-1
                             animations:^{
                dimmingView.alpha = 1.0f;
            }];
            
            [self addPopinToHierarchy:popinController];
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
            popinController.view.frame = popinFrame;
            [self addPopinToHierarchy:popinController];
            [popinController didMoveToParentViewController:self];
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
    [[NSNotificationCenter defaultCenter] removeObserver:presentedPopin];
    
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
            [UIView animateWithDuration:0.3
                                  delay:0 options:UIViewAnimationOptionCurveEaseIn
                             animations:[self outAnimationForPopinController:presentedPopin]
                             completion:^(BOOL finished) {
                                 [self removePopinFromHierarchy:presentedPopin];
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
    } else {
        [self removePopinFromHierarchy:presentedPopin];
        
        //Removing background
        [self.dimmingView removeFromSuperview];
        [self setDimmingView:nil];
        
        if (completion) {
            completion();
        }
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
            popinPreferedFrame.size.height = CGRectGetHeight(preferedContainerRect) - 40.0f; //Standard 20px margins
        }
        
        if (CGRectGetWidth(popinPreferedFrame) >= CGRectGetWidth(preferedContainerRect)) {
            popinPreferedFrame.size.width = CGRectGetWidth(preferedContainerRect) - 40.0f; //Standard 20px margins
        }
    }
    
    //Center popin in container
    popinPreferedFrame = BkRectCenterInRect(popinPreferedFrame, preferedContainerRect);
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
        CGFloat yOffset = (CGRectGetHeight(self.view.frame) - CGRectGetMinY(popinController.view.frame) + margin) * multiplier;
        frame = CGRectOffset(frame, 0.0f, yOffset);
    } else {
        CGFloat multiplier = (direction == BKTPopinTransitionDirectionRight) ? 1.0 : -1.0;
        CGFloat xOffset = (CGRectGetWidth(self.view.frame) - CGRectGetMinX(popinController.view.frame) + margin) * multiplier;
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
        [self setPresentingPopinViewController:nil];
    }
}

- (void)addPopinToHierarchy:(UIViewController *)popinController
{
    //Remove autoresizing mask
    [popinController.view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|
     UIViewAutoresizingFlexibleRightMargin|
     UIViewAutoresizingFlexibleTopMargin|
     UIViewAutoresizingFlexibleBottomMargin];
    
    //Add child with animation
    [self addChildViewController:popinController];
    
    //Add motion effect
    [UIViewController registerParalaxEffectForView:popinController.view WithDepth:10.0f];
    
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
        }
    };
    [self.animator addBehavior:snap];
    
    return NULL;
}

#pragma mark - Dynamic transition helper methods

- (BOOL)popinTransitionUsesDynamics
{
    return self.popinTransitionStyle >= BKTPopinTransitionStyleSnap && [self popinCanUseDynamics];
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

@end
