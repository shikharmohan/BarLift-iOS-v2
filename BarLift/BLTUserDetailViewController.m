//
//  BLTUserDetailViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 1/18/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTUserDetailViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "RKCardView.h"
#import "SDWebImage/UIImageView+WebCache.h"
@interface BLTUserDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet RKCardView *cardView;

@end

@implementation BLTUserDetailViewController
@synthesize profilePicture;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.cardView.profileImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [PFUser currentUser][@"fb_id"]]]];
    self.cardView.coverImageView.image = [UIImage imageNamed:@"BG1.png"];
    self.cardView.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.cardView.titleLabel.text = [NSString stringWithFormat:@"%@", [PFUser currentUser][@"profile"][@"name"]];
    self.cardView.layer.cornerRadius = 5;
    //[self.cardView addBlur]; // comment this out if you don't want blur
    [self.cardView addShadow]; // comment this out if you don't want a shadow
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
