//
//  BLTNudgeViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/22/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTNudgeViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SCLAlertView/SCLAlertView.h"

@interface BLTNudgeViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *nudgeCount;

@end

@implementation BLTNudgeViewController{
    NSMutableArray *friendsArray;
    
}
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if(![PFUser currentUser][@"first_nudge"]){
        [self showAlert];
    }
    
    friendsArray = [[NSMutableArray alloc] initWithCapacity:2];
        for(NSDictionary* obj in [PFUser currentUser][@"friends"]){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
            [dict setObject:obj[@"fb_id"] forKey:@"fb_id"];
            [dict setObject:obj[@"name"] forKey:@"name"];
            [dict setObject:@NO forKey:@"nudged"];
            [friendsArray addObject:dict];
        }
    [[PFUser currentUser] fetchInBackground];
    self.nudgeCount.text = [NSString stringWithFormat:@"%@",[PFUser currentUser][@"nudges_left"]];
    
    

    
}

- (void) viewWillAppear:(BOOL)animated{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friends = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] initWithCapacity:2];
                [dict1 setObject:friendObject[@"id"] forKey:@"fb_id"];
                [dict1 setObject:friendObject[@"name"] forKey:@"name"];
                [friends addObject:dict1];
            }
            [[PFUser currentUser] setObject:friends forKey:@"friends"];
            [[PFUser currentUser] saveInBackground];
            NSLog(@"Got friends");
        }
    }];
    


}
- (void) showAlert {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert showInfo:self title:@"Your First Nudge" subTitle:@"Nudge guide text: Tap and hold a friend's picture you want to nudge. Once the nudge is complete, they will receive a subtle push notifcation on their phone letting them know you want to see them out tonight. You get 10 nudges per day, so use them wisely." closeButtonTitle:@"Ok, got it!" duration:0.0f];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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
    NSString *firstName = [[[friendsArray objectAtIndex:indexPath.row][@"name"] componentsSeparatedByString:@" "] objectAtIndex:0];
    friendName.text = [NSString stringWithFormat:@"%@", firstName];
    NSString *fb_id = [friendsArray objectAtIndex:indexPath.row][@"fb_id"];
    [friendPic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    friendPic.contentMode = UIViewContentModeScaleAspectFill;
    friendPic.layer.cornerRadius = friendPic.frame.size.width / 2;
    friendPic.clipsToBounds = YES;
    if([friendsArray objectAtIndex:indexPath.row][@"nudged"]){
        NSLog(@"not nudged");
    }
    else{
        UIImage* imageForRendering = [friendPic.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        friendPic.image = imageForRendering;
        friendPic.alpha = 0.2f;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", (long)indexPath.item);
   // NSLog(@"%@",[friendsArray objectAtIndex:indexPath.item]);
    NSString *fb_id = [friendsArray objectAtIndex:indexPath.row][@"fb_id"];
    if([[friendsArray objectAtIndex:indexPath.row] objectForKey:@"nudged"]){
        [PFCloud callFunctionInBackground:@"nudge" withParameters:@{@"receipient":fb_id} block:^(id object, NSError *error) {
            if(!error){
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                UIImageView *friendPic = (UIImageView *) [cell viewWithTag:1];
                UIImage* imageForRendering = [friendPic.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                friendPic.image = imageForRendering;
                friendPic.alpha = 0.8f;
                self.nudgeCount.text = [NSString stringWithFormat:@"%@",object];
                [[friendsArray objectAtIndex:indexPath.row] setObject:@YES forKey:@"nudged"];
            }
        }];
    }

}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
