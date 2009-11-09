// 
//  XSPFMXspfObject.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XSPFMXspfObject.h"

#import "XspfManager_AppDelegate.h"
#import "XspfMCheckFileModifiedRequest.h"

@interface XSPFMXspfObject(HMPrivate)
- (NSURL *)url;
@end

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

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	
	NSData *thumbnailData = [self valueForKey:@"thumbnailData"];
	if(thumbnailData != nil) {
		NSImage *thumbnail = [[[NSImage alloc] initWithData:thumbnailData] autorelease];
		[self setPrimitiveValue:thumbnail forKey:@"thumbnail"];
	}
	
	NSString *urlString = [self valueForKey:@"urlString"];
	if(urlString != nil) {
		NSURL *url = [NSURL URLWithString:urlString];
		[self setPrimitiveValue:url forKey:@"url"];
	}
	
	id<HMChannel> channel = [[NSApp delegate] channel];
	id<HMRequest> request = [XspfMCheckFileModifiedRequest requestWithObject:self url:[self url]];
	[channel putRequest:request];
}

- (NSURL *)url
{
	[self willAccessValueForKey:@"url"];
	NSURL *url = [self primitiveValueForKey:@"url"];
	[self didAccessValueForKey:@"url"];
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
