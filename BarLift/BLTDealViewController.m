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
//#import "Mixpanel.h"
@interface BLTDealViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dealName;
@property (weak, nonatomic) IBOutlet UIImageView *dealTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *barName;
@property (weak, nonatomic) IBOutlet UILabel *barAddress;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIButton *sidebarButton;
@property (weak, nonatomic) PFObject *currentDeal;
@property (weak, nonatomic) IBOutlet UIView *friendsView;
@property (weak, nonatomic) IBOutlet UILabel *goingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationIcon;
@end

@implementation BLTDealViewController
{
    NSMutableArray *friendsArray;
    NSMutableDictionary *dict;
    CGSize iOSScreenSize;
    NSArray *myProfile;
    BOOL panelUp;
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
    [self.collectionView setScrollEnabled:NO];
    iOSScreenSize = [[UIScreen mainScreen] bounds].size;

    //sidebar stuff
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton addTarget:self.revealViewController action:@selector( rightRevealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    

    self.goingButton.layer.cornerRadius = 2;
    self.goingButton.layer.borderWidth = 1;
    self.goingButton.layer.borderColor = [UIColor colorWithRed:0.984 green:0.4941 blue:0.0745 alpha:1].CGColor;

    
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
    //friend view shadow
    
    panelUp = NO;
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandFriends)];
    [self.friendsView addGestureRecognizer:singleTapGestureRecognizer];
    // drop shadow
    [self.friendsView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.friendsView.layer setShadowOpacity:0.8];
    [self.friendsView.layer setShadowRadius:3.0];
    [self.friendsView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    // Do any additional setup after loading the view.
}

-(void)expandFriends{
    [UIView transitionWithView:self.friendsView duration:0.4f options:UIViewAnimationOptionCurveEaseIn animations:^{
        if(panelUp){
            [self fadeInContent];
            CGRect frame = self.friendsView.frame;
            frame.size.height = 150;
            frame.origin.y = iOSScreenSize.height*.76;
            self.friendsView.frame = frame;
            [self.collectionView setScrollEnabled:NO];
            [self.goingLabel setFont:[UIFont systemFontOfSize:16]];
            [self.collectionView setContentOffset:CGPointZero animated:YES];
            panelUp = NO;
        }
        else{
            [self fadeOutContent];
            CGRect frame = self.friendsView.frame;
            frame.size.height = 493;
            frame.origin.y = 75;
            self.friendsView.frame = frame;
            [self.collectionView setScrollEnabled:YES];
            CGRect cvFrame = self.collectionView.frame;
            cvFrame.size.height = 473;
            self.collectionView.frame = cvFrame;
            [self.goingLabel setFont:[UIFont systemFontOfSize:25]];
            panelUp = YES;
        }
        
    } completion:^(BOOL finished) {
        
    }];


}

-(void) fadeInContent{
    [self.dealName setAlpha:1.0f];
    [self.barAddress setAlpha:1.0f];
    [self.barName setAlpha:1.0f];
    [self.dealTypeImageView setAlpha:1.0f];
}

-(void)fadeOutContent{
    [self.dealName setAlpha:0.0f];
    [self.barAddress setAlpha:0.0f];
    [self.barName setAlpha:0.0f];
    [self.dealTypeImageView setAlpha:0.0f];
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
    friendsArray = [[NSMutableArray alloc] initWithCapacity:2];

    [PFCloud callFunctionInBackground:@"getCurrentDeal" withParameters:dict block:^(id object, NSError *error) {
        if(!error){
            self.currentDeal = (PFObject *) object[0];
            self.descriptionLabel.text = object[0][@"description"];
            self.dealName.text = object[0][@"name"];
            self.barName.text = object[0][@"user"][@"bar_name"];
            self.barAddress.text = object[0][@"user"][@"address"];
            [dict setObject:[object[0] objectId] forKey:@"deal_objectId"];
            [PFCloud callFunctionInBackground:@"getFriends" withParameters:dict block:^(id object, NSError *error) {
                if(!error){
                    for(int i = 0; i < 30; i++) {
                        for (NSArray *obj in object){
                            if([myProfile isEqualToArray:obj]){
                                NSLog(@"Already Going");
                                [UIView transitionWithView:self.backgroundView duration:1.0f options:UIViewAnimationOptionTransitionNone animations:^{
                                    [self.backgroundView setBackgroundColor:[UIColor colorWithRed:0.1804 green:0.8 blue:0.4431 alpha:1]];
                                    [self.goingButton setTitleColor:[UIColor colorWithRed:0.1804 green:0.8 blue:0.4431 alpha:1] forState:UIControlStateNormal];
                                    [self.goingButton.layer setBorderColor:[UIColor colorWithRed:0.1804 green:0.8 blue:0.4431 alpha:1].CGColor];
                                }completion:^(BOOL finished) {
                                    self.goingButton.enabled = NO;
                                }];
                                //[friendsArray addObject:obj];
                            }
                            else{
                                [friendsArray addObject:obj];
                            }
                        }
                    }
                    [self.collectionView reloadData];
                    //[self resizeCollectionView];
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
    [PFCloud callFunctionInBackground:@"imGoing" withParameters:dict block:^(id object, NSError *error) {
        if(!error){
            NSLog(@"%@", object);
            [self.goingButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [UIView transitionWithView:self.backgroundView duration:1.0f options:UIViewAnimationOptionTransitionNone animations:^{
                [self.backgroundView setBackgroundColor:[UIColor colorWithRed:0.1804 green:0.8 blue:0.4431 alpha:1]];
                [self.goingButton setTitleColor:[UIColor colorWithRed:0.1804 green:0.8 blue:0.4431 alpha:1] forState:UIControlStateNormal];
                [self.goingButton.layer setBorderColor:[UIColor colorWithRed:0.1804 green:0.8 blue:0.4431 alpha:1].CGColor];
            }completion:^(BOOL finished) {
                    self.goingButton.enabled = NO;
                if([friendsArray indexOfObject:myProfile] == -1){
                  //  [friendsArray insertObject:myProfile atIndex:0];
                    [self resizeCollectionView];
                }
//                NSDictionary *properties = @{@"date" : [NSDate date]};
//                [[Mixpanel sharedInstance] track:@"RSVP_event" properties:properties];
            }];
        }
    }];
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
    UILabel *friendName = (UILabel *) [cell viewWithTag:2];
    UIImageView *friendPic = (UIImageView *) [cell viewWithTag:1];
    NSString *firstName = [[[[friendsArray objectAtIndex:indexPath.row] objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString *lastNameInit = [[[[[friendsArray objectAtIndex:indexPath.row] objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:1] substringToIndex:1];
    friendName.text = [NSString stringWithFormat:@"%@ %@.", firstName, lastNameInit];
    NSString *fb_id = [[friendsArray objectAtIndex:indexPath.row] objectAtIndex:1];
    [friendPic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    friendPic.contentMode = UIViewContentModeScaleAspectFill;
    friendPic.layer.cornerRadius = friendPic.frame.size.width / 2;
    friendPic.clipsToBounds = YES;
//    dispatch_async(dispatch_get_global_queue(0,0), ^{
//        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
//        if ( data == nil )
//            return;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [friendPic initWithImage:[UIImage imageWithData:data scale:1.0]];
//            friendPic.layer.cornerRadius = friendPic.frame.size.width / 2;
//            friendPic.clipsToBounds = YES;
//        });
//    });
    return cell;
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
