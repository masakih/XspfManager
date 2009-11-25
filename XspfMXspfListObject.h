//
//  XspfMXspfListObject.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
//  Copyright 2009 masakih. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface XspfMXspfListObject :  NSManagedObject  
{
	short order;
}

@property (retain) NSString * name;
@property (retain) NSData * predicateData;
@property (retain) NSPredicate *predicate;
@property short order;

@end
