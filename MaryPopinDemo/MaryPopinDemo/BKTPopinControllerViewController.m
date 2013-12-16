//
//  BKTPopinControllerViewController.m
//  MaryPopinDemo
//
//  Created by Gaspard Viot on 16/12/13.
//  Copyright (c) 2013 Backelite. All rights reserved.
//

#import "BKTPopinControllerViewController.h"

#import "UIViewController+MaryPopin.h"

@interface BKTPopinControllerViewController ()

- (IBAction)closeButtonPressed:(id)sender;

@end

@implementation BKTPopinControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(id)sender {
    [self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES];
}

@end
