//
//  XspfMMainThreadRequest.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/18.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMWorkerProtocols.h"

@interface XspfMMainThreadRequest : NSObject <HMRequest>
{
}

- (void)fire;	// shuld override subclass.

- (NSTimeInterval)sleepTime;

@end
