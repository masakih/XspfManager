//
//  XSPFMXspfObject.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import <CoreData/CoreData.h>

@class XspfMThumbnailData;

@interface XSPFMXspfObject :  NSManagedObject
{
	NSString *title;
	NSString *filePath;
	
	BOOL didPutLoadRequest;
}

@property (retain) NSDate * registerDate;
@property (retain) XspfMThumbnailData * thumbnailData;
@property (retain) NSString * urlString;
@property (retain) NSDate * modificationDate;
@property (retain) NSDate * lastPlayDate;
@property (retain) NSNumber *movieNum;
@property (retain) NSDate * creationDate;
@property (retain) NSData *alias;
@property BOOL deleted;

@property (retain) NSURL *url;
@property (retain) NSImage *thumbnail;

@property (retain, readonly) NSString *title;
@property (retain, readonly) NSString *filePath;

@end
