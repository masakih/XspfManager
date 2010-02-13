//
//  XspfManager.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright masakih 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMWorkerProtocols.h"

@class XspfMXspfObject;
@protocol UKFileWatcher;

@interface XspfManager : NSObject 
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	id<HMChannel> channel;
	
	IBOutlet NSMenu *objectMenu;
}

- (NSString *)applicationSupportFolder;

- (NSURL *)storeURL;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

- (IBAction)launchXspfQT:(id)sender;

- (IBAction)showXSPFInFinder:(id)sender;
- (IBAction)showXSPFInformation:(id)sender;
- (IBAction)changeLabel:(id)sender;

- (NSMenu *)menuForXspfObject:(XspfMXspfObject *)object;

- (id<HMChannel>)channel;


- (BOOL)didRegisteredURL:(NSURL *)url;
- (XspfMXspfObject *)registerWithURL:(NSURL *)url;
- (void)registerFilePaths:(NSArray *)filePaths;
- (void)registerURLs:(NSArray *)URLs;
- (void)removeObject:(XspfMXspfObject *)object;

- (void)registerToUKKQueue;
- (void)watcher:(id<UKFileWatcher>)kq receivedNotification:(NSString*)notificationName forPath:(NSString*)filePath;

@end

extern NSString *const XspfManagerDidAddXspfObjectsNotification; // @"XspfManagerAddedXspfObjects"
