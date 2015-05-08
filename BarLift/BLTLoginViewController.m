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
#import "BLTButton.h"
#import "Mixpanel.h"

@interface BLTLoginViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet BLTButton *login;
@property (strong, nonatomic) NSMutableData *imageData;
- (IBAction)loginToFacebook:(UIButton *)sender;
@property (strong,nonatomic) UIImage *profPic;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) Reachability *internetReachableFoo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property BOOL new;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *overlay;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

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
   // [self.login setBackgroundImage:[self imageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
    [self.view addSubview:webViewBG];
    [self.scrollView setFrame:CGRectMake(0, 0, iOSScreenSize.width, 0.77*iOSScreenSize.height)];
    [self.view addSubview:self.overlay];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.login];
    [self.view addSubview:self.indicator];
    [self.view addSubview:self.pageControl];
    [self.scrollView addSubview:self.logo];
    [self.scrollView addSubview:self.welcomeLabel];
    [self.scrollView addSubview:self.subtitleLabel];
    self.indicator.hidden = YES;
    [self setUpScrollview];


    self.logo.alpha = 0.0;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.logo.alpha = 1.0;
    }];

    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginToFacebook:(UIButton *)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Login Pressed" properties:@{@"Time": [NSDate date],
                                                     }];
    self.indicator.hidden = NO;
    [self.view bringSubviewToFront:self.indicator];
    [self.indicator startAnimating];
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
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
               // [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser]];
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
                    [PFUser currentUser][@"nudges_left"] = @10;
                }
                else{
                    [PFUser currentUser][@"new"] = @0;
                }
                [[PFUser currentUser] setObject:userProfile[@"fb_id"] forKey:@"fb_id"];
                [[PFUser currentUser] setObject:userProfile[@"name"] forKey:@"full_name"];
                [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
                PFACL *acl = [PFACL ACLWithUser:[PFUser currentUser]];
                [acl setPublicReadAccess:YES];
                [[PFUser currentUser] setObject:acl forKey:@"ACL"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        [PFQuery clearAllCachedResults];
                        NSLog(@"User saved successfully");
                        NSLog(@"User with facebook logged in!");
                        FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?limit=1000"];
                        [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            if (!error) {
                                // result will contain an array with your user's friends in the "data" key
                                NSArray *friendObjects = [result objectForKey:@"data"];
                                NSMutableArray *friends = [NSMutableArray arrayWithCapacity:friendObjects.count];
                                // Create a list of friends' Facebook IDs
                                for (NSDictionary *friendObject in friendObjects) {
                                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:25];
                                    [dict setObject:friendObject[@"id"] forKey:@"fb_id"];
                                    [dict setObject:friendObject[@"name"] forKey:@"name"];
                                    [friends addObject:dict];
                                }
                                [[PFUser currentUser] setObject:friends forKey:@"friends"];
                                [[PFUser currentUser] saveInBackground];
                                NSLog(@"Got friends");
                                //
                                if(YES){
                                    [[PFInstallation currentInstallation] setObject:@0 forKey:@"badge"];
                                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser][@"fb_id"] forKey:@"fb_id"];
                                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                                    [[PFUser currentUser] saveInBackground];
                                    [[PFInstallation currentInstallation] saveInBackground];
                                    [self performSegueWithIdentifier:@"toWelcome" sender:self];
                                }
                                else{
                                    [PFCloud callFunctionInBackground:@"resetBadges" withParameters:@{@"fb": [PFUser currentUser][@"fb_id"]} block:^(id object, NSError *error) {
                                        if(!error){
                                        }
                                        else{
                                            NSLog(@"Could not reset badges");
                                        }
                                    }];
                                    [self performSegueWithIdentifier:@"toDeals" sender:self];
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


#pragma mark - Scrollview

-(void) setUpScrollview{
        self.scrollView.delegate = self;
        [self.scrollView setPagingEnabled:YES];
    
        [self.scrollView setContentSize:CGSizeMake(4*iOSScreenSize.width, 0.77*iOSScreenSize.height)];
        self.pageControl.numberOfPages = 4;
        self.pageControl.currentPage = 0;
    NSArray *titles = @[@"", @"Drink spontaneously", @"Never drink alone", @"Nudge your friends"];
    NSArray *subtitles=@[@"", @"Stay in the know with daily local drink deals.", @"See friends that are interested in going with less hassle.", @"Invite your friends out with a simple gesture."];
    NSArray *images = @[@"", @"deal_intro.png", @"going_intro.png", @"nudge_intro.png"];

        for(int i =1; i<4; i++)
        {
            //main title
            UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake((iOSScreenSize.width * i) + (0.078*iOSScreenSize.width),0.049*iOSScreenSize.height,0.843*iOSScreenSize.width, 0.16*iOSScreenSize.height)];
            mainTitle.textColor = [UIColor  whiteColor];
            mainTitle.numberOfLines = 0;
            [mainTitle setFont: [UIFont fontWithName:@"Avenir-Heavy" size:28.0f]];
            mainTitle.textAlignment = NSTextAlignmentCenter;
            [mainTitle setText:titles[i]];
            
            UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake((iOSScreenSize.width * i) + (0.078*iOSScreenSize.width), 0.198*iOSScreenSize.height,0.843*iOSScreenSize.width, 0.0809*iOSScreenSize.height)];
            subTitle.textColor = [UIColor  whiteColor];
            subTitle.numberOfLines = 2;
            [subTitle setFont: [UIFont fontWithName:@"Avenir-Heavy" size:14.0f]];
            subTitle.textAlignment = NSTextAlignmentCenter;
            [subTitle setText:subtitles[i]];
            
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((iOSScreenSize.width * i), 0.33*iOSScreenSize.height, iOSScreenSize.width, 0.308*iOSScreenSize.height)];
            img.image = [UIImage imageNamed:images[i]];
            
            if(iOSScreenSize.height == 480){
                
            }
            [self.scrollView addSubview:mainTitle];
            [self.scrollView addSubview:subTitle];
            [self.scrollView addSubview:img];
            
        }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
    
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

#pragma mark Button
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
