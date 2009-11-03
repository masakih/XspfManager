//
//  XSPFMXspfObject.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface XSPFMXspfObject :  NSManagedObject  
{
	NSString *title;
	NSString *filePath;
}

@property (retain) NSDate * registerDate;
@property (retain) NSData * thumbnailData;
@property (retain) NSString * urlString;
@property (retain) NSDate * lastUpdateDate;
@property (retain) NSDate * lastPlayDate;
@property (retain) NSNumber *movieNum;

@property (retain) NSURL *url;
@property (retain) NSImage *thumbnail;

@property (retain, readonly) NSString *title;
@property (retain, readonly) NSString *filePath;

@end


