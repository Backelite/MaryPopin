//
//  BKTiPadViewController.m
//  MaryPopinDemo
//
//  Created by Jerome Morissard on 1/18/14.
//  Copyright (c) 2014 Backelite. All rights reserved.
//

#import "BKTiPadViewController.h"
#import "BKTPopin2ControllerViewController.h"
#import "UIViewController+MaryPopin.h"

@interface BKTiPadViewController ()
@end

@implementation BKTiPadViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (IBAction)presentPopinPressed:(id)sender
{
    BKTPopin2ControllerViewController *popin = [[BKTPopin2ControllerViewController alloc] init];
    [popin setPopinOptions:BKTPopinDefault];
    [popin setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    [self presentPopinController:popin animated:YES completion:^{
        NSLog(@"Popin presented !");
    }];
}


@end
