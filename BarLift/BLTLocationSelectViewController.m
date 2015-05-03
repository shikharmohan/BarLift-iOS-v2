//
//  BLTLocationSelectViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/26/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTLocationSelectViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BLTButton.h"

@interface BLTLocationSelectViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray* arr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *selectedCells;

@end

@implementation BLTLocationSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedCells = [[NSMutableArray alloc] initWithCapacity:1];
    self.arr = [[NSMutableArray alloc] initWithCapacity:1];
    [self.selectedCells addObject:[[PFUser currentUser][@"community_name"] uppercaseString]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        self.arr = config[@"communities"];
        [self.tableView reloadData];
    }];
    [self.tableView reloadData];
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
#pragma mark - Table View Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arr count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locCell" forIndexPath:indexPath];
    
    UILabel *lbl = (UILabel *)[cell viewWithTag:1];
    lbl.text = [self.arr[indexPath.row] uppercaseString];
    
    if ([self.selectedCells containsObject:[self.arr[indexPath.row] uppercaseString]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.selectedCells removeAllObjects];
    [self.selectedCells addObject:[self.arr[indexPath.row] uppercaseString]];
    [[PFUser currentUser] setObject:self.arr[indexPath.row] forKey:@"community_name"];
    [[PFUser currentUser] saveInBackground];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateUINotification" object: nil];
    [self.navigationController popViewControllerAnimated:YES];
}






@end
