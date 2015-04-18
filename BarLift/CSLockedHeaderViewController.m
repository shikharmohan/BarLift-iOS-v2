#import "CSLockedHeaderViewController.h"
#import "DealCell.h"
#import "DealHeader.h"
#import "CSStickyHeaderFlowLayout.h"
#import "LocationCell.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BLTDealDetailViewController.h"

@interface CSLockedHeaderViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSMutableDictionary *dates;
@property (nonatomic, strong) NSArray *sortedKeys;
@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViews;
@property (weak, nonatomic) IBOutlet UIButton *sideBarButton;

@end

@implementation CSLockedHeaderViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.headerNib = [UINib nibWithNibName:@"CSSearchBarHeader" bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    
    self.sections =  [[NSMutableDictionary alloc]initWithCapacity:10];
    self.dates = [[NSMutableDictionary alloc]initWithCapacity:10];

    CSStickyHeaderFlowLayout *layout = (id)self.collectionViewLayout;
//    self.sunnyRefreshControl = [YALSunnyRefreshControl attachToScrollView:self.collectionViews
//                                                                   target:self
//                                                            refreshAction:@selector(test)];

    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 0);
        layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height);
        
        // Setting the minimum size equal to the reference size results
        // in disabled parallax effect and pushes up while scrolls
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, 0);
    }
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(test)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];

    
    // Also insets the scroll indicator so it appears below the search bar
    [self setProfilePicture];
    self.collectionView.alwaysBounceVertical = YES;
    [self refreshAllDeals];
    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];
}

-(void) viewWillAppear:(BOOL)animated  {
  //  self.navigationController.navigationBarHidden = NO;
   // self.navigationController.navigationBar.alpha = 1;

}

-(void)test{
    NSLog(@"Hey");
   // [self.sections removeAllObjects];
   // [self.dates removeAllObjects];
    if([self.segmentControl selectedSegmentIndex] == 0){
        [self refreshAllDeals];
    }
    else{
        [self refreshMyDeals];
    }
    [self.refreshControl endRefreshing];

}

-(void) showOptions{

    [self performSegueWithIdentifier:@"toOptions" sender:self];
    
}

-(void) setProfilePicture{
    UIImageView *pic = [[UIImageView alloc] init];
    NSString *fb_id = [PFUser currentUser][@"fb_id"];
    [pic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    pic.contentMode = UIViewContentModeScaleAspectFill;
    pic.contentMode = UIViewContentModeScaleAspectFill;
    [pic setFrame:CGRectMake(29, 10, 33, 33)];
    pic.layer.cornerRadius = pic.frame.size.width/2;
    pic.layer.borderWidth = 2.0;
    pic.layer.borderColor = [UIColor whiteColor].CGColor;

    pic.clipsToBounds = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(showOptions)];
    [singleTap setNumberOfTapsRequired:1];
    pic.userInteractionEnabled = YES;
    [pic addGestureRecognizer:singleTap];
    UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithCustomView:pic];
    
    [self.navigationItem setLeftBarButtonItem:imageButton];

}

-(void)refreshMyDeals{
    self.sections =  [[NSMutableDictionary alloc]initWithCapacity:10];
    self.dates = [[NSMutableDictionary alloc]initWithCapacity:6];
    self.sortedKeys = [[NSMutableArray alloc] initWithCapacity:6];
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error1) {
        if(!error1){
            PFRelation *relation = [object relationForKey:@"deal_list"];
            PFQuery *query = [relation query];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error){
                    for(int i =0; i < [objects count]; i++){
                        PFRelation *relation2 = [objects[i] relationForKey:@"social"];
                        PFQuery *query2 = [relation2 query];
                        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error) {
                            if(!error){
                                [objects[i] addObject:objs forKey:@"whosGoing"];
                                NSDate *dealDate = objects[i][@"deal_start_date"];
                                NSCalendar *cal = [NSCalendar currentCalendar];
                                NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
                                NSDate *today = [cal dateFromComponents:components];
                                NSDateComponents *components1 = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:dealDate];
                                NSDate *otherDate = [cal dateFromComponents:components1];
                                
                                NSString *key = @"";
                                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                NSDateComponents *comp = [cal components:NSWeekdayCalendarUnit fromDate:dealDate];
                                NSInteger dayNum = [comp weekday]-1;
                                NSString *day = [df weekdaySymbols][dayNum];
                                NSString *dt = [NSString stringWithFormat:@"%ld",(long)[components1 day]];
                                NSString *monthName = [[df monthSymbols] objectAtIndex:([components1 month]-1)];
                                NSString *year = [NSString stringWithFormat:@"%ld",  (long)[components1 year]];
                                NSString *name = [NSString stringWithFormat:@"%@, %@ %@, %@", day, monthName, dt, year];
                                key = [NSString stringWithFormat:@"%ld%ld%ld", (long)[components1 month], (long)[components1 day], (long)[components1 year]];
                                NSLog(@"%@", key);
                                if([self.sections valueForKey:key] != nil) {
                                    // The key existed...
                                    [[self.sections valueForKey:key] addObject:objects[i]];
                                }
                                else {
                                    NSMutableArray *arr = [NSMutableArray arrayWithObjects:objects[i], nil];
                                    [self.sections setValue:arr forKey:key];
                                }
                                if(![self.dates objectForKey:key]){
                                    NSString *name = [NSString stringWithFormat:@"%@, %@ %@, %@", day, monthName, dt, year];
                                    if([today isEqualToDate:otherDate]){
                                        name = @"Today";
                                    }
                                    [self.dates setValue:name forKey:key];
                                }
                                if(i == [objects count]-1){
                                    NSLog(@"%@", self.sections);
                                    self.sortedKeys = [[self.dates allKeys] sortedArrayUsingSelector:@selector(compare:)];
                                    //if([[self.sections allKeys] count] > 0 && [[self.dates allKeys] count] > 0){
                                    [self.collectionView reloadData];
                                }
                                
                            }
                        }];
                    }
                    //}
                }
                else{
                    NSLog(@"%@", error);
                }
            }];
        }
        else{
            NSLog(@"%@", error1);
        }
    }];
}

