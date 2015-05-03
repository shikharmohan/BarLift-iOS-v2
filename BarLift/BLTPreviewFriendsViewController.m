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
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BLTPreviewFriendsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSMutableArray *sections;
@end

@implementation BLTPreviewFriendsViewController{
    CGSize iOSScreensize;
}
@synthesize dealID;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    iOSScreensize = [[UIScreen mainScreen] bounds].size;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.data = [[NSMutableDictionary alloc] initWithCapacity:2];
    [self.data setObject:@[] forKey:@"Friends"];
    [self.data setObject:@[] forKey:@"Others"];
    self.sections = [[NSMutableArray alloc] initWithCapacity:2];
    [self.sections addObject:@"Friends"];
    [self.sections addObject:@"Others"];
    NSDictionary *dict = @{@"deal_objectId":self.dealID, @"user_objectId":[[PFUser currentUser] objectId]};
    [PFCloud callFunctionInBackground:@"getInterestedFriends" withParameters:dict block:^(id object, NSError *error) {
        if(!error){
            [self.data setObject:object forKey:@"Friends"];
            [PFCloud callFunctionInBackground:@"getInterestedOthers" withParameters:dict block:^(id obj, NSError *error) {
                if(!error){
                    [self.data setObject:obj forKey:@"Others"];
                    [self.tableView reloadData];
                }
            }];
        }

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}



#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.data objectForKey:[self.sections objectAtIndex:section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCells" forIndexPath:indexPath];
    if([[self.data objectForKey:[self.sections objectAtIndex:indexPath.section]] count] > 0){
        UILabel *friendName = (UILabel *) [cell viewWithTag:1];
        UIImageView *friendPic = (UIImageView *) [cell viewWithTag:3];
        friendName.text = [[self.data objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row][0];
        NSString *fb_id = [[self.data objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row][1];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([[self.data objectForKey:[self.sections objectAtIndex:section]] count] == 0){
        return nil;
    }
    return [self.sections objectAtIndex:section];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if([[self.data objectForKey:[self.sections objectAtIndex:section]] count] == 0){
        return nil;
    }
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(0, 5, iOSScreensize.width, 25);
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = UIColorFromRGB(0xF2F2F2);
    [myLabel setFont: [UIFont fontWithName:@"Lato-Bold" size:16.0f]];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iOSScreensize.width, 35)];
    headerView.backgroundColor = UIColorFromRGB(0xFF613D);
    [headerView addSubview:myLabel];
    if([[self.data objectForKey:[self.sections objectAtIndex:section]] count] == 0){
        headerView.hidden = YES;
    }
    else{
        headerView.hidden = NO;
    }
    return headerView;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BLTProfileViewController *vc = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [vc setFb_id:[[self.data objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row][1]];
    
}





@end
