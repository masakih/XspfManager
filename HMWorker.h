//
//  HMWorker.h
//  OldMacViewer
//
//  Created by Hori,Masaki on Wed Sep 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HMWorkerProtocols.h"

#import "HMChannel.h"

@interface HMWorker : NSObject
{
    id <HMRequest> _request;
    HMChannel* _channel;
    NSConditionLock* _requestLock;
}

@end
