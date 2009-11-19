//
//  XspfMThumbnailData.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/19.
//  Copyright 2009 masakih. All rights reserved.
//

#import <CoreData/CoreData.h>

@class XSPFMXspfObject;

@interface XspfMThumbnailData :  NSManagedObject  
{
}

@property (retain) NSData * data;
@property (retain) XSPFMXspfObject * xspf;

@end


