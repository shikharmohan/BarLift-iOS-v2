//
//  BLTLeftViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/9/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTLeftViewController.h"
#import <Parse/Parse.h>
#import "JFMinimalNotification.h"
@interface BLTLeftViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) JFMinimalNotification *minimalNotification;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation BLTLeftViewController {

    NSMutableArray *friendsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    friendsArray = [PFUser currentUser][@"friends"];
    // Do any additional setup after loading the view.
    
    //Close Button
    
    self.closeButton.layer.cornerRadius = 2;
    self.closeButton.layer.borderWidth = 1;
    self.closeButton.layer.borderColor = [UIColor whiteColor].CGColor;

    PFQuery *query = [PFInstallation query];
    [PFInstallation currentInstallation];
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleDefault
                                                                      title:@"You just zapped a friend!"
                                                                   subTitle:@"Have a great night!"];
    
    [self.minimalNotification setFrame:CGRectMake(0, 0, 320, 100)];
    
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell2" forIndexPath:indexPath];
    UILabel *friendName = (UILabel *) [cell viewWithTag:6];
    UIImageView *friendPic = (UIImageView *) [cell viewWithTag:7];
    friendName.text = [[friendsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString *fb_id = [[friendsArray objectAtIndex:indexPath.row] objectForKey:@"fb_id"];
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


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UILabel *str = (UILabel *)[cell viewWithTag:6];
    NSString *text = str.text;
    //Minimal Notification

    [self.minimalNotification show];
    [self performSelector:@selector(dismissNotification) withObject:nil afterDelay:2.5];

}
- (void) dismissNotification {
    [self.minimalNotification dismiss];
}
- (IBAction)closeButtonPressed:(UIButton *)sender {
    [self dismissModalViewControllerAnimated:YES];

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
