//
//  BLTDealDetailCollectionReusableView.h
//  BarLift
//
//  Created by Shikhar Mohan on 4/27/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLTButton.h"
@interface BLTDealDetailCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet BLTButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *whosIntLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@end
