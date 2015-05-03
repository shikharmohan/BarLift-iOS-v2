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
#import "SCLAlertView.h"
#import "BLTPreviewFriendsViewController.h"
#import "BLTDealDetailCollectionReusableView.h"

@interface BLTDealDetailViewController ()

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *labels;

@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic, strong) NSMutableDictionary *dealDetails;
@property (nonatomic, strong) NSMutableArray *whosGoing;
@property (nonatomic) NSInteger numGoing;
@property (strong, nonatomic) BLTDealDetailCollectionReusableView *header;
@property (nonatomic) BOOL interested;
@end

@implementation BLTDealDetailViewController
@synthesize dealID, reloadCell, day;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.images = @[@"Icon_Address@3x", @"Icon_Dealdetails@3x", @"icon_viral@3x", @"Icon_Uber@3x"];
        self.data = [[NSMutableArray alloc] initWithCapacity:4];
        self.labels = [[NSMutableArray alloc] initWithCapacity:4];
        self.headerNib = [UINib nibWithNibName:@"CSAlwaysOnTopHeader" bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.interested = NO;
    self.dealDetails = [[NSMutableDictionary alloc] initWithCapacity:10];
    CSStickyHeaderFlowLayout *layout = (id)self.collectionViewLayout;

    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 320);
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
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                self.dealDetails = objects[0];
                
                [PFCloud callFunctionInBackground:@"getWhosGoing" withParameters:@{@"deal_objectId":self.dealID, @"user_objectId": [[PFUser currentUser] objectId]} block:^(id object, NSError *error) {
                    if(!error){
                        self.whosGoing = object[0];
                        self.numGoing = [object[0] count];
                        if([object[1] isEqualToNumber:[NSNumber numberWithBool:YES]]){
                            self.interested = YES;
                        }
                        else{
                            self.interested = NO;
                        }
                        [PFCloud callFunctionInBackground:@"getNumberNudges" withParameters:@{@"dealID":self.dealID} block:^(id object, NSError *error) {
                            if(!error){
                                NSDate *date = [objects[0] createdAt];
                                NSCalendar *calendar = [NSCalendar currentCalendar];
                                NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
                                NSInteger hour = [components hour];
                                NSInteger total = [object integerValue] + (long)hour;
                                self.labels[2] = [NSString stringWithFormat:@"%ld nudges sent", (long)total];
                            }
                            else{
                                NSDate *date = [objects[0] createdAt];
                                NSCalendar *calendar = [NSCalendar currentCalendar];
                                NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
                                NSInteger hour = [components hour];
                                self.labels[2] = [NSString stringWithFormat:@"%ld nudges sent", (long)hour];
                            }
                            [self.collectionView reloadData];
                        }];
                        
                    }
                    else{
                        
                    }
                }];
                self.data[0] = [NSString stringWithFormat:@"%@ %@", self.dealDetails[@"venue"][@"address"], self.dealDetails[@"venue"][@"city_state"]];
                self.data[1] = @"DEAL DETAILS";
                self.data[2] = @"DEAL VIRALITY";
                self.data[3] = @"CALL UBER";
                self.labels[0] = @"Open in Maps";
                self.labels[1] = @"See more >";
                self.labels[2] = @"";
                self.labels[3] = @"Go to Uber";

                self.navigationController.navigationBar.topItem.title = self.dealDetails[@"venue"][@"bar_name"];
            }
            else{
                self.header.moreButton.hidden = YES;
                NSLog(@"error");
            }
        }];
    }
}


-(void) viewWillAppear:(BOOL)animated{
    //self.navigationController.navigationBar.alpha = 0.0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGoing) name:@"imGoing" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notGoing) name:@"notGoing" object:nil];
}

