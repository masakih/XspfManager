//
//  HMWorker.m
//  OldMacViewer
//
//  Created by Hori,Masaki on Wed Sep 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "HMWorker.h"

enum {
    MHWorkerRequestWaiting,
    HMWorkerRequestOperating,
};


@implementation HMWorker

-(id)initWithChannel:(HMChannel*)aChannel
{
    self = [super init];
    if( self ) {
        _channel = aChannel;
        _requestLock = [[NSConditionLock alloc] initWithCondition:MHWorkerRequestWaiting];
    }
    
    return self;
}

#pragma mark -
#pragma mark HMWorker Protocol
-(void)startWorking
{
    while(YES) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        [_requestLock lock];
        _request = [[_channel takeRequest] retain];
        [_requestLock unlockWithCondition:HMWorkerRequestOperating];
		
		NS_DURING
			[_request operate];
		NS_HANDLER
			NSLog( @"An uncaught exception" );
			NSLog( @"%@", localException );
		NS_ENDHANDLER
        
        [_requestLock lock];
        [_request release];
        _request = nil;
        [_requestLock unlockWithCondition:MHWorkerRequestWaiting];
        
        [pool release];
    }
}
        
-(oneway void)terminate
{
    if( [_requestLock tryLockWhenCondition:HMWorkerRequestOperating] ) {
        [_request terminate];
        [_requestLock unlock];
    }
}

-(oneway void)ternimateRequest:(id <HMRequest>)aRequest
{
    if( [_requestLock tryLockWhenCondition:HMWorkerRequestOperating] ) {
        if( [_request isEqual:aRequest] ) {
            [_request terminate];
        }
        [_requestLock unlock];
    }
}

@end
