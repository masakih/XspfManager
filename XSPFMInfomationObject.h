//
//  XSPFMInfomationObject.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/02.
//  Copyright 2009 masakih. All rights reserved.
//

#import <CoreData/CoreData.h>

@class XSPFMXspfObject;

@interface XSPFMInfomationObject :  NSManagedObject  
{
}

@property (retain) NSArray *voiceActors;
@property (retain) NSString * voiceActorsList;
@property (retain) XSPFMXspfObject * xspf;

@end


