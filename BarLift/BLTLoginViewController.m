//
//  ViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 1/16/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTLoginViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "BLTUserDetailViewController.h"
#import "FLAnimatedImage.h"
#import "SRFSurfboard.h"

@interface BLTLoginViewController () <SRFSurfboardDelegate>
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UIButton *login;
- (IBAction)aboutBarLift:(UIButton *)sender;
- (IBAction)loginToFacebook:(UIButton *)sender;

@end

@implementation BLTLoginViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self performSegueWithIdentifier:@"toDeal" sender:self];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://31.media.tumblr.com/c48378e8ce8f0e29ea7d3198df4decef/tumblr_n7wk45d38O1tvkgeto1_500.gif"]]];
    self.imageView.animatedImage = image;

    self.logo.alpha = 0.0;
    self.login.alpha = 0.0;
    
    [UIView animateWithDuration:2.0 animations:^{
        self.logo.alpha = 1.0;
    }];
    [UIView animateWithDuration:3.5 animations:^{
        self.login.alpha = 1.0;
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)aboutBarLift:(UIButton *)sender {


    
    
}

- (IBAction)loginToFacebook:(UIButton *)sender {
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [self performSegueWithIdentifier:@"toWelcome" sender:self];
            } else {
                NSLog(@"User with facebook logged in!");
            }
            [self performSegueWithIdentifier:@"toDeal" sender:self];
        }
    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SRFSurfboardViewController *surfboard = segue.destinationViewController;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"panels" ofType:@"json"];
    NSArray *panels = [SRFSurfboardViewController panelsFromConfigurationAtPath:path];
    [surfboard setPanels:panels];
    
    surfboard.delegate = self;
    
    surfboard.backgroundColor = [UIColor colorWithRed:0.97 green:0.58 blue:0.24 alpha:1.00];
}

#pragma mark - SRFSurfboardDelegate

/** ---
 *  @name SRFSurfboardDelegate
 *  ---
 */

- (void)surfboard:(SRFSurfboardViewController *)surfboard didTapButtonAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)surfboard:(SRFSurfboardViewController *)surfboard didShowPanelAtIndex:(NSInteger)index
{
    //    NSLog(@"Index: %i", index);
}

@end
