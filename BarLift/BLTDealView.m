//
//  BLTDealView.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/19/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTDealView.h"

@implementation BLTDealView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.frame = self.layer.bounds;
    CGFloat height = self.layer.frame.size.height;
    CGFloat width = self.layer.frame.size.width;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, nil, width, 0);
    CGPathAddLineToPoint(path, nil, 0, 10);
    CGPathAddLineToPoint(path, nil, 0, height);
    CGPathAddLineToPoint(path, nil, width, height);
    CGPathAddLineToPoint(path, nil, width, 0);
    CGPathCloseSubpath(path);

    mask.path = path;
    self.layer.mask = mask;
}


@end
