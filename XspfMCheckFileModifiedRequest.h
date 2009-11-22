//
//  XspfMCheckFileModifiedRequest.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/09.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMWorkerProtocols.h"
#import "XSPFMXspfObject.h"

@interface XspfMCheckFileModifiedRequest : NSObject <HMRequest>
{
	XSPFMXspfObject *object;
}
@property (retain) XSPFMXspfObject *object;

+ (id)requestWithObject:(XSPFMXspfObject *)object;
- (id)initWithObject:(XSPFMXspfObject *)object;
@end
