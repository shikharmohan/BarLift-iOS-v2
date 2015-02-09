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

@interface BLTDealViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dealName;
@property (weak, nonatomic) IBOutlet UIImageView *dealTypeImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UILabel *barName;
@property (weak, nonatomic) IBOutlet UILabel *barAddress;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) PFObject *currentDeal;
@property (weak, nonatomic) JFMinimalNotification *minimalNotification;
@end

@implementation BLTDealViewController
{
    NSMutableArray *friendsArray;
    NSMutableDictionary *dict;


}

- (void) viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(createUI) name: @"UpdateUINotification" object: nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scroller setScrollEnabled:YES];
    [self.scroller setContentSize:CGSizeMake(320, 640)];
    
    //sidebar stuff
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( rightRevealToggle: )];
        [self.shareButton setTarget:self.revealViewController];
        [self.shareButton setAction:@selector(revealToggle:)];
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
    [self.barAddress addGestureRecognizer:tapGesture];
    
    
    //Minimal Notification
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleSuccess
                                                                      title:@"You have just RSVP'd to the deal"
                                                                   subTitle:@"Have a great night!"];
    
    /**
     * Set the desired font for the title and sub-title labels
     * Default is System Normal
     */
    UIFont* titleFont = [UIFont fontWithName:@"STHeitiK-Light" size:22];
    [self.minimalNotification setTitleFont:titleFont];
    UIFont* subTitleFont = [UIFont fontWithName:@"STHeitiK-Light" size:16];
    [self.minimalNotification setSubTitleFont:subTitleFont];
    
    /**
     * Add the notification to a view
     */
    [self.view addSubview:self.minimalNotification];

    
    // Do any additional setup after loading the view.
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
                    for (NSDictionary *obj in object){
                        [friendsArray addObject:obj];
                    }
                    int len = [friendsArray count];
                    float rows = len / 3;
                    float padding = rows*105;
                    [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                                             self.collectionView.frame.origin.y,
                                                             self.collectionView.frame.size.width,padding+193)];
                    [self.scroller setContentSize:CGSizeMake(320, 640+padding)];
                    [self.collectionView reloadData];
                }
            }];
        }
    }];
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
            [UIView transitionWithView:self.backgroundView duration:1.5f options:UIViewAnimationOptionTransitionNone animations:^{
                [self.backgroundView setBackgroundColor:[UIColor colorWithRed:0.1804 green:0.8 blue:0.4431 alpha:1]];
                [self.goingButton setTitleColor:[UIColor colorWithRed:0.1804 green:0.8 blue:0.4431 alpha:1] forState:UIControlStateNormal];
                [self.goingButton.layer setBorderColor:[UIColor colorWithRed:0.1804 green:0.8 blue:0.4431 alpha:1].CGColor];
            }completion:^(BOOL finished) {
                    self.goingButton.enabled = NO;
                    [self.minimalNotification show];
                    [self performSelector:@selector(dismissNotification) withObject:nil afterDelay:2.5];
            }];
        }
    }];
}

- (void) dismissNotification {
    [self.minimalNotification dismiss];
}

//- (IBAction)shareButtonPressed:(id)sender {
//    NSString *textToShare = [NSString stringWithFormat:@"%@ at %@ tonight! Download BarLift at", self.dealName.text, self.barName.text];
//    NSURL *myWebsite = [NSURL URLWithString:@"http://www.barliftapp.com/"];
//    
//    NSArray *objectsToShare = @[textToShare, myWebsite];
//    
//    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
//    
//    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
//                                   UIActivityTypeMail,
//                                   UIActivityTypePrint,
//                                   UIActivityTypeAssignToContact,
//                                   UIActivityTypeSaveToCameraRoll,
//                                   UIActivityTypeAddToReadingList,
//                                   UIActivityTypePostToFlickr,
//                                   UIActivityTypePostToVimeo];
//    
//    activityVC.excludedActivityTypes = excludeActivities;
//    
//    [self presentViewController:activityVC animated:YES completion:nil];
//    if ([activityVC respondsToSelector:@selector(popoverPresentationController)])
//    {
//        // iOS 8+
//        UIPopoverPresentationController *presentationController = [activityVC popoverPresentationController];
//        
//        presentationController.sourceView = sender; // if button or change to self.view.
//    }
//}




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
    friendName.text = [[friendsArray objectAtIndex:indexPath.row] objectAtIndex:0];
    NSString *fb_id = [[friendsArray objectAtIndex:indexPath.row] objectAtIndex:1];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [friendPic initWithImage:[UIImage imageWithData:data scale:1.0]];
            friendPic.layer.cornerRadius = friendPic.frame.size.width / 2;
            friendPic.clipsToBounds = YES;
        });
    });
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
