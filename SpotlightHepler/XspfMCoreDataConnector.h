//
//  XspfMCoreDataConnector.h
//  XspfManager
//
//  Created by Hori,Masaki on 11/07/05.
//  Copyright 2011 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMCoreDataConnector : NSObject
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (retain, readonly) NSManagedObjectContext *managedObjectContext;
@end
