//
//  XspfMCheckFileModifiedRequest.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/09.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMWorkerProtocols.h"
#import "XspfMXspfObject.h"

@interface XspfMCheckFileModifiedRequest : NSObject <HMRequest>
{
	XspfMXspfObject *object;
}
@property (retain) XspfMXspfObject *object;

+ (id)requestWithObject:(XspfMXspfObject *)object;
- (id)initWithObject:(XspfMXspfObject *)object;
@end
