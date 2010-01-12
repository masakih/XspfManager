//
//  XspfLoadThumbnailRequest.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/19.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfLoadThumbnailRequest.h"

#import "XspfMXspfObject.h"
#import "XspfMThumbnailData.h"

@implementation XspfLoadThumbnailRequest
@synthesize object;

+ (id)requestWithObject:(XspfMXspfObject *)obj
{
	return [[[self alloc] initWithObject:obj] autorelease];
}
- (id)initWithObject:(XspfMXspfObject *)obj
{
	[super init];
	self.object = obj;
	return self;
}
- (void)dealloc
{
	self.object = nil;
	
	[super dealloc];
}
- (NSTimeInterval)sleepTime
{
	return 0.03;
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
