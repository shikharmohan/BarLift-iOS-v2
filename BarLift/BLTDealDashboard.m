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

@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSMutableDictionary *dates;
@property (nonatomic, strong) NSArray *sortedKeys;
@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViews;
@property (weak, nonatomic) IBOutlet UIButton *sideBarButton;
@property (nonatomic, strong) NSString *weekday;
typedef void(^myCompletion)(BOOL);
@end

@implementation BLTDealDashboard{
    CGSize iOSScreenSize;
}
@synthesize reloadCell;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.headerNib = [UINib nibWithNibName:@"CSSearchBarHeader" bundle:nil];
    }
    return self;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],UITextAttributeTextColor,
      [UIFont fontWithName:@"Lato-Regular" size:18],
      NSFontAttributeName, nil]];
    
    [self.collectionView.viewForBaselineLayout.layer setSpeed:0.1f];
    iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    CSStickyHeaderFlowLayout *layout = (id)self.collectionViewLayout;

    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 0);
        layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height);
        
        // Setting the minimum size equal to the reference size results
        // in disabled parallax effect and pushes up while scrolls
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, 0);
    }
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadDeals)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];

    
    // Also insets the scroll indicator so it appears below the search bar
    [self setProfilePicture];
    [self refreshAllDeals];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];
    
}

-(void) reloadDeals{
    [self refreshAllDeals];
    [self.refreshControl endRefreshing];
}

-(void) viewWillAppear:(BOOL)animated  {
  //  self.navigationController.navigationBarHidden = NO;
   // self.navigationController.navigationBar.alpha = 1;
    [self setProfilePicture];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(refreshAllDeals) name: @"UpdateUINotification" object: nil];
}


-(void) refreshAllDeals{
    PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
    NSDate *date = [NSDate date];
    [query whereKey:@"deal_end_date" greaterThanOrEqualTo:date];
    [query whereKey:@"community_name" equalTo:[PFUser currentUser][@"community_name"]];
    [query orderByAscending:@"deal_start_date"];
    [query orderByDescending:@"main"];
    [query includeKey:@"user"];
    [query includeKey:@"venue"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.sections = [[NSMutableDictionary alloc] initWithCapacity:7];
            self.dates = [[NSMutableDictionary alloc] initWithCapacity:7];
            self.sortedKeys = [[NSMutableArray alloc] initWithCapacity:7];

            for(int i =0; i < [objects count]; i++){

                        NSDate *dealDate = objects[i][@"deal_start_date"];
                        NSCalendar *cal = [NSCalendar currentCalendar];
                        NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
                        NSDate *today = [cal dateFromComponents:components];
                        NSDateComponents *components1 = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:dealDate];
                        NSDate *otherDate = [cal dateFromComponents:components1];
                        NSString *key = @"";
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        NSDateComponents *comp = [cal components:NSCalendarUnitWeekday fromDate:dealDate];
                        NSInteger dayNum = [comp weekday]-1;
                        NSString *day = [df weekdaySymbols][dayNum];
                        NSString *dt = [NSString stringWithFormat:@"%ld",(long)[components1 day]];
                        NSString *monthName = [[df monthSymbols] objectAtIndex:([components1 month]-1)];
                        key = [NSString stringWithFormat:@"%ld%ld%ld", (long)[components1 month], (long)[components1 day], (long)[components1 year]];
                        NSLog(@"%@", key);
                        NSArray *whoGoing = [objects[i] objectForKey:@"whos_going"];
                        BOOL interested = NO;
                        for(int k = 0; k < [whoGoing count]; k++){
                            if([whoGoing[k] isEqualToString:[[PFUser currentUser] objectId]]){
                                interested = YES;
                                [objects[i] addObject:[NSNumber numberWithBool:interested] forKey:@"im_going"];
                                break;
                            }
                        }
                
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
                
                
            }
            self.sortedKeys = [[self.dates allKeys] sortedArrayUsingSelector:@selector(compare:)];
            NSSortDescriptor *Sorter = [[NSSortDescriptor alloc] initWithKey:@"main" ascending:NO];
            
//            for(int i = 0; i < [self.sortedKeys count]; i++){
//                NSArray *arr = [[NSSet setWithArray:[self.sections objectForKey:self.sortedKeys[i]]] allObjects];
//                [self.sections setObject:arr forKey:self.sortedKeys[i]];
//            }
            for(int j = 0; j < [self.sortedKeys count]; j++){
                [[self.sections objectForKey:self.sortedKeys[j]] sortUsingDescriptors:[NSArray arrayWithObject:Sorter]];
            }
            [self.collectionView reloadData];
        }
        else{
            NSLog(@"%@", error);
        }
    }];
}

