//
//  BLTIntroViewController.h
//  BarLift
//
//  Created by Shikhar Mohan on 2/21/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLTLoginViewController.h"
#import "BLTIntroPagesViewController.h"

@interface BLTIntroViewController : UIViewController  <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageSubtitles;
@property (strong, nonatomic) NSArray *pageImages;

@end
