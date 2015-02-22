//
//  BLTIntroPagesViewController.h
//  BarLift
//
//  Created by Shikhar Mohan on 2/21/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BLTIntroPagesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *slideImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property NSString *subtitleText;
@end
