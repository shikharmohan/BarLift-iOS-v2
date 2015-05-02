//
//  NudgeHistoryViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/18/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "NudgeHistoryViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BLTProfileViewController.h"
#import "BLTDealDetailViewController.h"
#import "SCLAlertView.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)



@interface NudgeHistoryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *dictionary;
@property (strong, nonatomic) NSMutableArray *array;
@end

@implementation NudgeHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.array = [[NSMutableArray alloc] initWithCapacity:15];
    [PFCloud callFunctionInBackground:@"getMyNudges" withParameters:@{} block:^(id object, NSError *error) {
        if(!error){
            NSLog(@"%@", object);
            for(int i = 0; i < [object count]; i++){
                NSString *obj_id = [[[object objectAtIndex:i] objectForKey:@"deal"] objectId];
                if(obj_id != nil){
                    self.dictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
                    [self.dictionary setObject:object[i][@"from_user"][@"fb_id"] forKey:@"sender"];
                    [self.dictionary setObject:obj_id forKey:@"dealID"];
                    if(object[i][@"text"] != nil){
                        [self.dictionary setObject:object[i][@"text"] forKey:@"msg"];
                    }
                    else{
                        [self.dictionary setObject:@"" forKey:@"msg"];
                    }
                    [self.array addObject:self.dictionary];
                }
            }
            [self.tableView reloadData];
        }
    }];
    PFInstallation *inst = [PFInstallation currentInstallation];
    if(inst.badge !=0) {
        inst.badge = 0;
        [PFCloud callFunctionInBackground:@"resetMyBadge" withParameters:@{} block:^(id object, NSError *error) {
            if(!error){
                NSLog(@"Reset Badge");
            }
            else{
                NSLog(@"Did not reset");
            }
        }];
        [inst saveEventually];
    }
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        UIUserNotificationType type = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
        if (type == UIUserNotificationTypeNone){
            [alert showInfo:self title:@"Push Notifications Off" subTitle:@"Hey there, we noticed that you currently have push off for BarLift. If you want to know about nudges sooner, turn on push notifications in your phone settings." closeButtonTitle:@"Ok, got it!" duration:0.0f]; // Info
        }
    }
    else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types == UIRemoteNotificationTypeNone) {
            [alert showInfo:self title:@"Push Notifications Off" subTitle:@"Hey there, we noticed that you currently have push off for BarLift. If you want to know about nudges sooner, turn on push notifications in your phone settings." closeButtonTitle:@"Ok, got it!" duration:0.0f]; // Info
        }
    }
    
}

-(void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.array count];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nudgeCell" forIndexPath:indexPath];
    UILabel *text = (UILabel *)[cell viewWithTag:15];
    text.text = [self.array objectAtIndex:indexPath.row][@"msg"];
    UIImageView *friendPic = (UIImageView *)[cell viewWithTag:16];
    NSString *fb_id = [self.array objectAtIndex:indexPath.row][@"sender"];
    [friendPic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    friendPic.contentMode = UIViewContentModeScaleAspectFill;
    friendPic.layer.cornerRadius = friendPic.frame.size.height/2;
    friendPic.clipsToBounds = YES;
    return cell;
}


#pragma mark - Navigation


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    BLTDealDetailViewController *vc = [segue destinationViewController];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    NSString *deal = [self.array objectAtIndex:path.row][@"dealID"];
    [vc setDealID:deal];

}

@end
