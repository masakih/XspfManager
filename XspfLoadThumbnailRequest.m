//
//  XspfLoadThumbnailRequest.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/19.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfLoadThumbnailRequest.h"

#import "XSPFMXspfObject.h"
#import "XspfMThumbnailData.h"

@implementation XspfLoadThumbnailRequest
@synthesize object;

+ (id)requestWithObject:(XSPFMXspfObject *)obj
{
	return [[[self alloc] initWithObject:obj] autorelease];
}
- (id)initWithObject:(XSPFMXspfObject *)obj
{
	[super init];
	self.object = obj;
	return self;
}

- (void)fire
{
	// fault!!
	NSData *data = self.object.thumbnailData.data;
	if(!data) {
		return;
	}
}
@end
