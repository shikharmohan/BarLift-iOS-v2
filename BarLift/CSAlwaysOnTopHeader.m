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


-(void)awakeFromNib{
    self.scrollView.delegate = nil;

}
- (void)applyLayoutAttributes:(CSStickyHeaderFlowLayoutAttributes *)layoutAttributes {
    
    [UIView beginAnimations:@"" context:nil];

    if (layoutAttributes.progressiveness >= 0.58) {
        self.hoursLabel.alpha = 1;
    } else {
        self.hoursLabel.alpha = 0;
    }
    

    [UIView commitAnimations];
}
- (IBAction)interestedButtonPressed:(id)sender {
    
    NSDictionary *dict = @{@"deal_objectId":self.dealID, @"user_objectId":[[PFUser currentUser] objectId]};
    [PFCloud callFunctionInBackground:@"notGoing" withParameters:dict];
    NSLog(@"%@", self.dealID);
}

- (void) setUpView{

    if(self.dealNames != nil && self.dealHeadline != nil){
        self.scrollView.delegate = self;
        NSInteger numLbl = [self.dealNames count] + 1;
        [self.scrollView setPagingEnabled:YES];
        [self.scrollView setContentSize:CGSizeMake(numLbl*320, 166)];
        self.pageControl.numberOfPages = numLbl;
        self.pageControl.currentPage = 0;

        for(int i =0; i<numLbl; i++)
        {
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(320 * i, 0,300, 166)];
            textLabel.textColor = [UIColor  whiteColor];
            textLabel.numberOfLines = 0;
            [textLabel setFont: [UIFont fontWithName:@"Lato-Bold" size:33.0f]];
            textLabel.textAlignment = NSTextAlignmentCenter;

            if(i == 0){
                textLabel.text = self.dealHeadline;
            }
            else{
                textLabel.text = [self.dealNames[i-1] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                
            }
            [self.scrollView addSubview:textLabel];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scrollView.frame.size.width; 
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;

}

@end
