//
//  BLTDealTypeViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/27/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTDealTypeViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BLTButton.h"
#import "Mixpanel.h"

@interface BLTDealTypeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *arr;
@property (strong, nonatomic) NSMutableArray *selectedCells;
@property (strong, nonatomic) NSMutableArray *selectedDeals;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet BLTButton *nextButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation BLTDealTypeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.nextButton.enabled = NO;
    self.arr = [[NSMutableArray alloc] initWithCapacity:10];
    self.selectedCells = [[NSMutableArray alloc] initWithCapacity:3];
    self.selectedDeals = [[NSMutableArray alloc] initWithCapacity:3];
    self.tableView.allowsMultipleSelection = YES;
    self.arr = [PFConfig currentConfig][@"deal_types"];
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if(!error){
            self.arr = config[@"deal_types"];
            [self.tableView reloadData];
        }
        
    }];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - Table View Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.cornerRadius = 16;
    UILabel *lbl = (UILabel *)[cell viewWithTag:1];
    lbl.text = [self.arr[indexPath.section] uppercaseString];
    if([self.selectedCells containsObject:indexPath]){
        [cell setBackgroundColor:[UIColor whiteColor]];
        UIView *bg_selected = [[UIView alloc] initWithFrame:cell.bounds];
        bg_selected.layer.cornerRadius = 16;
        [bg_selected setBackgroundColor:[UIColor colorWithRed:0.1803 green:0.8 blue:0.443 alpha:1]];
        cell.backgroundView = bg_selected;
    }
    else{
        [cell setBackgroundColor:[UIColor whiteColor]];
        UIView *bg_selected = [[UIView alloc] initWithFrame:cell.bounds];
        bg_selected.layer.cornerRadius = 16;
        [bg_selected setBackgroundColor:[UIColor whiteColor]];
        
        cell.backgroundView = bg_selected;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor yellowColor];
    
    if ([self.selectedCells containsObject:indexPath])
    {
        [self.selectedCells removeObject:indexPath];
        [self.selectedDeals removeObject:self.arr[indexPath.section]];
    }
    else
    {
        [self.selectedCells addObject:indexPath];
        [self.selectedDeals addObject:self.arr[indexPath.section]];
        
    }
    if([self.selectedCells count] > 0){
        self.nextButton.enabled = YES;
    }
    [self.tableView reloadData];
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor whiteColor]];
    UIView *bg_selected = [[UIView alloc] initWithFrame:cell.bounds];
    bg_selected.layer.cornerRadius = 16;
    [bg_selected setBackgroundColor:[UIColor colorWithRed:0.1803 green:0.8 blue:0.443 alpha:1]];
    cell.selectedBackgroundView = bg_selected;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (IBAction)finishButtonPressed:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Finished sign up" properties:@{
                                                  @"Fb_id": [PFUser currentUser][@"fb_id"],
                                                  @"University":[PFUser currentUser][@"university_name"],
                                                  @"is_student":[PFUser currentUser][@"is_student"]
                                                  }];

    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication]  registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication]  registerForRemoteNotifications];
    
    [[PFUser currentUser] setObject:self.selectedDeals forKey:@"deal_types"];
    [PFUser currentUser][@"newVersion"] = [NSNumber numberWithBool:YES];
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self.indicator stopAnimating];
            self.indicator.hidden = YES;
            [self performSegueWithIdentifier:@"toDealFeed" sender:self];
        }
    }];
}


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
