//
//  BLTNudgeViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/24/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTNudgeViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "DataClass.h"
@interface BLTNudgeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *questionLabel
;
@property (weak, nonatomic) IBOutlet UIView *nudgeQuestionView;
@property (weak, nonatomic) IBOutlet UILabel *nudgeCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
@implementation BLTNudgeViewController{
    NSMutableArray *friendsArray;
    DataClass *obj;
}



-(void) viewDidLoad {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    friendsArray = [[NSMutableArray alloc] initWithCapacity:3];
    friendsArray = [PFUser currentUser][@"friends"];
    [self getFriends];
    self.nudgeCountLabel.layer.cornerRadius = 10;
    self.questionLabel.layer.cornerRadius =10;
    self.questionLabel.layer.masksToBounds = NO;
    self.nudgeCountLabel.layer.masksToBounds = NO;

    [self.tableView reloadData];

    
}
-(void) viewWillAppear:(BOOL)animated  {


}


- (void) getFriends {
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friends = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
                [dict setObject:friendObject[@"id"] forKey:@"fb_id"];
                [dict setObject:friendObject[@"name"] forKey:@"name"];
                [friends addObject:dict];
            }
            
            [friendsArray setArray:friends];
            [self.tableView reloadData];
            [[PFUser currentUser] setObject:friends forKey:@"friends"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                        [PFCloud callFunctionInBackground:@"loadNudgeData" withParameters:@{@"dealID":obj.dealID} block:^(id object, NSError *error) {
                            
                        }];
                    
                    
                
                
                
                }
                else{
                    NSLog(@"%@",error);
                
                }
            }];
            NSLog(@"Got friends");
        }
    }];
}

-(void) viewDidAppear:(BOOL)animated{

    [self getFriends];



}




#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [friendsArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nudgeCell" forIndexPath:indexPath];
    if(cell == nil){
        return cell;
    }
    UILabel *friendName = (UILabel *) [cell viewWithTag:6];
    UIImageView *friendPic = (UIImageView *) [cell viewWithTag:5];
    friendName.text = [friendsArray objectAtIndex:indexPath.row][@"name"];
    NSString *fb_id = [friendsArray objectAtIndex:indexPath.row][@"fb_id"];
    [friendPic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    friendPic.contentMode = UIViewContentModeScaleAspectFill;
    [friendPic setFrame:CGRectMake(16, 10, 39, 39)];
    friendPic.layer.cornerRadius = 18;
    friendPic.clipsToBounds = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *fb_id = [friendsArray objectAtIndex:indexPath.row];
    [PFCloud callFunctionInBackground:@"newNudge" withParameters:@{@"receipient":fb_id} block:^(id object, NSError *error) {
        NSLog(@"%@", object);
    }];
    

}



@end