-(void) updateGoing{
    self.numGoing = [self.dealDetails[@"num_accepted"] integerValue]+1;
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateUINotification" object: nil];
    [self.collectionView reloadData];
}
-(void) notGoing{
    self.numGoing = [self.dealDetails[@"num_accepted"] integerValue]-1;
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateUINotification" object: nil];
    [self.collectionView reloadData];
}
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    //NSString *obj = self.sections[indexPath.section][indexPath.row];

    DealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                             forIndexPath:indexPath];
    if([self.data count] >0){
        UIImageView *icon = (UIImageView *)[cell viewWithTag:1];
        UILabel *mainLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *sublabel = (UILabel *) [cell viewWithTag:3];
        UIImage *img = [UIImage imageNamed:self.images[indexPath.row]];
        [icon setImage:img];
        mainLabel.text = self.data[indexPath.row];
        sublabel.text = self.labels[indexPath.row];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 3){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
            NSString *address = self.data[0];
            NSString *newString = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"uber://?client_id=v_LwNpt8BzPKedHILykv2m2-9o8BbvsW&action=setPickup&dropoff[formatted_address]=%@", newString]];
            [[UIApplication sharedApplication] openURL:url];
        }
        else {
            // No Uber app! Open Mobile Website.
            NSURL* appStoreURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/uber/id368677368?mt=8"];
            [[UIApplication sharedApplication] openURL:appStoreURL];
        }
    }
    else if (indexPath.row == 0){
        if ([[UIApplication sharedApplication] canOpenURL:
             [NSURL URLWithString:@"comgooglemaps://"]]) {
            
            NSString *addr = [self.data[0] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%@",addr]]];
        } else {
            NSLog(@"Can't use comgooglemaps://");
        }
    }
    else if (indexPath.row == 1){
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showInfo:self title:@"Deal Details" subTitle:self.dealDetails[@"description"] closeButtonTitle:@"Close" duration:0.0f];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        int count = [self.whosGoing count];
        int imgCount = 0;
        
        self.header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        if(count == 0){
            self.header.whosIntLabel.text = @"Who's Interested:";
            self.header.moreButton.hidden = YES;
        }
        else{
            self.header.moreButton.hidden = NO;
            if(self.numGoing > 1){
                self.header.whosIntLabel.text = [NSString stringWithFormat:@"Who's Interested (%d going):", self.numGoing];
            }
            if(count > 6){
                imgCount = 6;
            }
            else{
                imgCount = count;
            }
            for(int i = 0; i < imgCount; i++){
                NSString *fb_id = self.whosGoing[i][@"fb_id"];
                    UIImageView *img = nil;
                    img = self.header.imageViews[i];
                    [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
                    img.contentMode = UIViewContentModeScaleAspectFill;
                    img.layer.cornerRadius = img.frame.size.width/2;
                    img.clipsToBounds = YES;
            }
        }
        return self.header;

    } else if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        CSAlwaysOnTopHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                forIndexPath:indexPath];
        
        
        
        if(self.dealDetails != nil && self.dealDetails[@"deal_start_date"] != nil && self.dealDetails[@"deal_end_date"] != nil){
            NSDate *startDate = self.dealDetails[@"deal_start_date"];
            NSDate *endDate =self.dealDetails[@"deal_end_date"];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            
            NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:startDate];
            NSInteger start_hour = [components hour];
            NSString *am1 = @"AM";
            NSString *am2 = @"AM";
            components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:endDate];
            NSInteger end_hour = [components hour];
            if(start_hour >= 12){
                am1 = @"PM";
                start_hour -= 12;
            }
            if(start_hour == 0){
                start_hour += 12;
            }
            if(end_hour >= 12){
                am2 = @"PM";
                end_hour -= 12;
            }
            if(end_hour == 0){
                end_hour += 12;
            }
            if(day == nil){
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMM dd"];
                day = [dateFormat stringFromDate:startDate];
            }
            cell.hoursLabel.text = [NSString stringWithFormat:@"%@ | %ld %@ - %ld %@",day, (long)start_hour, am1, (long)end_hour, am2];
            cell.dealName.text = [[self.dealDetails objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            cell.dealHeadline = [[self.dealDetails objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            cell.dealNames = self.dealDetails[@"add_deals"];
            cell.dealID = self.dealID;
            [cell.backgroundImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dealDetails[@"image_url"]]]];
            if(self.interested){
                cell.interested = YES;
            }
            [cell setUpView];
            //set up scrollview
        }
        
        return cell;
    }
    return nil;
}

- (IBAction)addToCalendarPressed:(id)sender {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];

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
    [alert showInfo:self title:@"Calendar Updated" subTitle:@"This deal has been added your calendar." closeButtonTitle:@"Ok, got it!" duration:0.0f]; // Info

}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqual:@"toNudge"]){
        BLTNudgeFriendsViewController *vc = [segue destinationViewController];
        [vc setDealID:self.dealID];
    }
    else if ([[segue identifier] isEqual:@"toWhosGoing"]){
        BLTPreviewFriendsViewController *vc = [segue destinationViewController];
        [vc setDealID:self.dealID];
    }
    
}

@end
