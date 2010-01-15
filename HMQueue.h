//
//  HMQueue.h
//  OldMacViewer
//
//  Created by Hori,Masaki on Thu Sep 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HMQueue : NSObject
{
    id* _queue;
    NSConditionLock* _lock;
    NSUInteger _capacity;
    NSUInteger _top, _bottom;
    NSInteger _stat;
}

+(id)queueWithCapacity:(NSUInteger)aCapacity;
-(id)initWithCapacity:(NSUInteger)aCapacity;

// throw exception named HMQueueOverflow, if queue is full.
-(void)put:(id)data;
-(id)take;

-(NSUInteger)next:(NSUInteger)current;

@end

extern NSString* HMQueueOverflow;
