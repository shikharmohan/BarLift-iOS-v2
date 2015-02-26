//
//  BLTDealViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/4/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTDealViewController.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import "JFMinimalNotification.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "SCLAlertView.h"
#import "BLTDealView.h"
#import "DataClass.h"

//#import "Mixpanel.h"
@interface BLTDealViewController ()
@property (weak, nonatomic) IBOutlet UIButton *dealInfoButton;
@property (weak, nonatomic) IBOutlet UILabel *dealName;
@property (weak, nonatomic) IBOutlet UILabel *barName;
@property (weak, nonatomic) IBOutlet UILabel *barAddress;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIButton *sidebarButton;
@property (weak, nonatomic) PFObject *currentDeal;
@property (strong, nonatomic) IBOutlet UIView *friendsView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *goingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationIcon;
@property (weak, nonatomic) IBOutlet UIView *nudgeView;
@property (weak, nonatomic) IBOutlet UIButton *nudgeButton;
@property (weak, nonatomic) IBOutlet UIButton *purchaseDrinks;
@property (weak, nonatomic) IBOutlet BLTDealView *dealView;
@property (strong, nonatomic) UIButton *nudge;
@property (weak, nonatomic) IBOutlet UIImageView *expandButton;
@property (nonatomic) BOOL going;

@end

@implementation BLTDealViewController
{
    NSMutableArray *friendsArray;
    NSMutableDictionary *dict;
    CGSize iOSScreenSize;
    NSArray *myProfile;
    BOOL panelUp;
    SCLAlertView *alert;
    NSString* desc;
    
}


- (void) viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(createUI) name: @"UpdateUINotification" object: nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //load background image
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg@2x.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

    
    myProfile = [NSArray arrayWithObjects:[PFUser currentUser][@"profile"][@"name"], [PFUser currentUser][@"profile"][@"fb_id"], nil];
    
    iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    if(iOSScreenSize.height != 736){
        [self.collectionView setScrollEnabled:NO];
    }

    //sidebar stuff
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton addTarget:self.revealViewController action:@selector( revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        [self.nudgeButton addTarget:self.revealViewController action:@selector(rightRevealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    


    
    dict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dict setObject:[PFUser currentUser][@"university_name"] forKey:@"location"];
    [dict setObject:[PFUser currentUser][@"fb_id"] forKey:@"fb_id"];
    [dict setObject:[[PFUser currentUser] objectId] forKey:@"user_objectId"];

    //create ui with deal
    [self createUI];
    
    
    //Address-> Maps
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
    UITapGestureRecognizer *tapGesture1 =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];

    [self.barAddress addGestureRecognizer:tapGesture1];
    [self.locationIcon addGestureRecognizer:tapGesture];
    
    self.barAddress.userInteractionEnabled = YES;
    self.locationIcon.userInteractionEnabled = YES;
    //friend view shadow
    
    panelUp = NO;
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandFriends)];
    [self.friendsView addGestureRecognizer:singleTapGestureRecognizer];
    

    // drop shadow/panel drag & slide
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    [self.friendsView addGestureRecognizer:panGestureRecognizer];
    [self.friendsView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.friendsView.layer setShadowOpacity:0.8];
    [self.friendsView.layer setShadowRadius:3.0];
    [self.friendsView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [self.view addSubview:self.friendsView];
    
    
    //animate nudge button
    CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=0.6;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0f];
    theAnimation.toValue=[NSNumber numberWithFloat:0.7f];
    [self.nudgeButton.layer addAnimation:theAnimation forKey:@"animateOpacity"]; //myButton.layer instead of
    [self.nudgeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    
    //deal description alert
    UITapGestureRecognizer *tapGesture4 =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDescription)];
    [self.dealName addGestureRecognizer:tapGesture4];
    self.dealName.userInteractionEnabled = YES;
}

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    //CGPoint touchLocation = [panGestureRecognizer locationInView:self.view];
    CGPoint vel = [panGestureRecognizer velocityInView:self.friendsView];
    if(vel.y < 0){
        NSLog(@"%f", vel.y);
        [UIView transitionWithView:self.friendsView duration:0.3f options:UIViewAnimationCurveEaseOut animations:^{
           [self fadeOutContent];
            self.expandButton.image = [UIImage imageNamed:@"thex-3x.png"];
            CGRect frame = self.friendsView.frame;
            frame.size.width = iOSScreenSize.width;
            frame.origin.y = 90;
            self.friendsView.frame = frame;
            panelUp = YES;
            [UIView transitionWithView:self.goingLabel duration:1.5f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.goingLabel setFont:[UIFont systemFontOfSize:23]];
            } completion:^(BOOL finished) {
            }];
        } completion:^(BOOL finished) {
            
        }];
    }
    else if(vel.y > 0){
        NSLog(@"%f", vel.y);
        [UIView transitionWithView:self.friendsView duration:0.3f options:UIViewAnimationCurveEaseOut animations:^{
            [self fadeInContent];

            self.expandButton.image = [UIImage imageNamed:@"theplus-3x.png"];
            CGRect frame = self.friendsView.frame;
            frame.size.width = iOSScreenSize.width;
            frame.origin.y = 0.8309*iOSScreenSize.height;
            if(iOSScreenSize.height == 480){
                frame.origin.y = 450;
            }
            if(iOSScreenSize.height == 667){
                frame.origin.y = 482;
            }
            self.friendsView.frame = frame;
            [UIView transitionWithView:self.goingLabel duration:1.5f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.goingLabel setFont:[UIFont systemFontOfSize:16]];
            } completion:^(BOOL finished) {
                
            }];
            panelUp = NO;
            
        } completion:^(BOOL finished) {
            
        }];
    
    }
    
}
-(void) showDescription{
    alert = [[SCLAlertView alloc] init];
    [alert showInfo:self title:@"Deal Details" subTitle:desc closeButtonTitle:@"Ok, got it!" duration:0.0f];

}

