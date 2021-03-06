//
//  BLTSignUpViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/25/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTSignUpViewController.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import "BLTButton.h"
@interface BLTSignUpViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet BLTButton *studentButton;
@property (weak, nonatomic) IBOutlet BLTButton *gradButton;

@end

@implementation BLTSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.profilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [PFUser currentUser][@"fb_id"]]]];
    self.profilePic.contentMode = UIViewContentModeScaleAspectFill;
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2;
    self.profilePic.clipsToBounds = YES;
    self.profilePic.layer.borderWidth = 2.0;
    self.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@", [PFUser currentUser][@"profile"][@"first_name"]];
    
    
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
- (IBAction)studentButtonPressed:(id)sender {
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"is_student"];
}
- (IBAction)gradButtonPressed:(id)sender {
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"is_student"];
    [[PFUser currentUser] setObject:@"I've graduated" forKey:@"affiliation"];
}

@end
