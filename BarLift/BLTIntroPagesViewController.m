//
//  BLTIntroPagesViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/21/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTIntroPagesViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface BLTIntroPagesViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property BOOL new;

@end

@implementation BLTIntroPagesViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.slideImageView.image = [UIImage imageNamed:self.imageFile];
    self.subtitleLabel.text = self.subtitleText;
    self.titleLabel.text = self.titleText;
    if([self.titleLabel.text isEqualToString:@"Nudge your friends"]){
        self.loginButton.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}




- (IBAction)loginButtonPressed:(id)sender {
    
    
    self.indicator.hidden = NO;
    [self.view bringSubviewToFront:self.indicator];
    [self.indicator startAnimating];

    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends", @"user_relationships", @"user_location"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.indicator stopAnimating];
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
                                [self performSegueWithIdentifier:@"dealSegue" sender:self];
                            }
                            else{
                                [self performSegueWithIdentifier:@"dealSegue" sender:self];
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


@end
