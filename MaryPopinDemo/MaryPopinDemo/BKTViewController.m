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

- (IBAction)presentPopinPressed:(id)sender;

@end

@implementation BKTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentPopinPressed:(id)sender {
    BKTPopinControllerViewController *popin = [[BKTPopinControllerViewController alloc] init];
    [popin setPopinTransitionStyle:BKTPopinTransitionStyleSnap];
    [self presentPopinController:popin animated:YES completion:NULL];
}

@end
