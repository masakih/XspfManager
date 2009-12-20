//
//  XspfMThreadSpleepRequest.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/20.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMThreadSpleepRequest.h"


@implementation XspfMThreadSpleepRequest
+ (id)requestWithSleepTime:(NSTimeInterval)time
{
	return [[[self alloc] initWithSleepTime:time] autorelease];
}
- (id)initWithSleepTime:(NSTimeInterval)time
{
	[super init];
	sleepTime = time;
	return self;
}
- (void)fire {}

- (NSTimeInterval)sleepTime {return sleepTime;}

@end
