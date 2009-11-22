// 
//  XSPFMXspfObject.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XSPFMXspfObject.h"
#import "XspfMThumbnailData.h"

#import "XspfManager_AppDelegate.h"
#import "XspfMCheckFileModifiedRequest.h"
#import "XspfMMovieLoadRequest.h"
#import "XspfLoadThumbnailRequest.h"

#import "NSPathUtilities-XspfQT-Extensions.h"

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
@dynamic alias;


- (void)awakeFromFetch
{
	[super awakeFromFetch];
	
	NSString *urlString = self.urlString;
	if(urlString != nil) {
		NSURL *url = [NSURL URLWithString:urlString];
		[self setPrimitiveValue:url forKey:@"url"];
	}
	
	id<HMChannel> channel = [[NSApp delegate] channel];
	id<HMRequest> request = [XspfMCheckFileModifiedRequest requestWithObject:self url:self.url];
	[channel putRequest:request];
}

- (void)awakeFromInsert
{
	id info = [NSEntityDescription insertNewObjectForEntityForName:@"Info"
											inManagedObjectContext:[self managedObjectContext]];
	
	[self setValue:info forKey:@"information"];
	id thumbnailData = [NSEntityDescription insertNewObjectForEntityForName:@"ThumbnailData"
													 inManagedObjectContext:[self managedObjectContext]];
	
	[self setValue:thumbnailData forKey:@"thumbnailData"];
}

- (void)setUrlString:(NSString *)string
{
	[self willChangeValueForKey:@"urlString"];
	[self setPrimitiveValue:string forKey:@"urlString"];
	[self didChangeValueForKey:@"urlString"];
	self.alias = [[self.url path] aliasData];
}
- (NSData *)alias
{
	[self willAccessValueForKey:@"alias"];
	NSData *alias = [self primitiveValueForKey:@"alias"];
	[self didAccessValueForKey:@"alias"];
	if(!alias) {
		alias = [[self.url path] aliasData];
	}
	if(alias) {
		[self willChangeValueForKey:@"alias"];
		[self setPrimitiveValue:alias forKey:@"alias"];
		[self didChangeValueForKey:@"alias"];
	}
	
	return alias;
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

- (BOOL)isDeleted
{
	[self willAccessValueForKey:@"deleted"];
	NSNumber *deleted = [self primitiveValueForKey:@"deleted"];
	[self didAccessValueForKey:@"deleted"];
	
	return [deleted boolValue];
}
- (BOOL)deleted
{
	return [self isDeleted];
}
- (void)setIsDeleted:(BOOL)flag
{
	NSNumber *deleted = [NSNumber numberWithBool:flag];
	[self willChangeValueForKey:@"deleted"];
	[self setPrimitiveValue:deleted forKey:@"deleted"];
	[self didChangeValueForKey:@"deleted"];
}
- (void)setDeleted:(BOOL)flag
{
	[self setIsDeleted:flag];
}
- (NSImage *)thumbnail
{
	[self willAccessValueForKey:@"thumbnail"];
	NSImage *thumbnail = [self primitiveValueForKey:@"thumbnail"];
	[self didAccessValueForKey:@"thumbnail"];
	
	if(!thumbnail && !didPutLoadRequest) {
		didPutLoadRequest = YES;
		id<HMChannel> channel = [[NSApp delegate] channel];
		id<HMRequest> request = [XspfLoadThumbnailRequest requestWithObject:self];
		[channel putRequest:request];
	}
	
	return thumbnail;
} 
- (void)setThumbnail:(NSImage *)aThumbnail
{
	[self willAccessValueForKey:@"thumbnail"];
	NSImage *thumbnail = [self primitiveValueForKey:@"thumbnail"];
	[self didAccessValueForKey:@"thumbnail"];
	if([aThumbnail isEqual:thumbnail]) return;
	
	[self willChangeValueForKey:@"thumbnail"];
	[self setPrimitiveValue:aThumbnail forKey:@"thumbnail"];
	[self didChangeValueForKey:@"thumbnail"];
	self.thumbnailData.data = [aThumbnail TIFFRepresentation];
}

- (void)setModificationDate:(NSDate *)newDate
{
	[self willAccessValueForKey:@"modificationDate"];
	NSDate *oldDate = [self primitiveValueForKey:@"modificationDate"];
	[self didAccessValueForKey:@"modificationDate"];
	
	// 更新日時に変更がありサムネイルが既に存在していれば、ファイル内容を確認し直す。
	if(NSOrderedSame != [newDate compare:oldDate]) {
		if(self.thumbnail) {
			id<HMChannel> channel = [[NSApp delegate] channel];
			id<HMRequest> request = [XspfMMovieLoadRequest requestWithObject:self url:self.url];
			[channel putRequest:request];
		}
	}
	
	[self willChangeValueForKey:@"modificationDate"];
	[self setPrimitiveValue:newDate forKey:@"modificationDate"];
	[self didChangeValueForKey:@"modificationDate"];
}

- (NSString *)title
{
	if(title == nil) {
		NSString *aTitle = self.filePath;
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
		NSString *path = [self.alias resolvedPath];
		if(path) {
			[filePath release];
			filePath = [path copy];
		}
	}
	
	return filePath;
}
@end
