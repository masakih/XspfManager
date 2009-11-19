//
//  XspfLoadThumbnailRequest.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/19.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMMainThreadRequest.h"

@class XSPFMXspfObject;

@interface XspfLoadThumbnailRequest : XspfMMainThreadRequest
{
	XSPFMXspfObject *object;
}
@property (retain) XSPFMXspfObject *object;

+ (id)requestWithObject:(XSPFMXspfObject *)object;
- (id)initWithObject:(XSPFMXspfObject *)object;
@end
