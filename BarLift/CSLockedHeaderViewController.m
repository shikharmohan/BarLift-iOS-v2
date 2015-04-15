#import "CSLockedHeaderViewController.h"
#import "DealCell.h"
#import "DealHeader.h"
#import "CSStickyHeaderFlowLayout.h"
#import "LocationCell.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "YALSunnyRefreshControl.h"

@interface CSLockedHeaderViewController ()

@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSMutableDictionary *dates;
@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViews;

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
    self.collectionView.alwaysBounceVertical = YES;
    [self refreshPage];
    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];
}

-(void)test{
    NSLog(@"Hey");
    [self.sections removeAllObjects];
    [self.dates removeAllObjects];
    [self refreshPage];
    [self.refreshControl endRefreshing];

}

-(void)refreshPage{
    self.sections =  [[NSMutableDictionary alloc]initWithCapacity:10];
    PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
    NSDate *date = [NSDate date];
    [query whereKey:@"deal_end_date" greaterThanOrEqualTo:date];
    [query whereKey:@"community_name" equalTo:@"NU"];
    [query orderByDescending:@"deal_start_date"];
    [query includeKey:@"user"];
    [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(int i =0; i < [objects count]; i++){
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
                    key = [NSString stringWithFormat:@"%d%d%ld", [components1 month], [components1 day], (long)[components1 year]];
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

            }
            NSLog(@"%@", self.sections);
            [self.collectionView reloadData];
        }
        else{
            NSLog(@"%@", error);
        }
    }];

}
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.dates allKeys] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.sections objectForKey:[[self.dates allKeys] objectAtIndex:section]] count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *obj = [[self.dates allKeys] objectAtIndex:indexPath.section];
    DealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                             forIndexPath:indexPath];
    cell.textLabel.text = [[self.sections objectForKey:obj] objectAtIndex:indexPath.row][@"name"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DealHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"sectionHeader"
                                                                 forIndexPath:indexPath];
        
        cell.textLabel.text = [self.dates objectForKey:[[self.dates allKeys] objectAtIndex:indexPath.section]];
        
        return cell;
    } else if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        LocationCell *lcell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                   forIndexPath:indexPath];
        [lcell.textLabel setText:@"NORTHWESTERN"];
        
        
        return lcell;
    }
    return nil;
}



@end
