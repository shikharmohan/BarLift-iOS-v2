//
//  BLTPreviewFriendsViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/20/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTPreviewFriendsViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BLTProfileViewController.h"
@interface BLTPreviewFriendsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *data;
@end

@implementation BLTPreviewFriendsViewController
@synthesize dealID;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.data = [[NSMutableArray alloc] initWithCapacity:9];
    NSDictionary *dict = @{@"deal_objectId":self.dealID, @"user_objectId":[[PFUser currentUser] objectId]};
    [PFCloud callFunctionInBackground:@"getInterestedFriends" withParameters:dict block:^(id object, NSError *error) {
        self.data = object;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}



#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.data count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCells" forIndexPath:indexPath];
    if([self.data count] > 0){
        UILabel *friendName = (UILabel *) [cell viewWithTag:1];
        UIImageView *friendPic = (UIImageView *) [cell viewWithTag:3];
        friendName.text = [self.data[indexPath.row] objectAtIndex:0];
        NSString *fb_id = [self.data[indexPath.row] objectAtIndex:1];
        [friendPic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
        friendPic.contentMode = UIViewContentModeScaleAspectFill;
        friendPic.layer.cornerRadius = friendPic.frame.size.height/2;
        friendPic.clipsToBounds = YES;
    }
    if(cell == nil){
        return cell;
    }

    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BLTProfileViewController *vc = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [vc setFb_id:[self.data objectAtIndex:indexPath.row][1]];
    
}





@end
