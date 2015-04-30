//
//  BLTDaysOutViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/25/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTDaysOutViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"

@interface BLTDaysOutViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, strong) NSMutableArray *selectedCells;
@property (nonatomic, strong) NSMutableArray *selectedDays;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation BLTDaysOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.nextButton.enabled = NO;
    self.arr = @[@"M", @"TU", @"W", @"TH", @"F", @"SAT", @"SUN"];
    self.selectedCells = [[NSMutableArray alloc] initWithCapacity:3];
    self.selectedDays = [[NSMutableArray alloc] initWithCapacity:3];
    self.tableView.allowsMultipleSelection = YES;
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[PFUser currentUser] setObject:self.selectedDays forKey:@"selected_days"];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:self.selectedDays forKey:@"days_out"];
    [currentInstallation saveEventually];
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
        [self.selectedDays removeObject:self.arr[indexPath.section]];
        [cell setBackgroundColor:[UIColor whiteColor]];
        UIView *bg_selected = [[UIView alloc] initWithFrame:cell.bounds];
        bg_selected.layer.cornerRadius = 16;
        [bg_selected setBackgroundColor:[UIColor whiteColor]];

        cell.backgroundView = bg_selected;
    }
    else
    {
        [self.selectedCells addObject:indexPath];
        [self.selectedDays addObject:self.arr[indexPath.section]];
        [cell setBackgroundColor:[UIColor whiteColor]];
        UIView *bg_selected = [[UIView alloc] initWithFrame:cell.bounds];
        bg_selected.layer.cornerRadius = 16;
        [bg_selected setBackgroundColor:[UIColor colorWithRed:0.1803 green:0.8 blue:0.443 alpha:1]];
        cell.backgroundView = bg_selected;

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



- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