-(void)expandFriends{
    if(iOSScreenSize.height != 736){
        [UIView transitionWithView:self.friendsView duration:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            if(panelUp){
                [self fadeInContent];
                self.expandButton.image = [UIImage imageNamed:@"theplus-3x.png"];
                CGRect frame = self.friendsView.frame;
                frame.origin.y = 0.8309*iOSScreenSize.height;
                if(iOSScreenSize.height == 480){
                    frame.origin.y = 450;
                }
                if(iOSScreenSize.height == 667){
                    frame.origin.y = 482;
                }
                self.friendsView.frame = frame;
                [self.collectionView setScrollEnabled:NO];
                [UIView transitionWithView:self.goingLabel duration:1.5f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.goingLabel setFont:[UIFont systemFontOfSize:16]];
                } completion:^(BOOL finished) {
                    
                }];
                panelUp = NO;
            }
            else{
                [self fadeOutContent];
                self.expandButton.image = [UIImage imageNamed:@"thex-3x.png"];

                CGRect frame = self.friendsView.frame;
                frame.origin.y = 90;
                self.friendsView.frame = frame;
                [self.collectionView setScrollEnabled:YES];
                [UIView transitionWithView:self.goingLabel duration:1.5f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.goingLabel setFont:[UIFont systemFontOfSize:23]];
                } completion:^(BOOL finished) {
                }];
                panelUp = YES;

                
                
            }
            
        } completion:^(BOOL finished) {
            
        }];
    
    }

}

-(void) fadeInContent{
    [self.dealName setAlpha:1.0f];
    [self.barAddress setAlpha:1.0f];
    [self.barName setAlpha:1.0f];
    [self.dealInfoButton setAlpha:1.0f];
    self.dealView.hidden = NO;

}

-(void)fadeOutContent{
    [self.dealName setAlpha:0.0f];
    [self.barAddress setAlpha:0.0f];
    [self.barName setAlpha:0.0f];
    [self.dealInfoButton setAlpha:0.0f];
    self.dealView.hidden = YES;

}



