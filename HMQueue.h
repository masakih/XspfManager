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
    unsigned _capacity;
    unsigned _top, _bottom;
    int _stat;
}

+(id)queueWithCapacity:(unsigned int)aCapacity;
-(id)initWithCapacity:(unsigned int)aCapacity;

// throw exception named HMQueueOverflow, if queue is full.
-(void)put:(id)data;
-(id)take;

-(unsigned)next:(unsigned)current;

@end

extern NSString* HMQueueOverflow;
