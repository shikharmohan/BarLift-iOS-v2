//
//  BLTLeftViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/9/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTLeftViewController.h"
#import <Parse/Parse.h>

@interface BLTLeftViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation BLTLeftViewController {

    NSMutableArray *friendsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    friendsArray = [PFUser currentUser][@"friends"];
    // Do any additional setup after loading the view.
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell1" forIndexPath:indexPath];
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
