//
//  XspfMInfomationObject.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/02.
//  Copyright 2009 masakih. All rights reserved.
//

#import <CoreData/CoreData.h>

@class XspfMXspfObject;

@interface XspfMInfomationObject :  NSManagedObject  
{
}

//@property (retain) NSArray *products;
//@property (retain) NSArray *voiceActors;
@property (retain) NSString * productsList;
@property (retain) NSString * voiceActorsList;
@property (retain) XspfMXspfObject * xspf;

@end


