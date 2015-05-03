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
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation CSAlwaysOnTopHeader{
    CGSize iOSScreensize;
}

-(void)awakeFromNib{
    self.scrollView.delegate = nil;
    self.interested = NO;
    iOSScreensize = [[UIScreen mainScreen] bounds].size;
}
- (void)applyLayoutAttributes:(CSStickyHeaderFlowLayoutAttributes *)layoutAttributes {
    
    [UIView beginAnimations:@"" context:nil];

    if (layoutAttributes.progressiveness >= 0.58) {
        self.hoursLabel.alpha = 1;
        self.scrollView.alpha = 1;
    } else {
        self.hoursLabel.alpha = 0;
        self.scrollView.alpha = 0;
    }
    

    [UIView commitAnimations];
}
- (IBAction)interestedButtonPressed:(id)sender {
    
    
    NSDictionary *dict = @{@"deal_objectId":self.dealID, @"user_objectId":[[PFUser currentUser] objectId]};
    if(self.interested != YES){
        [PFCloud callFunctionInBackground:@"imGoing" withParameters:dict block:^(id object, NSError *error) {
            if(!error){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"imGoing" object:self];
            }
        }];
        self.interested = YES;
        self.interestedButton.defaultBackgroundColor = UIColorFromRGB(0x2ECC71);
        self.interestedButton.layer.borderWidth = 0.0f;
        [self.interestedButton setTitle:@"YOU'RE INTERESTED" forState:UIControlStateNormal];
    }
    else{
        [PFCloud callFunctionInBackground:@"notGoing" withParameters:dict block:^(id object, NSError *error) {
            if(!error){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"notGoing" object:self];
            }
        }];
        self.interested = NO;
        self.interestedButton.defaultBackgroundColor = UIColorFromRGB(0xFFFFFF);
        self.interestedButton.layer.borderWidth = 2.0f;
        self.interestedButton.layer.borderColor = UIColorFromRGB(0xFF613D).CGColor;
        [self.interestedButton setTitle:@"INTERESTED?" forState:UIControlStateNormal];
    }
    
    NSLog(@"%@", self.dealID);
}

- (void) setUpView{
    if(self.interested){
        self.interestedButton.defaultBackgroundColor = UIColorFromRGB(0x2ECC71);
        self.interestedButton.layer.borderWidth = 0.0f;
        [self.interestedButton setTitle:@"YOU'RE INTERESTED" forState:UIControlStateNormal];
    }
    else{
        self.interestedButton.defaultBackgroundColor = UIColorFromRGB(0xFFFFFF);
        self.interestedButton.layer.borderWidth = 2.0f;
        self.interestedButton.layer.borderColor = UIColorFromRGB(0xFF613D).CGColor;
        [self.interestedButton setTitle:@"INTERESTED?" forState:UIControlStateNormal];
    }
    if(self.dealNames != nil && self.dealHeadline != nil){
        self.scrollView.delegate = self;
        NSInteger numLbl = [self.dealNames count] + 1;
        [self.scrollView setFrame:CGRectMake(0, 44, iOSScreensize.width, 166)];
        [self.scrollView setPagingEnabled:YES];
        [self.scrollView setContentSize:CGSizeMake(numLbl*iOSScreensize.width, 166)];
        self.pageControl.numberOfPages = numLbl;
        self.pageControl.currentPage = 0;

        for(int i =0; i<numLbl; i++)
        {
            int width = 0;
            int plus = 10;
            if(iOSScreensize.width == 320){
                width = 300;
            }
            else{
                width = 300;
                plus = 37.5;
            }
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((iOSScreensize.width*i) + plus, 0,width, 166)];
            textLabel.textColor = UIColorFromRGB(0xF2F2F2);
            textLabel.numberOfLines = 0;
            [textLabel setFont: [UIFont fontWithName:@"Lato-Bold" size:27.0f]];
            
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
