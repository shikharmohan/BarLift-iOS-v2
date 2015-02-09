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
#import "Reachability.h"
#import "SRFSurfboard.h"

@interface BLTLoginViewController () <SRFSurfboardDelegate>
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UIButton *login;
@property (strong, nonatomic) NSMutableData *imageData;
- (IBAction)aboutBarLift:(UIButton *)sender;
- (IBAction)loginToFacebook:(UIButton *)sender;
@property (strong,nonatomic) UIImage *profPic;
@property (strong, nonatomic) Reachability *internetReachableFoo;
@property BOOL new;

@end

@implementation BLTLoginViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
     //Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
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
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends", @"user_relationships", @"user_location"];
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            self.new = false;
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
                [self updateUserInformation];
                if (user.isNew) {
                    NSLog(@"User with facebook signed up and logged in!");
                    self.new = true;
                } else {
                    NSLog(@"User with facebook logged in!");
                }
                
            }
        }];

    
    
    // Add a handler function for when the entire group completes
    // It's possible that this will happen immediately if the other methods have already finished
    
    // Login PFUser using Facebook
}
-(void) updateUserInformation
{
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(!error){
                NSDictionary *userDictionary = (NSDictionary *)result;
                //create URL
                NSString *facebookID = userDictionary[@"id"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
                if(userDictionary[@"name"]){
                    userProfile[@"name"] = userDictionary[@"name"];
                }
                if(userDictionary[@"email"]){
                    userProfile[@"email"] = userDictionary[@"email"];
                }
                if(userDictionary[@"first_name"]){
                    userProfile[@"first_name"] = userDictionary[@"first_name"];
                }
                if(userDictionary[@"location"][@"name"]){
                    userProfile[@"location"] = userDictionary[@"location"][@"name"];
                }
                if(userDictionary[@"gender"]){
                    userProfile[@"gender"] = userDictionary[@"gender"];
                }
                if(userDictionary[@"birthday"]){
                    userProfile[@"birthday"] = userDictionary[@"birthday"];
                }
                if(userDictionary[@"id"]){
                    userProfile[@"fb_id"] = userDictionary[@"id"];
                }
                if([pictureURL absoluteString]){
                    userProfile[@"pictureURL"] = [pictureURL absoluteString];
                }
                if([[PFUser currentUser] isNew]){
                    [PFUser currentUser][@"new"] = @1;
                    [PFUser currentUser][@"deals_redeemed"] = @0;
                }
                else{
                    [PFUser currentUser][@"new"] = @0;
                }
                [[PFUser currentUser] setObject:userProfile[@"fb_id"] forKey:@"fb_id"];
                
                [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
                PFACL *acl = [PFACL ACLWithUser:[PFUser currentUser]];
                [acl setPublicReadAccess:YES];
                [[PFUser currentUser] setObject:acl forKey:@"ACL"];
                [[PFUser currentUser] setObject:@"Northwestern" forKey:@"university_name"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        NSLog(@"User saved successfully");
                        NSLog(@"User with facebook logged in!");
                        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            if (!error) {
                                // result will contain an array with your user's friends in the "data" key
                                NSArray *friendObjects = [result objectForKey:@"data"];
                                NSMutableArray *friends = [NSMutableArray arrayWithCapacity:friendObjects.count];
                                // Create a list of friends' Facebook IDs
                                for (NSDictionary *friendObject in friendObjects) {
                                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
                                    [dict setObject:friendObject[@"id"] forKey:@"fb_id"];
                                    [dict setObject:friendObject[@"name"] forKey:@"name"];
                                    [friends addObject:dict];
                                }
                                [[PFUser currentUser] setObject:friends forKey:@"friends"];
                                [[PFUser currentUser] saveInBackground];
                                [[PFInstallation currentInstallation] setObject:[PFUser currentUser][@"fb_id"] forKey:@"fb_id"];
                                [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                                [[PFInstallation currentInstallation] saveInBackground];

                                NSLog(@"Got friends");
                                if(self.new){
                                    [self performSegueWithIdentifier:@"toDeal" sender:self];
                                }
                                else{
                                    [self performSegueWithIdentifier:@"toDeal" sender:self];
                                }
                            }
                        }];
                    }
                    else{
                        NSLog(@"User not saved %@", error);
                    }
                }];
            }
            else{
                NSLog(@"Error in Facebook Request %@", error);
            }
        }];

}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toAbout"]){
        SRFSurfboardViewController *surfboard = segue.destinationViewController;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"panels" ofType:@"json"];
        NSArray *panels = [SRFSurfboardViewController panelsFromConfigurationAtPath:path];
        [surfboard setPanels:panels];
        surfboard.delegate = self;
        surfboard.backgroundColor = [UIColor colorWithRed:0.97 green:0.58 blue:0.24 alpha:1.00];
    }
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

#pragma mark - Reachability
// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    self.internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    self.internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    self.internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Connection Issue" message:@"Please check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [self.internetReachableFoo startNotifier];
}

@end
