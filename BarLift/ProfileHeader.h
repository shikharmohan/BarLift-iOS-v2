//
//  ProfileHeader.h
//  BarLift
//
//  Created by Shikhar Mohan on 4/15/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeader : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImg;

@end
