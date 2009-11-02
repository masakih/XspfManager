//
//  HMWorkerProtocols.h
//  OldMacViewer
//
//  Created by Hori,Masaki on Wed Sep 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//


@protocol HMRequest <NSObject>

-(void)operate;
-(void)terminate;

@end

@protocol HMChannel

-(void)putRequest:(id <HMRequest>)aRequest;
-(id <HMRequest>)takeRequest;

-(void)terminateAll;
-(void)terminateRequet:(id <HMRequest>)aRequest;

@end

@protocol HMWorker

-(id)initWithChannel:(id <HMChannel>)aChannel;
-(void)startWorking;
-(oneway void)terminate;
-(oneway void)ternimateRequest:(id <HMRequest>)aRequest;

@end
