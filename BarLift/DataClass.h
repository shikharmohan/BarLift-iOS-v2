//
//  DataClass.h
//  BarLift
//
//  Created by Shikhar Mohan on 2/25/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataClass : NSObject {
    
    NSString *dealID;
}

@property(nonatomic,retain)NSString *dealID;


+(DataClass*)getInstance;
@end