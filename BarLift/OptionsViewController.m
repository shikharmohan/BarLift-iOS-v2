//
//  OptionsViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/14/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "OptionsViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BLTButton.h"
@interface OptionsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet BLTButton *nudgeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end

@implementation OptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor whiteColor],NSForegroundColorAttributeName,
     [UIFont fontWithName:@"Avenir-Medium" size:18],
     NSFontAttributeName, nil];

    [self setUpView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
   // self.navigationController.navigationBarHidden = YES;

}

- (void) setUpView {
    NSString *fb_id = [PFUser currentUser][@"fb_id"];
    [self.profilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    self.profilePic.contentMode = UIViewContentModeScaleAspectFill;
    self.profilePic.contentMode = UIViewContentModeScaleAspectFill;
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2;
    self.profilePic.clipsToBounds = YES;
//    self.profilePic.layer.borderWidth = 2.0;
//    self.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;

    
    [self.name setText:[PFUser currentUser][@"profile"][@"name"]];
    if([PFInstallation currentInstallation].badge >0){
        [self.nudgeButton setTitle:[NSString stringWithFormat:@"Nudges (%ld new)",(long)[PFInstallation currentInstallation].badge] forState:UIControlStateNormal];
    }

}

- (IBAction)logoutButtonPressed:(id)sender {
    if ([PFUser currentUser]) {
        [[PFFacebookUtils session] closeAndClearTokenInformation];
        [PFUser logOut];
    } else {
        NSLog(@"currentUser: %@", [PFUser currentUser]);
    }
    
    [self performSegueWithIdentifier:@"toLogin" sender:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissModalPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)barlifttermsPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.barliftapp.com/#/terms"]];
    
}

@end
