//
//  BLTSelectUnivViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 4/25/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTSelectUnivViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"

@interface BLTSelectUnivViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arr;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation BLTSelectUnivViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.nextButton.enabled = NO;
    if([[PFUser currentUser][@"is_student"] isEqualToNumber:[NSNumber numberWithBool:YES]]){
        self.headerLabel.text = @"Where do you go to school?";
    }
    else{
        self.headerLabel.text = @"Where did you go to school?";
    }
    self.arr = [[NSMutableArray alloc] initWithCapacity:5];
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            self.arr = config[@"universities"];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"%@",error);
        }
    }];
    // Do any additional setup after loading the view.
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
//    cell.layer.borderWidth = 2.0;
//    cell.layer.borderColor = [UIColor colorWithRed:0.239 green:0.294 blue:0.288 alpha:1].CGColor;
   // [cell setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lbl = (UILabel *)[cell viewWithTag:1];
    lbl.text = [self.arr[indexPath.section] uppercaseString];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    [[PFUser currentUser] setObject:self.arr[indexPath.section] forKey:@"university_name"];
    self.nextButton.enabled = YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10; // you can have your own choice, of course
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
- (IBAction)nextButtonPressed:(id)sender {
    if([[PFUser currentUser][@"is_student"] isEqualToNumber:[NSNumber numberWithBool:YES]]){
        [self performSegueWithIdentifier:@"toAffiliation" sender:self];
        
    }
    else{
        [self performSegueWithIdentifier:@"toDays" sender:self];
    }
    
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