-(void) labelTap{
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        
        NSString *addr = [self.barAddress.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%@",addr]]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }

}

- (void) createUI {
    //deal created here
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    friendsArray = [[NSMutableArray alloc] initWithCapacity:2];

    [PFCloud callFunctionInBackground:@"getCurrentDeal" withParameters:dict block:^(id object, NSError *error) {
        if(!error){
            self.currentDeal = (PFObject *) object[0];
            self.descriptionLabel.text = object[0][@"description"];
            self.dealName.text = object[0][@"name"];
            desc = object[0][@"description"];
            self.barName.text = object[0][@"user"][@"bar_name"];
            self.barAddress.text = object[0][@"user"][@"address"];
            [dict setObject:[object[0] objectId] forKey:@"deal_objectId"];
            DataClass *obj=[DataClass getInstance];
            obj.dealID= [object[0] objectId];
            [PFCloud callFunctionInBackground:@"getFriends" withParameters:dict block:^(id object, NSError *error) {
                if(!error){
                    for(int i = 0; i < 1; i++) {
                        for (NSArray *obj in object){
                            if([myProfile isEqualToArray:obj]){
                                NSLog(@"Already Going");
                                self.going = YES;
                                [UIView transitionWithView:self.goingButton duration:0.5f options:UIViewAnimationOptionTransitionNone animations:^{
                                    [self.goingButton setImage:[UIImage imageNamed:@"interested2-3x.png"] forState:UIControlStateNormal];
                                }completion:^(BOOL finished) {
                                }];
                                //add self to beginning of list
                                //[friendsArray addObject:obj];
                            }
                            else{
                                //only add new friends
                                [friendsArray addObject:obj];
                            }
                        }
                    }
                    
                    NSOrderedSet *mySet = [[NSOrderedSet alloc] initWithArray:friendsArray];
                    friendsArray = [[NSMutableArray alloc] initWithArray:[mySet array]];

                    [self.collectionView reloadData];
                    [self.indicator stopAnimating];
                    //[self resizeCollectionView];
                }
                else{
                    [self.indicator stopAnimating];
                }
            }];
        }
    }];
}

-(void) resizeCollectionView {
    int len = [friendsArray count];
    float rows = len / 3;
    
    NSLog(@"%f", self.collectionView.frame.size.height);
    if(iOSScreenSize.height == 568){
        float padding = (rows-1)*115;
        if(padding <0){
            padding = 0;
        }
        if(rows >= 1 && (len %3 == 1 || len%3 == 2)){
            padding += 115;
        }
        [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                                 self.collectionView.frame.origin.y,
                                                 self.collectionView.frame.size.width,padding+115)];
        [self.scroller setContentSize:CGSizeMake(320, 620+padding)];
    }
    if(iOSScreenSize.height == 667){
        float padding = rows*115;
        if(rows == 1){
            padding = 130;
        }
        if(padding < 0){
            padding = 0;
        }
        if(rows > 1 &&(len %3 == 1 || len%3 == 2)){
            padding += 115;
        }
        if(padding > 200){
            padding -= 115;
        }
        [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                                 self.collectionView.frame.origin.y,
                                                 self.collectionView.frame.size.width,padding+200)];
        NSLog(@"%f", self.collectionView.frame.size.height);
        
        [self.scroller setContentSize:CGSizeMake(375, 600+padding)];
    }
    [self.collectionView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Going Button
- (IBAction)goingButtonPressed:(UIButton *)sender {
    if(self.going == NO){
        self.indicator.hidden = NO;
        [self.indicator startAnimating];
        [PFCloud callFunctionInBackground:@"imGoing" withParameters:dict block:^(id object, NSError *error) {
            if(!error){
                NSLog(@"%@", object);
                self.going = YES;
                [UIView transitionWithView:self.goingButton duration:0.5f options:UIViewAnimationOptionTransitionNone animations:^{
                    [self.goingButton setImage:[UIImage imageNamed:@"interested2-3x.png"] forState:UIControlStateNormal];
                    self.going = YES;
                    
                }completion:^(BOOL finished) {
                    [self.indicator stopAnimating];
                    if([friendsArray indexOfObject:myProfile] == -1){
                        //  [friendsArray insertObject:myProfile atIndex:0];
                        // [self resizeCollectionView];
                    }
                    //                NSDictionary *properties = @{@"date" : [NSDate date]};
                    //                [[Mixpanel sharedInstance] track:@"RSVP_event" properties:properties];
                }];
            }
        }];
    }
    else{
        self.indicator.hidden = NO;
        [self.indicator startAnimating];
    [PFCloud callFunctionInBackground:@"notGoing" withParameters:dict block:^(id object, NSError *error) {
        if(!error){
            self.going = NO;
            [UIView transitionWithView:self.goingButton duration:1.0f options:UIViewAnimationOptionTransitionNone animations:^{
                [self.goingButton setImage:[UIImage imageNamed:@"interested3-3x.png"] forState:UIControlStateNormal];
            } completion:^(BOOL finished) {
                [self.goingButton setImage:[UIImage imageNamed:@"interested1-3x.png"] forState:UIControlStateNormal];
                [self.indicator stopAnimating];
            }];
        
        }
        
    }];
    }

}



- (IBAction)shareButtonPressed:(id)sender {
    NSString *textToShare = [NSString stringWithFormat:@"%@ at %@ tonight! Download BarLift at", self.dealName.text, self.barName.text];
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




#pragma mark - Collection View Methods

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [friendsArray count];
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    UILabel *friendName = (UILabel *) [cell viewWithTag:2];
    UIImageView *friendPic = (UIImageView *) [cell viewWithTag:1];
    NSString *firstName = [[[[friendsArray objectAtIndex:indexPath.row] objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:0];
    friendName.text = [NSString stringWithFormat:@"%@", firstName];
    NSString *fb_id = [[friendsArray objectAtIndex:indexPath.row] objectAtIndex:1];
    [friendPic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    friendPic.contentMode = UIViewContentModeScaleAspectFill;
    friendPic.layer.cornerRadius = friendPic.frame.size.width / 2;
    friendPic.clipsToBounds = YES;
    return cell;
}

- (IBAction)purchaseDrinksPressed:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    SCLButton *button =  [alert addButton:@"Yes" actionBlock:^(void) {
        NSLog(@"Yes button tapped");
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"pay_interest"];
        [[PFUser currentUser] saveInBackground];
    }];
   SCLButton *button1 = [alert addButton:@"No" actionBlock:^(void) {
        NSLog(@"No button tapped");
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"pay_interest"];
        [[PFUser currentUser] saveInBackground];
    }];

    button.layer.borderWidth = 2.0f;

    button.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor whiteColor];
        buttonConfig[@"textColor"] = [UIColor blackColor];
        buttonConfig[@"borderColor"] = [UIColor orangeColor];
        
        return buttonConfig;
    };
    button1.layer.borderWidth = 2.0f;
    
    button1.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor whiteColor];
        buttonConfig[@"textColor"] = [UIColor blackColor];
        buttonConfig[@"borderColor"] = [UIColor orangeColor];
        
        return buttonConfig;
    };


    [alert showCustom:self image:[UIImage imageNamed:@"dealinfo-3x.png"] color:[UIColor clearColor] title:@"Purchase Drinks" subTitle:@"Hey there, we haven't added this feature yet but would you be interested in purchasing drinks through the app in the future?" closeButtonTitle:@"" duration:0.0f];
    
 // Notice

    
    
    
}

- (IBAction)dealInfoButtonPressed:(id)sender {
    alert = [[SCLAlertView alloc] init];
    [alert showInfo:self title:@"Deal Details" subTitle:desc closeButtonTitle:@"Ok, got it!" duration:0.0f];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.


}


@end

