#import "BLTDealDashboard.h"
#import "DealCell.h"
#import "DealHeader.h"
#import "CSStickyHeaderFlowLayout.h"
#import "LocationCell.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BLTDealDetailViewController.h"
#import "BBBadgeBarButtonItem.h"


@interface BLTDealDashboard ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSMutableDictionary *dates;
@property (nonatomic, strong) NSArray *sortedKeys;
@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViews;
@property (weak, nonatomic) IBOutlet UIButton *sideBarButton;
typedef void(^myCompletion)(BOOL);
@end

@implementation BLTDealDashboard
@synthesize reloadCell;

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
    self.dates = [[NSMutableDictionary alloc]initWithCapacity:7];

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
    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];
    [self refreshAllDeals:^(BOOL finished) {
        if(finished){
            [self.collectionView reloadData];
        }
    }];
    
    
}

-(void) viewWillAppear:(BOOL)animated  {
  //  self.navigationController.navigationBarHidden = NO;
   // self.navigationController.navigationBar.alpha = 1;
    [self setProfilePicture];
}


-(void) refreshAllDeals:(myCompletion) compblock{
    self.sections =  [[NSMutableDictionary alloc]initWithCapacity:10];
    PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
    NSDate *date = [NSDate date];
    [query whereKey:@"deal_end_date" greaterThanOrEqualTo:date];
    [query whereKey:@"community_name" equalTo:@"Dev"];
    [query orderByAscending:@"deal_start_date"];
    [query orderByDescending:@"main"];
    [query includeKey:@"user"];
    [query includeKey:@"venue"];
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
                        // NSString *year = [NSString stringWithFormat:@"%ld",  (long)[components1 year]];
                        //    NSString *name = [NSString stringWithFormat:@"%@, %@ %@", day, monthName, dt];
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
                            NSString *name = [NSString stringWithFormat:@"%@, %@ %@", day, monthName, dt];
                            if([today isEqualToDate:otherDate]){
                                name = @"Today";
                            }
                            [self.dates setValue:name forKey:key];
                        }
                        NSLog(@"%@", self.sections);
                        self.sortedKeys = [[self.dates allKeys] sortedArrayUsingSelector:@selector(compare:)];
                        //if([[self.sections allKeys] count] > 0 && [[self.dates allKeys] count] > 0){
                        
                        //  if(i == [objects count]-1){
                        NSSortDescriptor *Sorter = [[NSSortDescriptor alloc] initWithKey:@"main" ascending:NO];
                        for(int j = 0; j < [self.sortedKeys count]; j++){
                            [[self.sections objectForKey:self.sortedKeys[j]] sortUsingDescriptors:[NSArray arrayWithObject:Sorter]];
                        }
                        //    }
                        
                        compblock(YES);

                        //[self reloadList];
                        
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
    [self performSelector:@selector(reloadList) withObject:nil afterDelay:3.0f];
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
    [pic setFrame:CGRectMake(0, 0, 29, 29)];
    pic.layer.cornerRadius = pic.frame.size.width/2;
    pic.layer.borderWidth = 2.0;
    pic.layer.borderColor = [UIColor whiteColor].CGColor;

    pic.clipsToBounds = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(showOptions)];
    [singleTap setNumberOfTapsRequired:1];
    pic.userInteractionEnabled = YES;
    UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithCustomView:pic];
    
    UIButton *logoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    [logoBtn setImage:[UIImage imageNamed:@"bltlogo.png"] forState:UIControlStateNormal];
    BBBadgeBarButtonItem *barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:logoBtn];
    [logoBtn addGestureRecognizer:singleTap];

    // Set a value for the badge
    NSString *badge;
    if([PFInstallation currentInstallation].badge != 0){
        badge = [NSString stringWithFormat:@"%ld", (long)[PFInstallation currentInstallation].badge];
    }
    else{
        badge =@"0";
    }
    barButton.badgeValue = badge;
    barButton.badgeOriginX = 22;
    barButton.badgeOriginY = -5;
    // Add it as the leftBarButtonItem of the navigation bar
    
    [self.navigationItem setLeftBarButtonItem:barButton animated:YES];
    [self.navigationItem setRightBarButtonItem:imageButton animated:YES];

}

