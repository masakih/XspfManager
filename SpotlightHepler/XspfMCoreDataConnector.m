//
//  XspfMCoreDataConnector.m
//  XspfManager
//
//  Created by Hori,Masaki on 11/07/05.
//  Copyright 2011 masakih. All rights reserved.
//

#import "XspfMCoreDataConnector.h"


@implementation XspfMCoreDataConnector

- (void)dealloc
{
	[persistentStoreCoordinator release];
	[managedObjectModel release];
	[managedObjectContext release];
	
	[super dealloc];
}

/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "XspfManager" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
	return [basePath stringByAppendingPathComponent:@"XspfManager"];
}
- (NSURL *)storeURL
{
	NSFileManager *fileManager;
	NSString *applicationSupportFolder = nil;
	NSURL *url;
	
	fileManager = [NSFileManager defaultManager];
	applicationSupportFolder = [self applicationSupportFolder];
	if(![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL]) {
		[fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
	}
	
	url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent:@"XspfManager.qdb"]];
	
	return url;
}

/**
 Returns the managed object model. 
 The last read model is cached in a global variable and reused
 if the URL and modification date are identical
 */
static NSManagedObjectModel *cachedModel = nil;
static NSDate				*cachedModelModificationDate =nil;

- (NSManagedObjectModel *)managedObjectModel
{
	if (managedObjectModel != nil) return managedObjectModel;
	
	NSDictionary *modelFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self storeURL] path] error:nil];
	NSDate *modelModificationDate =  [modelFileAttributes objectForKey:NSFileModificationDate];
	
	if ([modelModificationDate isEqualToDate:cachedModelModificationDate]) {
		managedObjectModel = [cachedModel retain];
	} 	
	
	if (!managedObjectModel) {
		NSWorkspace *ws = [NSWorkspace sharedWorkspace];
		NSString *XspfManagerPath = [ws fullPathForApplication:@"XspfManager"];
		NSBundle *bundle = [NSBundle bundleWithPath:XspfManagerPath];
		if(!bundle) {
			NSLog(@"Can not get bundle.");
			return nil;
		}
		managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:bundle]] retain]; 
		
		if (!managedObjectModel) {
			NSLog(@"%@:%s unable to load model at URL %@", [self class], _cmd, [self storeURL]);
			return nil;
		}
		
		// XspfMXspfListObject  XspfMThumbnailData 
		// XspfMInfomationObject XspfMXspfObject
		
		
		// Clear out all custom classes used by the model to avoid having to link them
		// with the importer. Remove this code if you need to access your custom logic.
		NSString *managedObjectClassName = [NSManagedObject className];
		for (NSEntityDescription *entity in managedObjectModel) {
			NSString *className = [entity managedObjectClassName];
			if(![className isEqualToString:@"XspfMInfomationObject"]
			   && ![className isEqualToString:@"XspfMXspfObject"]) {
				[entity setManagedObjectClassName:managedObjectClassName];
			}
		}
		// cache last loaded model
		
		cachedModel = [managedObjectModel retain];
		[cachedModelModificationDate release];
		cachedModelModificationDate = [modelModificationDate retain];
	}
	
	return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSError *error = nil;
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
												  configuration:nil 
															URL:[self storeURL] 
														options:nil 
														  error:&error]){
        NSLog(@"%@:%s unable to add persistent store coordinator - %@", [self class], _cmd, error);
    }    
	
    return persistentStoreCoordinator;
	
}


/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *)managedObjectContext
{
	if(managedObjectContext != nil) {
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if(coordinator != nil) {
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
	}
	
	return managedObjectContext;
}

@end
