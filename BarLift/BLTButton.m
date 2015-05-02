//
//  BLTButton.m
//  BarLift
//
//  Created by Shikhar Mohan on 5/1/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTButton.h"

@implementation BLTButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)init
{
    self = [super init];
    if (self) {
        // Do something
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Do something
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Do something
    }
    return self;
}

- (void)setDefaultBackgroundColor:(UIColor *)defaultBackgroundColor
{
    self.backgroundColor = _defaultBackgroundColor = defaultBackgroundColor;
}
- (void)setHighlighted:(BOOL)highlighted
{
    self.backgroundColor = (highlighted) ? [self darkerColorForColor:_defaultBackgroundColor] : _defaultBackgroundColor;
    [super setHighlighted:highlighted];
}

- (UIColor *)darkerColorForColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.3f, 0.0f)
                               green:MAX(g - 0.3f, 0.0f)
                                blue:MAX(b - 0.3f, 0.0f)
                               alpha:a];
    return nil;
}

@end
