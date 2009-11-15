//
//  HMChannel.m
//  OldMacViewer
//
//  Created by Hori,Masaki on Fri Sep 05 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "HMChannel.h"

#import "HMWorker.h"
#import "HMQueue.h"

@implementation HMChannel

-(void)makeWokers:(int)num
{
    for(; num > 0 ; num-- ) {
        HMWorker* worker = [[[HMWorker alloc] initWithChannel:self] autorelease];
        
        [_workers addObject:worker];
        [NSThread detachNewThreadSelector:@selector(startWorking) toTarget:worker withObject:nil];
    }
}

-(id)initWithWorkerNum:(int)num
{
    self = [super init];
    if( self ) {
        _queue = [[HMQueue alloc] initWithCapacity:128];
        _workers  = [[NSMutableArray alloc] initWithCapacity:num];
        
        [self makeWokers:num];
    }
    
    return self;
}
- (void)finishRequestOnMainThread:(id <HMRequest>)request
{
	[self willChangeValueForKey:@"requestNum"];
	_requestNum--;
	[self didChangeValueForKey:@"requestNum"];
}

- (oneway void)finishRequest:(id <HMRequest>)request
{
	[self performSelectorOnMainThread:@selector(finishRequestOnMainThread:) withObject:request waitUntilDone:NO];
}
- (NSInteger)requestNum
{
	return _requestNum;
}
#pragma mark -
#pragma mark HMChannel Protocol
-(void)putRequest:(id <HMRequest>)aRequest
{
    NS_DURING
        [_queue put:aRequest];
    NS_HANDLER
        if( ! [[localException name] isEqualTo:HMQueueOverflow] ) {
            [localException raise];
        }
    NS_ENDHANDLER
	
	[self willChangeValueForKey:@"requestNum"];
	_requestNum++;
	[self didChangeValueForKey:@"requestNum"];
}

-(id <HMRequest>)takeRequest
{
    return [_queue take];
}

-(void)terminateAll
{
    [_workers makeObjectsPerformSelector:@selector(terminate)];
}

-(void)terminateRequet:(id <HMRequest>)aRequest
{
    [_workers makeObjectsPerformSelector:@selector(terminateRequest:) withObject:aRequest];
}

@end
