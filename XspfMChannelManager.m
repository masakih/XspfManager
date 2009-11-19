//
//  XspfMChannelManager.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/18.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMChannelManager.h"

#import "HMChannel.h"
#import "XspfMMainThreadRequest.h"

@implementation XspfMChannelManager

- (id)init
{
	[super init];
	
	mainThreadChannel = [[HMChannel alloc] initWithWorkerNum:1];
	channel = [[HMChannel alloc] initWithWorkerNum:3];
	
	[self bind:@"channelRequestNum"
	  toObject:channel
   withKeyPath:@"requestNum"
	   options:nil];
	[self bind:@"mainThreadChannelRequestNum"
	  toObject:mainThreadChannel
   withKeyPath:@"requestNum"
	   options:nil];
	
	return self;
}

- (void)dealloc
{
	[self unbind:@"channelRequestNum"];
	[self unbind:@"mainThreadChannelRequestNum"];
	
	[super dealloc];
}

+ (NSSet *)keyPathsForValuesAffectingRequestNum
{
	return [NSSet setWithObjects:@"channelRequestNum", @"mainThreadChannelRequestNum", nil];
}

- (NSInteger)requestNum
{
	return channelRequestNum + mainThreadChannelRequestNum;
}

-(void)putRequest:(id <HMRequest>)aRequest
{
	if([aRequest isKindOfClass:[XspfMMainThreadRequest class]]) {
		[mainThreadChannel putRequest:aRequest];
	} else {
		[channel putRequest:aRequest];
	}
}
-(id <HMRequest>)takeRequest { return nil; }

-(void)terminateAll
{
	[mainThreadChannel terminateAll];
	[channel terminateAll];
}
-(void)terminateRequet:(id <HMRequest>)aRequest
{
	[mainThreadChannel terminateRequet:aRequest];
	[channel terminateRequet:aRequest];
}

@end
