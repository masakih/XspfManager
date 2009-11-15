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
	NSURL *url;
}
@property (retain) XSPFMXspfObject *object;
@property (retain) NSURL *url;

+ (id)requestWithObject:(XSPFMXspfObject *)object url:(NSURL *)url;
- (id)initWithObject:(XSPFMXspfObject *)object url:(NSURL *)url;
@end