-(void) showOptions{
    [self performSegueWithIdentifier:@"toOptions" sender:self];
}

-(void) setProfilePicture{
    UIImageView *pic = [[UIImageView alloc] init];
    NSString *fb_id = [PFUser currentUser][@"fb_id"];
    [pic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    pic.contentMode = UIViewContentModeScaleAspectFill;
    [pic setFrame:CGRectMake(0, 0, 0.075*iOSScreenSize.width,0.042253521*iOSScreenSize.height)];
    pic.layer.cornerRadius = pic.frame.size.width/2;
  //  pic.layer.borderWidth = 2.0;
   // pic.layer.borderColor = [UIColor whiteColor].CGColor;

    pic.clipsToBounds = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(showOptions)];
    [singleTap setNumberOfTapsRequired:1];
    pic.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(toProfile:)];

    UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithCustomView:pic];
    [pic addGestureRecognizer:tap];
    UIButton *logoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0.075*iOSScreenSize.width,0.042253521*iOSScreenSize.height)];
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
//    [imageButton setTarget:self];
//    [imageButton setAction:@selector(toProfile:)];

}

-(void) toProfile:(id) sender{
    [self performSegueWithIdentifier:@"toMyProfile" sender:self];
}



#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.sortedKeys count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.sections objectForKey:[self.sortedKeys objectAtIndex:section]] count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DealCell *cell = nil;
    if([self.sortedKeys count] > 0 && [self.sections count] > 0){
        NSString *obj = [self.sortedKeys objectAtIndex:indexPath.section];
        if(cell == nil){
            if([[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"main"] isEqualToNumber:@1]){
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mainDealCell"
                                                                 forIndexPath:indexPath];
                UILabel *moreDeals = (UILabel *)[cell viewWithTag:6];
                if([[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"add_deals"] count] > 0){
                    moreDeals.hidden = NO;
                    moreDeals.text = [NSString stringWithFormat:@"+%lu more deals",(unsigned long)[[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"add_deals"] count]];
                }
                else{
                    moreDeals.hidden = YES;
                }
                //set deal label + location
                UILabel *location = (UILabel *)[cell viewWithTag:5];
                location.text = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"venue"][@"bar_name"] uppercaseString];
                
                //set community
                UILabel *community = (UILabel *) [cell viewWithTag:37];
                [community setText:[[[self.sections objectForKey:obj] objectAtIndex:indexPath.row] objectForKey:@"community_name"]];
                
                //set background image
                UIImageView *background = (UIImageView *)[cell viewWithTag:10];
                NSString *img_url =[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"image_url"];
                
                
                [background sd_setImageWithURL:[NSURL URLWithString:img_url]];
            
                
                NSDictionary *dict = @{@"deal_objectId":[[[self.sections objectForKey:obj] objectAtIndex:indexPath.row] objectId], @"user_objectId":[[PFUser currentUser] objectId]};

                
                UIImageView *img = (UIImageView *)[cell viewWithTag:30];
                // img.image = nil;
                NSArray *going = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row] objectForKey:@"im_going"];
