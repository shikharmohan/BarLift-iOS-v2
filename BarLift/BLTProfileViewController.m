//
//  BLTProfileViewController.h
//

#import "BLTProfileViewController.h"
#import "CardViewCell.h"
#import "ProfileHeader.h"
#import "CSStickyHeaderFlowLayout.h"
#import <Parse/Parse.h>
#import "BLTStats.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "UIImage+BlurredFrame.h"

@interface BLTProfileViewController ()

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic, strong) NSMutableDictionary *profileInfo;
@property (nonatomic, strong) NSMutableArray *labelData;

@end

@implementation BLTProfileViewController
{
    CGSize iOSScreensize;
}

@synthesize fb_id;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.data = @[@"College", @"Affiliation", @"Last Visited Bar", @"Going out days"];
        self.labelData = [[NSMutableArray alloc] initWithCapacity:4];
        iOSScreensize = [UIScreen mainScreen].bounds.size;
        if(iOSScreensize.width == 320){
            self.headerNib = [UINib nibWithNibName:@"ProfileHeader4" bundle:nil];
        }
        else if(iOSScreensize.width == 375){
            self.headerNib = [UINib nibWithNibName:@"ProfileHeader47" bundle:nil];
        }
        else if(iOSScreensize.width == 414){
            self.headerNib = [UINib nibWithNibName:@"ProfileHeader55" bundle:nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.profileInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
    if(fb_id != nil){
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"fb_id" equalTo:fb_id];
        query.limit = 1;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                NSDictionary *profile = [objects[0] objectForKey:@"profile"];
                NSString *name = profile[@"name"];
                int ct = [[objects[0] objectForKey:@"friends"] count];
                NSInteger dr = [[objects[0] objectForKey:@"deals_redeemed"] integerValue];
                
                [self.profileInfo setObject:name forKey:@"name"];
                [self.profileInfo setValue:[NSNumber numberWithInt:ct] forKey:@"count"];
                [self.profileInfo setValue:[NSNumber numberWithInt:dr] forKey:@"dr"];
                
                self.navigationItem.title = objects[0][@"profile"][@"name"];
                if(objects[0][@"university_name"]){
                    [self.labelData setObject:objects[0][@"university_name"] atIndexedSubscript:0];
                }
                else{
                    [self.labelData setObject:@"Tell them to get the new version!" atIndexedSubscript:0];
                }
                if(objects[0][@"affiliation"]){
                    [self.labelData setObject:objects[0][@"affiliation"] atIndexedSubscript:1];
                }
                else{
                    [self.labelData setObject:@"No student affiliation." atIndexedSubscript:1];
                }
                if(objects[0][@"bar_visited"]){
                    [self.labelData setObject:objects[0][@"bar_visited"] atIndexedSubscript:2];
                }
                else{
                    [self.labelData setObject:@"Tell them to redeem some deals!" atIndexedSubscript:2];
                }
                if(objects[0][@"days_out"]){
                    [self.labelData setObject:objects[0][@"days_out"] atIndexedSubscript:3];
                }
                else{
                    [self.labelData setObject:@"We're not sure yet." atIndexedSubscript:3];
                }
                
                [self.collectionView reloadData];
            }
            else{
                NSLog(@"%@", error);
            }
        }];
        
    }
    else{
        self.navigationItem.title = [PFUser currentUser][@"profile"][@"first_name"];
        if([PFUser currentUser][@"university_name"]){
            [self.labelData setObject:[PFUser currentUser][@"university_name"] atIndexedSubscript:0];
        }
        else{
            [self.labelData setObject:@"Get the new version!" atIndexedSubscript:0];
        }
        if([PFUser currentUser][@"affiliation"]){
            [self.labelData setObject:[PFUser currentUser][@"affiliation"] atIndexedSubscript:1];
        }
        else{
            [self.labelData setObject:@"No student affiliation." atIndexedSubscript:1];
        }
        if([PFUser currentUser][@"visited_bar"]){
            [self.labelData setObject:[PFUser currentUser][@"visited_bar"] atIndexedSubscript:2];
        }
        else{
            [self.labelData setObject:@"Start redeeming some deals!" atIndexedSubscript:2];
        }
        if([PFUser currentUser][@"selected_days"]){
            [self.labelData setObject:[PFUser currentUser][@"selected_days"] atIndexedSubscript:3];
        }
        else{
            [self.labelData setObject:@"We're not sure yet." atIndexedSubscript:3];
        }
        
    }
    CSStickyHeaderFlowLayout *layout = (id)self.collectionViewLayout;
    
    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 264);
        layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height);
        
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, 230);
    }
    
    // If we want to disable the sticky header effect
    layout.disableStickyHeaders = YES;
    
    // Also insets the scroll indicator so it appears below the search bar
  //  self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(144, 0, 0, 0);
    
    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBarHidden = NO;
}
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"profileCell"
                                                                   forIndexPath:indexPath];
    if([self.labelData count] > 0){
        UILabel *sectionLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *lbl = (UILabel *)[cell viewWithTag:2];
        [lbl setText:self.labelData[indexPath.row]];
        if(indexPath.row)
        [sectionLabel setText:[self.data[indexPath.row] uppercaseString]];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        BLTStats *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                            withReuseIdentifier:@"profHeader"
                                                                   forIndexPath:indexPath];
        
        int count, dr;
        if(fb_id == nil){
            if([PFUser currentUser][@"deals_redeemed"] != nil){
                [cell.dealsRedeemed setText:[NSString stringWithFormat:@"%@", [PFUser currentUser][@"deals_redeemed"]]];
                [cell.friendsCount setText:[NSString stringWithFormat:@"%d", [[PFUser currentUser][@"friends"] count]]];
            }
            
            
            count =  [[PFUser currentUser][@"friends"] count];
            dr = [[PFUser currentUser][@"deals_redeemed"] integerValue];
        }
        else{
            if([self.profileInfo objectForKey:@"dr"]){
                [cell.dealsRedeemed setText:[NSString stringWithFormat:@"%@", [self.profileInfo objectForKey:@"dr"]]];
                [cell.friendsCount setText:[NSString stringWithFormat:@"%@", [self.profileInfo objectForKey:@"count"]]];
            }
            count =  [[self.profileInfo objectForKey:@"count"] integerValue];
            dr = [[self.profileInfo objectForKey:@"dr"] integerValue];
            
        }
        int partyScore = count*dr+132+count;
        cell.partyScore.text = [NSString stringWithFormat:@"%d", partyScore];
        
        return cell;
    } else if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        ProfileHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                 withReuseIdentifier:@"header"
                                                                        forIndexPath:indexPath];
        
        if(fb_id == nil){
            [cell.profilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [PFUser currentUser][@"fb_id"]]]];
            cell.profilePic.contentMode = UIViewContentModeScaleAspectFill;
            cell.backgroundImg.image = [cell.profilePic.image applyLightEffectAtFrame:cell.backgroundImg.frame];
            
            //cell.textLabel.text = [PFUser currentUser][@"profile"][@"name"];
        }
        else{
            [cell.profilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fb_id]]];
            cell.profilePic.contentMode = UIViewContentModeScaleAspectFill;
            
            cell.backgroundImg.image = [cell.profilePic.image applyLightEffectAtFrame:cell.backgroundImg.frame];
            // cell.textLabel.text = [self.profileInfo objectForKey:@"name"];
            
            
        }
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width/2;
        cell.profilePic.clipsToBounds = YES;
        cell.profilePic.layer.borderWidth = 2.0;
        cell.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
        
        
        return cell;
    }
    return nil;
}

#pragma mark ScrollView Delegates
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate{
    
    //    self.navigationItem.title = [PFUser currentUser][@"profile"][@"first_name"];
    //    NSLog(@"Did end dragging");
}



@end