-(void)refreshMyDeals{
    self.sections =  [[NSMutableDictionary alloc]initWithCapacity:3];
    self.dates = [[NSMutableDictionary alloc]initWithCapacity:7];
    self.sortedKeys = [[NSMutableArray alloc]initWithCapacity:7];
    if([[PFUser currentUser] isDataAvailable]){
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error1) {
            if(!error1){
                PFRelation *relation = [object relationForKey:@"deal_list"];
                PFQuery *query = [relation query];
                [query includeKey:@"venue"];
                [query orderByDescending:@"main"];
                [query whereKey:@"deal_end_date" greaterThan:[NSDate date]];
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
                                        NSString *name = [NSString stringWithFormat:@"%@, %@ %@", day, monthName, dt];
                                        if([today isEqualToDate:otherDate]){
                                            name = @"Today";
                                        }
                                        [self.dates setValue:name forKey:key];
                                    }
                                        NSLog(@"%@", self.sections);
                                        self.sortedKeys = [[self.dates allKeys] sortedArrayUsingSelector:@selector(compare:)];
                                    NSSortDescriptor *Sorter = [[NSSortDescriptor alloc] initWithKey:@"main" ascending:NO];
                                    for(int j = 0; j < [self.sortedKeys count]; j++){
                                        [[self.sections objectForKey:self.sortedKeys[j]] sortUsingDescriptors:[NSArray arrayWithObject:Sorter]];
                                    }
                                    [self reloadList];

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
    else{
        PFRelation *relation = [[PFUser currentUser] relationForKey:@"deal_list"];
        PFQuery *query = [relation query];
        [query orderByDescending:@"main"];
        [query includeKey:@"venue"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                for(int i =0; i < [objects count]; i++){
                    PFRelation *relation2 = [objects[i] relationForKey:@"social"];
                    PFQuery *query2 = [relation2 query];
                    [query2 whereKey:@"deal_end_date" greaterThan:[NSDate date]];
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
                           // NSString *year = [NSString stringWithFormat:@"%ld",  (long)[components1 year]];
                        //    NSString *name = [NSString stringWithFormat:@"%@, %@ %@", day, monthName, dt];
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
                                NSString *name = [NSString stringWithFormat:@"%@, %@ %@", day, monthName, dt];
                                if([today isEqualToDate:otherDate]){
                                    name = @"Today";
                                }
                                [self.dates setValue:name forKey:key];
                            }
                                NSLog(@"%@", self.sections);
                                self.sortedKeys = [[self.dates allKeys] sortedArrayUsingSelector:@selector(compare:)];
                                NSSortDescriptor *Sorter = [[NSSortDescriptor alloc] initWithKey:@"main" ascending:NO];
                                for(int j = 0; j < [self.sortedKeys count]; j++){
                                    [[self.sections objectForKey:self.sortedKeys[j]] sortUsingDescriptors:[NSArray arrayWithObject:Sorter]];
                                }
                            [self reloadList];

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
    [query includeKey:@"venue"];
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
                       // NSString *year = [NSString stringWithFormat:@"%ld",  (long)[components1 year]];
                    //    NSString *name = [NSString stringWithFormat:@"%@, %@ %@", day, monthName, dt];
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
                            NSString *name = [NSString stringWithFormat:@"%@, %@ %@", day, monthName, dt];
                            if([today isEqualToDate:otherDate]){
                                name = @"Today";
                            }
                            [self.dates setValue:name forKey:key];
                        }
                        NSLog(@"%@", self.sections);
                        self.sortedKeys = [[self.dates allKeys] sortedArrayUsingSelector:@selector(compare:)];
                        //if([[self.sections allKeys] count] > 0 && [[self.dates allKeys] count] > 0){
                        
                      //  if(i == [objects count]-1){
                            NSSortDescriptor *Sorter = [[NSSortDescriptor alloc] initWithKey:@"main" ascending:NO];
                            for(int j = 0; j < [self.sortedKeys count]; j++){
                                [[self.sections objectForKey:self.sortedKeys[j]] sortUsingDescriptors:[NSArray arrayWithObject:Sorter]];
                            }
                    //    }
                        [self reloadList];

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

-(void)reloadList {

    [UIView performWithoutAnimation:^{
        [self.collectionView reloadData];
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
    DealCell *cell = nil;
    if(cell == nil){
    if([[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"main"] isEqualToNumber:@1]){
         cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mainDealCell"
                                                                   forIndexPath:indexPath];
        UILabel *moreDeals = (UILabel *)[cell viewWithTag:6];
        if([[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"add_deals"] count] > 0){
            moreDeals.text = [NSString stringWithFormat:@"+%lu more deals",(unsigned long)[[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"add_deals"] count]];
        }
        //set deal label + location
        UILabel *location = (UILabel *)[cell viewWithTag:5];
        location.text = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"venue"][@"bar_name"] uppercaseString];
        
        //set background image
        UIImageView *background = (UIImageView *)[cell viewWithTag:10];
        NSString *img_url =[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"image_url"];
        
    
        [background sd_setImageWithURL:[NSURL URLWithString:img_url]];

        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = background.frame;
        
        // Add colors to layer
        UIColor *centerColor = [UIColor clearColor];
        UIColor *endColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.88];
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[endColor CGColor],
                           (id)[centerColor CGColor],
                           (id)[centerColor CGColor],
                           nil];
        
        [background.layer insertSublayer:gradient atIndex:0];

        
        NSArray *whosGoing = [[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"whosGoing"];
        NSInteger int_count = [[whosGoing objectAtIndex:0] count];
        UIImageView *img = (UIImageView *)[cell viewWithTag:30];
        BOOL interested = NO;
        for(int i =0; i< int_count; i++){
            if([whosGoing[0][i][@"fb_id"] isEqualToString:[PFUser currentUser][@"fb_id"] ]){
                interested = YES;
                break;
            }
        }
        if(interested){
            cell.image.hidden = NO;
            [cell.image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [PFUser currentUser][@"fb_id"]]]];
            cell.image.contentMode = UIViewContentModeScaleAspectFill;
            cell.image.layer.cornerRadius = img.frame.size.width/2;
            cell.image.layer.borderWidth = 2.0;
            cell.image.layer.borderColor = [UIColor greenColor].CGColor;
            cell.image.clipsToBounds = YES;
        }
        else{
            cell.image.hidden = YES;
        }
        if(int_count > 0){
            cell.goingLabel.hidden = NO;
            cell.goingLabel.text = [NSString stringWithFormat:@"+%ld", (long)int_count];
            cell.goingLabel.layer.cornerRadius = cell.goingLabel.frame.size.width/2;
            cell.goingLabel.layer.borderWidth = 2.0;
            cell.goingLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        else{
            cell.goingLabel.hidden = YES;
        
        }
    }
    else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dealCell"
                                                                   forIndexPath:indexPath];
        UILabel *moreDeals = (UILabel *)[cell viewWithTag:46];
        if([[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"add_deals"] count] > 0){
            moreDeals.text = [NSString stringWithFormat:@"+%lu more deals",(unsigned long)[[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"add_deals"] count]];
        }
        //set deal label + location
        UILabel *location = (UILabel *)[cell viewWithTag:45];
        location.text = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"venue"][@"bar_name"] uppercaseString];
        
        //interested
        NSArray *whosGoing = [[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"whosGoing"];
        NSInteger int_count = [[whosGoing objectAtIndex:0] count];
        BOOL interested = NO;
        for(int i =0; i< int_count; i++){
            if([whosGoing[0][i][@"fb_id"] isEqualToString:[PFUser currentUser][@"fb_id"] ]){
                interested = YES;
                break;
            }
        }
        if(interested){
            cell.img.hidden = NO;
            [cell.img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [PFUser currentUser][@"fb_id"]]]];
            cell.img.contentMode = UIViewContentModeScaleAspectFill;
            cell.img.layer.cornerRadius = cell.img.frame.size.width/2;
            cell.img.layer.borderWidth = 2.0;
            cell.img.layer.borderColor = [UIColor greenColor].CGColor;
            cell.img.clipsToBounds = YES;
        }
        else{
            cell.image.hidden = YES;
        }
        if(int_count > 0){
            cell.goingLbl.hidden = NO;
            cell.goingLbl.text = [NSString stringWithFormat:@"+%ld", (long)int_count];
            cell.goingLbl.layer.cornerRadius = cell.goingLbl.frame.size.width/2;
            cell.goingLbl.layer.borderWidth = 2.0;
            cell.goingLbl.layer.borderColor = [UIColor blackColor].CGColor;
        }
        else{
            cell.goingLbl.hidden = YES;
        }
        
    }
    if([self.sections objectForKey:obj] != nil){
        NSString *text = [[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"name"];
        
        cell.dealName.text = [text stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DealHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                        withReuseIdentifier:@"sectionHeader"
                                                                 forIndexPath:indexPath];
        
        cell.textLabel.text = [self.dates objectForKey:[self.sortedKeys objectAtIndex:indexPath.section]] ;
        cell.numDeals.text = [NSString stringWithFormat:@"%lu",(unsigned long)[[self.sections objectForKey:[self.sortedKeys objectAtIndex:indexPath.section]] count]];
        
        return cell;
    } else if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        LocationCell *lcell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                   forIndexPath:indexPath];
        
        
        return lcell;
    }
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *obj = [self.sortedKeys objectAtIndex:indexPath.section];
    
    if([[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"main"] isEqualToNumber:@1]){
        return CGSizeMake(320, 220);
    }
    else{
        return CGSizeMake(320, 125);
        
    }

}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"toDealDetail"]){
        BLTDealDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
        NSString *obj = [self.sortedKeys objectAtIndex:indexPath.section];
        NSString *dealID = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row] objectId];
        self.reloadCell = indexPath;
        [vc setDealID:dealID];
    }
}

#pragma mark ScrollView Delegates




@end
