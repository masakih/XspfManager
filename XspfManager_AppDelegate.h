//
//  XspfManager_AppDelegate.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright masakih 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XspfManager_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (NSString *)applicationSupportFolder;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

@end
