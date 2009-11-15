//
//  HMChannel.h
//  OldMacViewer
//
//  Created by Hori,Masaki on Fri Sep 05 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HMWorkerProtocols.h"

@class HMQueue;

@interface HMChannel : NSObject <HMChannel>
{
    HMQueue* _queue;
    NSMutableArray* _workers;
	
	NSInteger _requestNum;
}

-(id)initWithWorkerNum:(int)num;

// called from HMWorker. take care thread safty.
- (oneway void)finishRequest:(id <HMRequest>)request;

- (NSInteger)requestNum;

-(void)putRequest:(id <HMRequest>)aRequest;
-(id <HMRequest>)takeRequest;
-(void)terminateAll;
-(void)terminateRequet:(id <HMRequest>)aRequest;

@end
