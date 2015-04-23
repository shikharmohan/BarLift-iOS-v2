//
//  CSAlwaysOnTopHeader.h
//  CSStickyHeaderFlowLayoutDemo
//
//  Created by James Tang on 6/4/14.
//  Copyright (c) 2014 Jamz Tang. All rights reserved.
//

#import "CardViewCell.h"

@interface CSAlwaysOnTopHeader : CardViewCell

@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *dealName;
@property (strong, nonatomic) NSString *dealID;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImg;
@end
