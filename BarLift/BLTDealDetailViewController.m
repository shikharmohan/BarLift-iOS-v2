#import "BLTDealDetailViewController.h"
#import "DealCell.h"
#import "ProfileHeader.h"
#import "CSStickyHeaderFlowLayout.h"
#import "CSAlwaysOnTopHeader.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"


@interface BLTDealDetailViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic, strong) NSMutableDictionary *dealDetails;
@property (nonatomic, strong) NSMutableArray *whosGoing;
@end

@implementation BLTDealDetailViewController
@synthesize dealID;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sections = @[
                          @[
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                              @"Test",
                            ],
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
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                self.dealDetails = objects[0];
                [self.collectionView reloadData];
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





@end
