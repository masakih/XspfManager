// 
//  XSPFMXspfObject.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XSPFMXspfObject.h"


@implementation XSPFMXspfObject 

@dynamic registerDate;
@dynamic thumbnailData;
@dynamic urlString;
@dynamic lastUpdateDate;
@dynamic lastPlayDate;

@synthesize url;
@synthesize thumbnail;

- (NSURL *)url
{
	[self willAccessValueForKey:@"url"];
	NSURL *url = [self primitiveValueForKey:@"url"];
	[self didAccessValueForKey:@"url"];
	if (url == nil) {
		NSString *urlString = [self valueForKey:@"urlString"];
		if (urlString != nil) {
			url = [NSURL URLWithString:urlString];
			[self setValue:url forKey:@"url"];
		}
	}
	return url;
}
- (void)setUrl:(NSURL *)aURL
{
	[self willChangeValueForKey:@"url"];
	[self setPrimitiveValue:aURL forKey:@"url"];
	[self didChangeValueForKey:@"url"];
	[self setValue:[aURL absoluteString] forKey:@"urlString"];
}

- (NSImage *)thumbnail
{
	[self willAccessValueForKey:@"thumbnail"];
	NSImage *thumbnail = [self primitiveValueForKey:@"thumbnail"];
	[self didAccessValueForKey:@"thumbnail"];
	if (thumbnail == nil) {
		NSData *thumbnailData = [self valueForKey:@"thumbnailData"];
		if (thumbnailData != nil) {
			thumbnail = [[[NSImage alloc] initWithData:thumbnailData] autorelease];
			[self setValue:thumbnail forKey:@"thumbnail"];
		}
	}
	return thumbnail;
}
- (void)setThumbnail:(NSImage *)aThumbnail
{
	[self willChangeValueForKey:@"thumbnail"];
	[self setPrimitiveValue:aThumbnail forKey:@"thumbnail"];
	[self didChangeValueForKey:@"thumbnail"];
	[self setValue:[aThumbnail TIFFRepresentation] forKey:@"thumbnailData"];
}


- (NSString *)title
{
	NSString *path = [self.url path];
	path = [path lastPathComponent];
	path = [path stringByDeletingPathExtension];
	
	return path;
}

@end
