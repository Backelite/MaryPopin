//
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

#import "BKTViewController.h"
#import "BKTPopinControllerViewController.h"
#import "UIViewController+MaryPopin.h"

@interface BKTViewController ()

@property (nonatomic, getter = isDismissable) BOOL dismissable;

- (IBAction)presentPopinPressed:(id)sender;

@end

@implementation BKTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)presentPopinPressed:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    BKTPopinControllerViewController *popin = [[BKTPopinControllerViewController alloc] init];
    [popin setPopinTransitionStyle:[self transitionStyleForIndexPath:selectedIndexPath]];
    if ([self isDismissable]) {
        [popin setPopinOptions:BKTPopinDefault];
    } else {
        [popin setPopinOptions:BKTPopinDisableAutoDismiss];
    }
    
    if (popin.popinTransitionStyle == BKTPopinTransitionStyleCustom)
    {
        [popin setPopinCustomInAnimation:^(UIViewController *popInController, CGRect initialFrame, CGRect finalFrame) {
          
            /*
            CGFloat y = self.view.center.y;
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
            animation.values = @[@(y), @(y + 20), @(y - 10), @(y)];
            animation.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.4;
            [popInController.view.layer addAnimation:animation forKey:@"dropdown"];
            */
            
            popInController.view.frame = finalFrame;
            
        }];
    }
    
    [popin setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    [self.navigationController presentPopinController:popin animated:YES completion:^{
        NSLog(@"Popin presented !");
    }];
}

- (IBAction)isDismissableValueChanged:(id)sender
{
    [self setDismissable:((UISwitch *)sender).isOn];
}

- (BKTPopinTransitionStyle)transitionStyleForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return indexPath.row;
    }
    return 0;
}

@end
