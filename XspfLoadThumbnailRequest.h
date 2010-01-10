//
//  XspfLoadThumbnailRequest.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/19.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMMainThreadRequest.h"

@class XspfMXspfObject;

@interface XspfLoadThumbnailRequest : XspfMMainThreadRequest
{
	XspfMXspfObject *object;
}
@property (retain) XspfMXspfObject *object;

+ (id)requestWithObject:(XspfMXspfObject *)object;
- (id)initWithObject:(XspfMXspfObject *)object;
@end
