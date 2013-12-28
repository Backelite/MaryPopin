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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BKTPopinTransitionStyle) {
    BKTPopinTransitionStyleSlide,
    BKTPopinTransitionStyleCrossDissolve,
    BKTPopinTransitionStyleZoom,
    BKTPopinTransitionStyleSpringySlide,
    BKTPopinTransitionStyleSpringyZoom,
    //UIDynamics transition styles
    BKTPopinTransitionStyleSnap
};

typedef NS_ENUM(NSInteger, BKTPopinTransitionDirection) {
    BKTPopinTransitionDirectionBottom = 0,
    BKTPopinTransitionDirectionTop,
    BKTPopinTransitionDirectionLeft,
    BKTPopinTransitionDirectionRight
};

typedef NS_ENUM(NSInteger, BKTPopinOption) {
    BKTPopinDefault = 0,
    BKTPopinIgnoreKeyboardNotification = 1 << 0,
    BKTPopinDisableAutoDismiss = 1 << 1
};

/**
 * Category allowing modal-like presentation of view controllers but with more configuration options.
 * Configuration options include pop-in size, transition style, transition direction, response to keyboard notifications and auto dismiss.
 */

@interface UIViewController (CDN) <UIDynamicAnimatorDelegate>

- (void)presentPopinController:(UIViewController *)popinController animated:(BOOL)animated
                    completion:(void(^)(void))completion;

- (void)presentPopinController:(UIViewController *)popinController fromRect:(CGRect)rect animated:(BOOL)animated
                    completion:(void(^)(void))completion;

- (void)dismissCurrentPopinControllerAnimated:(BOOL)animated;
- (void)dismissCurrentPopinControllerAnimated:(BOOL)animated completion:(void(^)(void))completion;

- (UIViewController *)presentedPopinViewController;

- (UIViewController *)presentingPopinViewController;

- (CGSize)preferedPopinContentSize;
- (void)setPreferedPopinContentSize:(CGSize)preferredSize;

- (BKTPopinTransitionStyle)popinTransitionStyle;
- (void)setPopinTransitionStyle:(BKTPopinTransitionStyle)transitionStyle;

- (BKTPopinTransitionDirection)popinTransitionDirection;
- (void)setPopinTransitionDirection:(BKTPopinTransitionDirection)transitionDirection;

- (BKTPopinOption)popinOptions;
- (void)setPopinOptions:(BKTPopinOption)popinOptions;

@end
