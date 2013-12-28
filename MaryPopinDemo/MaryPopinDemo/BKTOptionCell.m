//
//  BKTOptionCell.m
//  MaryPopinDemo
//
//  Created by Gaspard on 28/12/2013.
//  Copyright (c) 2013 Backelite. All rights reserved.
//

#import "BKTOptionCell.h"

@implementation BKTOptionCell

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(self.dismissSwitch.frame, point);
}

@end
