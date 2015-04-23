#import "BLTDealDetailViewController.h"
#import "DealCell.h"
#import "ProfileHeader.h"
#import "CSStickyHeaderFlowLayout.h"
#import "CSAlwaysOnTopHeader.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BLTNudgeFriendsViewController.h"
#import <EventKit/EventKit.h>
#import "CWStatusBarNotification.h"


@interface BLTDealDetailViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic, strong) NSMutableDictionary *dealDetails;
@property (nonatomic, strong) NSMutableArray *whosGoing;
@property (nonatomic, strong) CWStatusBarNotification *calNotification;
@property (nonatomic, strong) CWStatusBarNotification *intNotification;

@end

@implementation BLTDealDetailViewController
@synthesize dealID, reloadCell;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sections = @[
                          @[@"test"
                            ]
                          ];

        self.headerNib = [UINib nibWithNibName:@"CSAlwaysOnTopHeader" bundle:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dealDetails = [[NSMutableDictionary alloc] initWithCapacity:10];
    CSStickyHeaderFlowLayout *layout = (id)self.collectionViewLayout;

    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 426);
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, 100);
        layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height);
        layout.parallaxHeaderAlwaysOnTop = YES;

        // If we want to disable the sticky header effect
        layout.disableStickyHeaders = YES;
    }

    // Also insets the scroll indicator so it appears below the search bar
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];
    
    //do query if deal ID exists
    if(self.dealID != nil){
        PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
        [query whereKey:@"objectId" equalTo:self.dealID];
        [query includeKey:@"venue"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                self.dealDetails = objects[0];
                PFRelation *relation = [objects[0] relationForKey:@"social"];
                PFQuery *query2 = [relation query];
                [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if(!error){
                        self.dealDetails[@"whosGoing"] = objects;
                        [self.collectionView reloadData];
                    }
                }];
            }
            else{
                NSLog(@"error");
            }
        }];
    }
}


-(void) viewWillAppear:(BOOL)animated{
    //self.navigationController.navigationBar.alpha = 0.0;

}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sections[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *obj = self.sections[indexPath.section][indexPath.row];

    DealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                             forIndexPath:indexPath];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

        UICollectionReusableView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"sectionHeader"
                                                                 forIndexPath:indexPath];

        return cell;

    } else if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        CSAlwaysOnTopHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                forIndexPath:indexPath];
        
        if(self.dealDetails != nil){
            cell.hoursLabel.text = @"6PM - 4AM";
            cell.dealName.text = [self.dealDetails objectForKey:@"name"];
            cell.dealID = self.dealID;
        }
        
        return cell;
    }
    return nil;
}

- (IBAction)addToCalendarPressed:(id)sender {
    
    self.calNotification = [CWStatusBarNotification new];
    self.calNotification.notificationStyle = CWNotificationStyleNavigationBarNotification;
    
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = [self.dealDetails objectForKey:@"name"];
        event.location = self.dealDetails[@"venue"][@"bar_name"];
        event.startDate = self.dealDetails[@"deal_start_date"];
        event.endDate = self.dealDetails[@"deal_end_date"];
        event.calendar = [store defaultCalendarForNewEvents];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];

        // self.savedEventId = event.eventIdentifier;  //save the event id if you want to access this later
    }];
    self.calNotification.notificationLabelBackgroundColor = [UIColor blueColor];
    [self.calNotification displayNotificationWithMessage:@"Added deal to your calendar."
                                             forDuration:1.5f];

}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BLTNudgeFriendsViewController *vc = [segue destinationViewController];
    [vc setDealID:self.dealID];
    
}

@end