//                if([going[0] isEqualToNumber:[NSNumber numberWithBool:YES]]){
//                    cell.image.hidden = NO;
//                    [cell.image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [PFUser currentUser][@"fb_id"]]]];
//                    cell.image.contentMode = UIViewContentModeScaleAspectFill;
//                    cell.image.layer.cornerRadius = img.frame.size.width/2;
//                    cell.image.layer.borderWidth = 2.0;
//                    cell.image.layer.borderColor = [UIColor colorWithRed:0.1803 green:0.8 blue:0.443 alpha:1].CGColor;
//                    cell.image.clipsToBounds = YES;
//                }
//                else{
//                    // cell.image.hidden = YES;
//                    cell.image.image = nil;
//                    cell.image.layer.borderColor = [UIColor whiteColor].CGColor;
//                    
//                }
                
                NSNumber *int_count = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row] objectForKey:@"num_accepted"];
               
                if([int_count integerValue] > 0){
                    cell.goingLabel.hidden = NO;
                    cell.goingLabel.text = [NSString stringWithFormat:@"%@", int_count];
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
                //Set community name
                UILabel *community = (UILabel *) [cell viewWithTag:35];
                [community setText:[[[self.sections objectForKey:obj] objectAtIndex:indexPath.row] objectForKey:@"community_name"]];
                
                //set num more deals
                UILabel *moreDeals = (UILabel *)[cell viewWithTag:46];
                if([[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"add_deals"] count] > 0){
                    moreDeals.text = [NSString stringWithFormat:@"+%lu more deals",(unsigned long)[[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"add_deals"] count]];
                }
                
                //set deal label + location
                UILabel *location = (UILabel *)[cell viewWithTag:45];
                location.text = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"venue"][@"bar_name"] uppercaseString];
                
                UIImageView *background = (UIImageView *)[cell viewWithTag:50];
                NSString *img_url =[[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"image_url"];
                
                
                [background sd_setImageWithURL:[NSURL URLWithString:img_url]];

                //interested
               
                NSNumber *int_count = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row] objectForKey:@"num_accepted"];
//                BOOL interested = NO;
//                
//                if(interested){
//                    cell.img.hidden = NO;
//                    [cell.img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [PFUser currentUser][@"fb_id"]]]];
//                    cell.img.contentMode = UIViewContentModeScaleAspectFill;
//                    cell.img.layer.cornerRadius = cell.img.frame.size.width/2;
//                    cell.img.layer.borderWidth = 2.0;
//                    cell.img.layer.borderColor = [UIColor greenColor].CGColor;
//                    cell.img.clipsToBounds = YES;
//                }
//                else{
//                    cell.image.hidden = YES;
//                }
                
                
                if([int_count integerValue] > 0){
                    cell.goingLbl.hidden = NO;
                    cell.goingLbl.text = [NSString stringWithFormat:@"%@", int_count];
                    cell.goingLbl.layer.cornerRadius = cell.goingLbl.frame.size.width/2;
//                    cell.goingLbl.layer.borderWidth = 2.0;
//                    cell.goingLbl.layer.borderColor = [UIColor blackColor].CGColor;
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
    }
    else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mainDealCell"
                                                         forIndexPath:indexPath];
    }
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DealHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                        withReuseIdentifier:@"sectionHeader"
                                                                 forIndexPath:indexPath];
        if([self.sortedKeys count] > 0){
            if(![[self.dates objectForKey:[self.sortedKeys objectAtIndex:indexPath.section]]  isEqual: @"Today"]){
                NSArray *parts = [[self.dates objectForKey:[self.sortedKeys objectAtIndex:indexPath.section]] componentsSeparatedByString:@","];
                
                cell.dateLabel.text = parts[1];
                self.weekday = parts[0];
                cell.dayLabel.text = [parts[0] uppercaseString];
            }
            else{
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                NSDateComponents *components1 = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
                NSString *dt = [NSString stringWithFormat:@"%ld",(long)[components1 day]];
                NSString *monthName = [[df monthSymbols] objectAtIndex:([components1 month]-1)];
                
                cell.dateLabel.text = [NSString stringWithFormat:@"%@ %@", monthName, dt];
                cell.dayLabel.text = @"TODAY";
                self.weekday = @"Today";
                
            }
            
            cell.numDeals.text = [NSString stringWithFormat:@"%lu",(unsigned long)[[self.sections objectForKey:[self.sortedKeys objectAtIndex:indexPath.section]] count]];
            
        }
        
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
        return CGSizeMake(0.925*iOSScreenSize.width, 0.448943662*iOSScreenSize.height);
    }
    else{
        return CGSizeMake(0.925*iOSScreenSize.width, 0.267605634*iOSScreenSize.height);
    }

}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqual:@"toDealDetail"] || [[segue identifier] isEqual:@"toDealInfo"]){
        BLTDealDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
        NSString *obj = [self.sortedKeys objectAtIndex:indexPath.section];
        NSString *dealID = [[[self.sections objectForKey:obj] objectAtIndex:indexPath.row] objectId];
        self.reloadCell = indexPath;
        [vc setDealID:dealID];
        [vc setDay:self.weekday];
    }
}

#pragma mark ScrollView Delegates




@end
