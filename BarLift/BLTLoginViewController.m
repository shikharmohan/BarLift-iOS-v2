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
#import "Reachability.h"

@interface BLTLoginViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UIButton *login;
@property (weak, nonatomic) IBOutlet UIButton *aboutBarLift;
@property (strong, nonatomic) NSMutableData *imageData;
- (IBAction)aboutBarLift:(UIButton *)sender;
- (IBAction)loginToFacebook:(UIButton *)sender;
@property (strong,nonatomic) UIImage *profPic;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) Reachability *internetReachableFoo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property BOOL new;

@end

@implementation BLTLoginViewController{
    CGSize iOSScreenSize;

}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
     //Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Connection Issue"
                                                        message:@"Please connect to a network and try again."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Dismiss", nil];
        [alert show];
    } else {
        NSLog(@"There IS internet connection");
    }
    
    
    
    
    NSString *filePath;
    if(iOSScreenSize.height == 480){
        filePath = [[NSBundle mainBundle] pathForResource:@"bgblack4" ofType:@"gif"];
    }
    if(iOSScreenSize.height == 568){
        filePath = [[NSBundle mainBundle] pathForResource:@"bgblack4" ofType:@"gif"];
    }
    else if (iOSScreenSize.height == 667){
        filePath = [[NSBundle mainBundle] pathForResource:@"bgblack47" ofType:@"gif"];
    }
    else if (iOSScreenSize.height == 736){
        filePath = [[NSBundle mainBundle] pathForResource:@"bgblack55" ofType:@"gif"];
    }
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    UIWebView *webViewBG = [[UIWebView alloc] initWithFrame:self.view.frame];
    [webViewBG loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webViewBG.userInteractionEnabled = NO;
    [self.view addSubview:webViewBG];
    [self.view addSubview:self.aboutBarLift];
    [self.view addSubview:self.logo];
    [self.view addSubview:self.login];
    [self.view addSubview:self.indicator];
    [self.view addSubview:self.welcomeLabel];
    [self.view addSubview:self.subtitleLabel];
    self.indicator.hidden = YES;
    


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
    
    
    self.indicator.hidden = NO;
    [self.view bringSubviewToFront:self.indicator];
    [self.indicator startAnimating];
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends", @"user_relationships", @"user_location"];
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            [self.indicator stopAnimating];
            self.indicator.hidden = YES;

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
                                    [self performSegueWithIdentifier:@"toWelcome" sender:self];
                                }
                                else{
                                    [self performSegueWithIdentifier:@"toWelcome" sender:self];
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
