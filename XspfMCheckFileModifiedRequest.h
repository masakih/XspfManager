//
//  XspfMCheckFileModifiedRequest.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/09.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMWorkerProtocols.h"

@interface XspfMCheckFileModifiedRequest : NSObject <HMRequest>
{
	id object;
	NSURL *url;
}
@property (retain) id object;
@property (retain) NSURL *url;

+ (id)requestWithObject:(id)object url:(NSURL *)url;
- (id)initWithObject:(id)object url:(NSURL *)url;
@end
