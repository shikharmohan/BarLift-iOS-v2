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
@property (strong, nonatomic) NSMutableData *imageData;
- (IBAction)aboutBarLift:(UIButton *)sender;
- (IBAction)loginToFacebook:(UIButton *)sender;
@property (strong,nonatomic) UIImage *profPic;

@end

@implementation BLTLoginViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
//    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        [self updateUserInformation];
//        [self performSegueWithIdentifier:@"toDeal" sender:self];
//    }
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
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        BOOL new = false;
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
                [self performSegueWithIdentifier:@"toWelcome" sender:self];
                new = true;
            } else {
                NSLog(@"User with facebook logged in!");
                [self performSegueWithIdentifier:@"toDeal" sender:self];
            }

        }
    }];
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
            }
            else{
                [PFUser currentUser][@"new"] = @0;
            }
            [[PFUser currentUser] setObject:userProfile[@"fb_id"] forKey:@"fb_id"];
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            PFACL *acl = [PFACL ACLWithUser:[PFUser currentUser]];
            [acl setPublicReadAccess:YES];
            [[PFUser currentUser] setObject:acl forKey:@"ACL"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    NSLog(@"User saved successfully");
                    if ([[PFUser currentUser][@"new"] isEqualToNumber:@1]) {
                        NSLog(@"User with facebook signed up and logged in!");
                        [self performSegueWithIdentifier:@"toWelcome" sender:self];
                    } else {
                        NSLog(@"User with facebook logged in!");
                        [self performSegueWithIdentifier:@"toDeal" sender:self];
                    }
                }
                else{
                    NSLog(@"User not saved%@", error);
                }
            }];

            [self requestImage];
        }
        else{
            NSLog(@"Error in Facebook Request %@", error);
        }
    }];
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
        }
    }];
}

-(void)uploadPFFileToParse:(UIImage *)image
{
    NSLog(@"upload called");
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if(!imageData){
        NSLog(@"Image Data not found");
        return;
    }
    PFFile *photoFile = [PFFile fileWithData:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            PFObject *photo = [PFObject objectWithClassName:@"ProfilePhoto"];
            [photo setObject:[PFUser currentUser] forKey:@"user"];
            [photo setObject:photoFile forKey:@"profile_image"];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    NSLog(@"Profile picture was saved successfully");
                }
                else{
                    NSLog(@"Picture not saved: %@", error);
                }
            }];
        }
    }];
}

- (void) requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:@"ProfilePhoto"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(number  == 0)
        {
            PFUser *user =[PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];
            NSURL *profilePictureURL = [NSURL URLWithString:user[@"profile"][@"pictureURL"]];
            NSURLRequest *urlRequest= [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if(!urlConnection){
                NSLog(@"failed to download picture");
            }
            else{
                NSLog(@"pic received");
            }
        }
    }];

}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *profilePicture = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profilePicture];
    
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

@end