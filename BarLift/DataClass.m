//
//  DataClass.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/25/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "DataClass.h"

@implementation DataClass
@synthesize dealID;

static DataClass *instance = nil;

+(DataClass *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [DataClass new];
        }
    }
    return instance;
}

@end