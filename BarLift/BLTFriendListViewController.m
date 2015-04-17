//
//  BLTFriendListViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/16/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTFriendListViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BLTProfileViewController.h"

@interface BLTFriendListViewController ()
@property (nonatomic, strong) NSMutableArray *friendsList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString* fb;
@end

@implementation BLTFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    // Do any additional setup after loading the view.
    self.friendsList = [[NSMutableArray alloc] initWithCapacity:30];
    FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?limit=1000"];
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
                [dict setObject:friendObject[@"id"] forKey:@"fb_id"];
                [dict setObject:friendObject[@"name"] forKey:@"name"];
                [self.friendsList addObject:dict];
            }
            [[PFUser currentUser] setObject:self.friendsList forKey:@"friends"];
            [[PFUser currentUser] saveInBackground];
            NSSortDescriptor *Sorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            [self.friendsList sortUsingDescriptors:[NSArray arrayWithObject:Sorter]];

            [self.tableView reloadData];
        }
    }];
}

-(void) viewWillAppear:(BOOL)animated  {

    self.navigationController.navigationBarHidden = NO;
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
    
    return [self.friendsList count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"frCell" forIndexPath:indexPath];
    if(cell == nil){
        return cell;
    }
    UILabel *friendName = (UILabel *) [cell viewWithTag:20];
    UIImageView *friendPic = (UIImageView *) [cell viewWithTag:21];
    friendName.text = [self.friendsList objectAtIndex:indexPath.row][@"name"];
    NSString *fb_id = [self.friendsList objectAtIndex:indexPath.row][@"fb_id"];
    [friendPic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    friendPic.contentMode = UIViewContentModeScaleAspectFill;
    friendPic.layer.cornerRadius = friendPic.frame.size.height/2;
    friendPic.clipsToBounds = YES;
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
        BLTProfileViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [vc setFb_id:[self.friendsList objectAtIndex:indexPath.row][@"fb_id"]];

    
    
}


@end
