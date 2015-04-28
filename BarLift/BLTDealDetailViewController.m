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
#import "SCLAlertView.h"
#import "BLTPreviewFriendsViewController.h"
#import "BLTDealDetailCollectionReusableView.h"
@interface BLTDealDetailViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic, strong) NSMutableDictionary *dealDetails;
@property (nonatomic, strong) NSMutableArray *whosGoing;
@property (nonatomic, strong) CWStatusBarNotification *calNotification;
@property (strong, nonatomic) BLTDealDetailCollectionReusableView *header;
@property (nonatomic, strong) CWStatusBarNotification *intNotification;
@property (nonatomic) BOOL interested;
@end

@implementation BLTDealDetailViewController
@synthesize dealID, reloadCell, day;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sections = @[@[@"test"]];

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGoingImage) name:@"imGoing" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeGoingImage) name:@"notGoing" object:nil];
}

-(void)updateGoingImage{
    NSString *fb_id = [PFUser currentUser][@"fb_id"];
    UIImageView *img = self.header.imageViews[0];
    [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
    img.contentMode = UIViewContentModeScaleAspectFill;
    img.layer.cornerRadius = img.frame.size.width/2;
    img.clipsToBounds = YES;
    img.layer.borderWidth = 2.0;
    img.layer.borderColor = [UIColor colorWithRed:0.1803 green:0.8 blue:0.443 alpha:1].CGColor;

    self.header.whosIntLabel.text = [NSString stringWithFormat:@"Who's Interested (%d going):", [[self.dealDetails objectForKey:@"whosGoing"] count]];
    self.header.moreButton.hidden = NO;
    
}

-(void)removeGoingImage{
    UIImageView *img = self.header.imageViews[0];
    [UIView beginAnimations:nil context:nil];
    [UIView animateWithDuration:1 animations:nil];
    img.layer.borderWidth = 0.0f;
    img.image = nil;
    BOOL noImage = YES;
    [UIView commitAnimations];
    if([[self.dealDetails objectForKey:@"whosGoing"] count] > 1){
        self.header.whosIntLabel.text = [NSString stringWithFormat:@"Who's Interested (%d going):", [[self.dealDetails objectForKey:@"whosGoing"] count]];
        NSString *fb_id= [self.dealDetails objectForKey:@"whosGoing"][0][@"fb_id"];
        int i = 0;
        while(fb_id != [PFUser currentUser][@"fb_id"] && noImage){
            UIImageView *img = self.header.imageViews[0];
            [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
            img.contentMode = UIViewContentModeScaleAspectFill;
            img.layer.cornerRadius = img.frame.size.width/2;
            img.clipsToBounds = YES;
            img.layer.borderWidth = 2.0;
            img.layer.borderColor = [UIColor colorWithRed:0.1803 green:0.8 blue:0.443 alpha:1].CGColor;
            noImage = NO;
            i++;
            fb_id = [self.dealDetails objectForKey:@"whosGoing"][i][@"fb_id"];
        }

    }
    else{
        self.header.whosIntLabel.text = @"Who's Interested:";
        self.header.moreButton.hidden = YES;
    }
    
}
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sections[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    //NSString *obj = self.sections[indexPath.section][indexPath.row];

    DealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                             forIndexPath:indexPath];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        int count =[[self.dealDetails objectForKey:@"whosGoing"] count];
        int imgCount = 0;
        
        self.header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        if(count == 0){
            self.header.whosIntLabel.text = @"Who's Interested:";
            self.header.moreButton.hidden = YES;
        }
        else{
            self.header.moreButton.hidden = NO;
            self.header.whosIntLabel.text = [NSString stringWithFormat:@"Who's Interested (%d going):", count];
            if(count > 6){
                imgCount = 6;
            }
            else{
                imgCount = count;
            }
            for(int i = 0; i < imgCount; i++){
                NSString *fb_id = [self.dealDetails objectForKey:@"whosGoing"][i][@"fb_id"];
                if(fb_id != [PFUser currentUser][@"fb_id"]){
                    UIImageView *img = nil;
                    img = self.header.imageViews[i];
                    [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
                    img.contentMode = UIViewContentModeScaleAspectFill;
                    img.layer.cornerRadius = img.frame.size.width/2;
                    img.clipsToBounds = YES;
//                    img.layer.borderWidth = 2.0;
//                    img.layer.borderColor = [UIColor colorWithRed:0.1803 green:0.8 blue:0.443 alpha:1].CGColor;
                }
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
            for(int i = 0; i < [[self.dealDetails objectForKey:@"whosGoing" ] count]; i++){
                if([[PFUser currentUser][@"fb_id"] isEqual:[[[self.dealDetails objectForKey:@"whosGoing"] objectAtIndex:i] objectForKey:@"fb_id"]]){
                    cell.interested = YES;
                    self.interested = YES;
                    [self updateGoingImage];
                    break;
                }
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
