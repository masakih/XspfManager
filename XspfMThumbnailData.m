// 
//  XspfMThumbnailData.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/19.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMThumbnailData.h"

#import "XSPFMXspfObject.h"

@implementation XspfMThumbnailData 

@dynamic data;
@dynamic xspf;

- (void)awakeFromFetch
{
	if(self.xspf.thumbnail == nil) {
		NSImage *thumbnail = [[[NSImage alloc] initWithData:self.data] autorelease];
		self.xspf.thumbnail = thumbnail;
	}
}

@end
