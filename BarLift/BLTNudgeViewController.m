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
#import "SCLAlertView/SCLAlertView.h"

@interface BLTNudgeViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

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



    

    
}
- (void) showAlert {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert showInfo:self title:@"Your First Nudge" subTitle:@"Nudge guide text: Tap and hold a friend's picture you want to nudge. Once the nudge is complete, they will receive a subtle push notifcation on their phone letting them know you want to see them out tonight." closeButtonTitle:@"Ok, got it!" duration:0.0f];
    
    [[PFUser currentUser] setValue:[NSNumber numberWithBool:YES] forKey:@"first_nudge"];
    [[PFUser currentUser] saveInBackground];
    
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
       // UIImage* imageForRendering = [friendPic.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
       // friendPic.image = imageForRendering;
        friendPic.tintColor = UIColorFromRGB(0xE8613D);
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", (long)indexPath.item);
   // NSLog(@"%@",[friendsArray objectAtIndex:indexPath.item]);
    NSString *fb_id = [friendsArray objectAtIndex:indexPath.row][@"fb_id"];
    [PFCloud callFunctionInBackground:@"nudge" withParameters:@{@"receipient":fb_id} block:^(id object, NSError *error) {
            if(!error){
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                UIImageView *friendPic = (UIImageView *) [cell viewWithTag:1];
                UIImage* imageForRendering = [friendPic.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                friendPic.image = imageForRendering;
                friendPic.tintColor = UIColorFromRGB(0xE8613D);
                [[friendsArray objectAtIndex:indexPath.row] setObject:@YES forKey:@"nudged"];
            }
        }];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
