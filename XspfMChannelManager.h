//
//  XspfMChannelManager.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/18.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMWorkerProtocols.h"

@interface XspfMChannelManager : NSObject <HMChannel>
{
	id<HMChannel> channel;
	id<HMChannel> mainThreadChannel;
	
	NSInteger channelRequestNum;
	NSInteger mainThreadChannelRequestNum;
}

- (NSInteger)requestNum;

@end
