//
//  BLTNavigationView.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/18/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTNavigationView.h"

@implementation BLTNavigationView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.frame = self.layer.bounds;
    CGFloat height = self.layer.frame.size.height;
    CGFloat width = self.layer.frame.size.width;

    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, nil, width, height-10);
    CGPathAddLineToPoint(path, nil, width, 0);
    CGPathAddLineToPoint(path, nil, 0, 0);
    CGPathAddLineToPoint(path, nil, 0, height);
    CGPathAddLineToPoint(path, nil, width, height-10);
    CGPathCloseSubpath(path);
    
    mask.path = path;
    self.layer.mask = mask;
    
}


@end
