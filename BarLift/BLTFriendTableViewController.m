//
//  TableViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/16/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTFriendTableViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"

@interface BLTFriendTableViewController ()
@property (nonatomic, strong) NSMutableArray *friendsList;


@end

@implementation BLTFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Avenir-Medium" size:18],
      NSFontAttributeName, nil]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
            [self.tableView reloadData];
        }
    }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.friendsList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
