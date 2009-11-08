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
@dynamic modificationDate;
@dynamic lastPlayDate;
@dynamic movieNum;
@dynamic creationDate;

@synthesize title;
@synthesize filePath;

- (NSURL *)url
{
	[self willAccessValueForKey:@"url"];
	NSURL *url = [self primitiveValueForKey:@"url"];
	[self didAccessValueForKey:@"url"];
	if(url == nil) {
		NSString *urlString = [self valueForKey:@"urlString"];
		if(urlString != nil) {
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
	if(thumbnail == nil) {
		NSData *thumbnailData = [self valueForKey:@"thumbnailData"];
		if(thumbnailData != nil) {
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
	if(title == nil) {
		NSString *aTitle = [self.url path];
		aTitle = [aTitle lastPathComponent];
		aTitle = [aTitle stringByDeletingPathExtension];
		if(aTitle) {
			[title release];
			title = [aTitle copy];
		}
	}
	
	return title;
}
- (NSString *)filePath
{
	if(filePath == nil) {
		NSString *path = [self.url path];
		if(path) {
			[filePath release];
			filePath = [path copy];
		}
	}
	
	return filePath;
}
@end
