//
//  XspfMSpotlighterHelper.h
//  XspfMSpotlighterHelper
//
//  Created by Hori,Masaki on 11/06/29.
//  Copyright 2011 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMCoreDataConnector.h"


@protocol XspfQTSpotlightIndexerProtocol
- (NSDictionary *)dataFromURL:(NSURL *)url;
@end

@interface XspfMSpotlighterHelper : NSObject <XspfQTSpotlightIndexerProtocol>
{
	NSLock *lock;
	NSTimer *timer;
	XspfMCoreDataConnector *connector;
}

- (XspfMCoreDataConnector *)connector;
@end
