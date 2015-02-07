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
@interface BLTDealViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dealName;
@property (weak, nonatomic) IBOutlet UIImageView *dealTypeImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UILabel *barName;
@property (weak, nonatomic) IBOutlet UILabel *barAddress;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) PFObject *currentDeal;
@end

@implementation BLTDealViewController
{
    NSArray *friendsArray;

}

- (void) viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(createUI) name: @"UpdateUINotification" object: nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //sidebar stuff
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( rightRevealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    friendsArray = [NSArray arrayWithObjects: [NSArray arrayWithObjects: @"Shikhar Mohan", @"10153138455222223", nil], [NSArray arrayWithObjects: @"Shikhar Mohan", @"10153138455222223", nil], [NSArray arrayWithObjects: @"Shikhar Mohan", @"10153138455222223", nil], [NSArray arrayWithObjects: @"Shikhar Mohan", @"10153138455222223", nil], [NSArray arrayWithObjects: @"Shikhar Mohan", @"10153138455222223", nil], [NSArray arrayWithObjects: @"Shikhar Mohan", @"10153138455222223", nil], [NSArray arrayWithObjects: @"Shikhar Mohan", @"10153138455222223", nil], [NSArray arrayWithObjects: @"Zak Allen", @"10206051829519092", nil], nil];

    
    //create ui with deal
    [self createUI];
    
    // Do any additional setup after loading the view.
}


- (void) createUI {
    //deal created here
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [PFCloud callFunctionInBackground:@"getCurrentDeal" withParameters:@{@"location": @"Northwestern"} block:^(id object, NSError *error) {
        if(!error){
            self.dealName.text = object[0][@"name"];
            self.barName.text = object[0][@"user"][@"bar_name"];
            self.barAddress.text = object[0][@"user"][@"address"];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
