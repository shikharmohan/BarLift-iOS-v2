

#import "CardViewCell.h"
#import "BLTButton.h"
@interface BLTTopHeader : CardViewCell <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet BLTButton *interestedButton;
@property (nonatomic) BOOL interested;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *dealName;
@property (strong, nonatomic) NSString *dealHeadline;
@property (strong, nonatomic) NSString *dealID;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImg;
@property (strong, nonatomic) NSArray *dealNames;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
 - (void) setUpView;
@end

