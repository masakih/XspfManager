//
//  XspfMMovieLoadRequest.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMMainThreadRequest.h"
#import "XSPFMXspfObject.h"

@interface XspfMMovieLoadRequest : XspfMMainThreadRequest
{
	XSPFMXspfObject *object;
}
@property (retain) XSPFMXspfObject *object;

+ (id)requestWithObject:(XSPFMXspfObject *)object;
- (id)initWithObject:(XSPFMXspfObject *)object;

@end
