//
//  BKTViewController.m
//  MaryPopinDemo
//
//  Created by Gaspard Viot on 16/12/13.
//  Copyright (c) 2013 Backelite. All rights reserved.
//

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
    [self.navigationController presentPopinController:popin animated:YES completion:NULL];
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
