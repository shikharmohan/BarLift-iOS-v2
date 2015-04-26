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

@interface BLTFriendListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *friendsList;
@property (nonatomic, strong) NSMutableArray *sections;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *alphabet;
@property (strong, nonatomic) NSString* fb;
@end

@implementation BLTFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.alphabet = @[@"A", @"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
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
            [self convertArray];
            [self.tableView reloadData];
        }
    }];
}

- (void)convertArray
{
    //NSMutableArray *exhibitorArray = [[NSMutableArray alloc] initWithArray:@[@"abra", @"Catabra"]];
    
    NSArray *data = [self.friendsList copy];
    self.sections = [[NSMutableArray alloc] initWithCapacity:27];
    // 27 elements, 26 for A-Z plus one for '#'
    for (int i=0; i<27; i++)
        [self.sections addObject:[[NSMutableArray alloc] init]];
    
    int firstAsciiPos = (int)[@"A" characterAtIndex:0];
    for (int i=0; i<[data count]; i++)
    {
        int index = (int)[[[data objectAtIndex:i][@"name"] uppercaseString] characterAtIndex:0] - firstAsciiPos;
        if (index < 0 || index > 25)
        {
            // it is not between A and Z, add it to '#'
            index = 26;
        }
        [[self.sections objectAtIndex:index] addObject:[data objectAtIndex:i]];
    }
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
    return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([[self.sections objectAtIndex:section] count] == 0){
        return nil;
    }
    return [self.alphabet objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.sections objectAtIndex:section] count];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.alphabet;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"frCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(cell == nil){
        return cell;
    }
    UILabel *friendName = (UILabel *) [cell viewWithTag:20];
    UIImageView *friendPic = (UIImageView *) [cell viewWithTag:21];
    friendName.text = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row][@"name"];
    NSString *fb_id = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row][@"fb_id"];
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
    [vc setFb_id:[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row][@"fb_id"]];

    
    
}


@end
