//
//  CSAlwaysOnTopHeader.m
//  CSStickyHeaderFlowLayoutDemo
//
//  Created by James Tang on 6/4/14.
//  Copyright (c) 2014 Jamz Tang. All rights reserved.
//

#import "CSAlwaysOnTopHeader.h"
#import "CSStickyHeaderFlowLayoutAttributes.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"

@implementation CSAlwaysOnTopHeader

- (void)applyLayoutAttributes:(CSStickyHeaderFlowLayoutAttributes *)layoutAttributes {

    [UIView beginAnimations:@"" context:nil];

    if (layoutAttributes.progressiveness >= 0.58) {
        self.hoursLabel.alpha = 1;
    } else {
        self.hoursLabel.alpha = 0;
    }
//
//    if (layoutAttributes.progressiveness >= 1) {
//        self.searchBar.alpha = 1;
//    } else {
//        self.searchBar.alpha = 0;
//    }

    [UIView commitAnimations];
}
- (IBAction)interestedButtonPressed:(id)sender {
    
    NSDictionary *dict = @{@"deal_objectId":self.dealID, @"user_objectId":[[PFUser currentUser] objectId]};
    [PFCloud callFunctionInBackground:@"imGoing" withParameters:dict];
    NSLog(@"%@", self.dealID);
}

@end
