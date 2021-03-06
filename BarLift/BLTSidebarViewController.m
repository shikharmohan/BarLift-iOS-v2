//
//  BLTSidebarViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/4/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTSidebarViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"


@interface BLTSidebarViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profPic;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *callUberButton;

@end

@implementation BLTSidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name.text = [NSString stringWithFormat:@"%@", [PFUser currentUser][@"profile"][@"name"]];
    [self.profPic sd_setImageWithURL:[NSURL URLWithString: [PFUser currentUser][@"profile"][@"pictureURL"]]];
    self.profPic.contentMode = UIViewContentModeScaleAspectFill;
    self.profPic.layer.cornerRadius = self.profPic.frame.size.width / 2;
    self.profPic.layer.masksToBounds = YES;
    self.profPic.layer.borderWidth = 0;
    self.profPic.clipsToBounds = YES;
    //    dispatch_async(dispatch_get_global_queue(0,0), ^{
//        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [PFUser currentUser][@"profile"][@"pictureURL"]]];
//        if ( data == nil )
//            return;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.profPic initWithImage:[UIImage imageWithData:data scale:1.0]];
//            self.profPic.layer.cornerRadius = self.profPic.frame.size.width / 2;
//            self.profPic.clipsToBounds = YES;
//        });
//    });

    // Do any additional setup after loading the view.
}

- (IBAction)logoutButtonPressed:(UIButton *)sender {
    self.indicator.hidden = NO;
    [self.view bringSubviewToFront:self.indicator];
    [self.indicator startAnimating];
    if ([PFUser currentUser]) {
        [[PFFacebookUtils session] closeAndClearTokenInformation];
        [PFUser logOut];
        [self.indicator stopAnimating];
    } else {
        NSLog(@"currentUser: %@", [PFUser currentUser]);
    }
    
    [self performSegueWithIdentifier:@"toLogin" sender:self];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)callUberPressed:(UIButton *)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        [PFCloud callFunctionInBackground:@"getCurrentDeal" withParameters:@{@"location":@"Northwestern"} block:^(id object, NSError *error) {
            if(!error){

            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Get Information"
                                                                message:@"Address was not retrieved or processed."
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
            }

        }];
        
    }
    else {
        // No Uber app! Open Mobile Website.
        NSURL* appStoreURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/uber/id368677368?mt=8"];
        [[UIApplication sharedApplication] openURL:appStoreURL];
    }


}
- (IBAction)shareButtonPressed:(id)sender {
    NSString *textToShare = @"There's an awesome deal tonight through BarLift at ";
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.barliftapp.com/"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSLog(@"Share button pressed");
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypeMail,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    //    NSDictionary *properties = @{@"date" : [NSDate date]};
    //    [[Mixpanel sharedInstance] track:@"Share_event" properties:properties];
    [self presentViewController:activityVC animated:YES completion:nil];
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