-(void)refreshAllDeals{
    self.sections =  [[NSMutableDictionary alloc]initWithCapacity:10];
    PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
    NSDate *date = [NSDate date];
    [query whereKey:@"deal_end_date" greaterThanOrEqualTo:date];
    [query whereKey:@"community_name" equalTo:@"Dev"];
    [query orderByAscending:@"deal_start_date"];
    [query orderByDescending:@"main"];
    [query includeKey:@"user"];
    [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(int i =0; i < [objects count]; i++){
                PFRelation *relation2 = [objects[i] relationForKey:@"social"];
                PFQuery *query2 = [relation2 query];
                [query2 findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *err) {
                    if(!err){
                        [objects[i] addObject:objs forKey:@"whosGoing"];
                        NSDate *dealDate = objects[i][@"deal_start_date"];
                        NSCalendar *cal = [NSCalendar currentCalendar];
                        NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
                        NSDate *today = [cal dateFromComponents:components];
                        NSDateComponents *components1 = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:dealDate];
                        NSDate *otherDate = [cal dateFromComponents:components1];
                        
                        NSString *key = @"";
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        NSDateComponents *comp = [cal components:NSWeekdayCalendarUnit fromDate:dealDate];
                        NSInteger dayNum = [comp weekday]-1;
                        NSString *day = [df weekdaySymbols][dayNum];
                        NSString *dt = [NSString stringWithFormat:@"%ld",(long)[components1 day]];
                        NSString *monthName = [[df monthSymbols] objectAtIndex:([components1 month]-1)];
                        NSString *year = [NSString stringWithFormat:@"%ld",  (long)[components1 year]];
                        NSString *name = [NSString stringWithFormat:@"%@, %@ %@, %@", day, monthName, dt, year];
                        key = [NSString stringWithFormat:@"%ld%ld%ld", (long)[components1 month], (long)[components1 day], (long)[components1 year]];
                        NSLog(@"%@", key);
                        if([self.sections valueForKey:key] != nil) {
                            // The key existed...
                            [[self.sections valueForKey:key] addObject:objects[i]];
                        }
                        else {
                            NSMutableArray *arr = [NSMutableArray arrayWithObjects:objects[i], nil];
                            [self.sections setValue:arr forKey:key];
                        }
                        if(![self.dates objectForKey:key]){
                            NSString *name = [NSString stringWithFormat:@"%@, %@ %@, %@", day, monthName, dt, year];
                            if([today isEqualToDate:otherDate]){
                                name = @"Today";
                            }
                            [self.dates setValue:name forKey:key];
                        }
                        NSLog(@"%@", self.sections);
                        self.sortedKeys = [[self.dates allKeys] sortedArrayUsingSelector:@selector(compare:)];
                        //if([[self.sections allKeys] count] > 0 && [[self.dates allKeys] count] > 0){
                        [self.collectionView reloadData];

                    }
                    else{
                        NSLog(@"%@", err);
                    }
                }];
            }

        }
        else{
            NSLog(@"%@", error);
        }
    }];
    
}
#pragma mark Segment Control

- (IBAction)segmentChanged:(id)sender {
    if([sender selectedSegmentIndex] == 0){
        [self refreshAllDeals];
    }
    else{
        [self refreshMyDeals];
    }
    
    
}



#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.sortedKeys count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.sections objectForKey:[self.sortedKeys objectAtIndex:section]] count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *obj = [self.sortedKeys objectAtIndex:indexPath.section];
    DealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mainDealCell"
                                                             forIndexPath:indexPath];
    if([self.sections objectForKey:obj] != nil){
        NSString *text = [[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"name"];
        
        cell.dealName.text = [text stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DealHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"sectionHeader"
                                                                 forIndexPath:indexPath];
        
        cell.textLabel.text = [self.dates objectForKey:[self.sortedKeys objectAtIndex:indexPath.section]] ;
        cell.numDeals.text = [NSString stringWithFormat:@"%d",[[self.sections objectForKey:[self.sortedKeys objectAtIndex:indexPath.section]] count]];
        
        return cell;
    } else if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        LocationCell *lcell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                   forIndexPath:indexPath];
        
        
        return lcell;
    }
    return nil;
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"toDealDetail"]){
        BLTDealDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
        NSString *obj = [self.sortedKeys objectAtIndex:indexPath.section];
        NSString *dealID = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row] objectId];
        [vc setDealID:dealID];
    }
}

#pragma mark ScrollView Delegates



@end
