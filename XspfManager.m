//
//  XspfManager_AppDelegate.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright masakih 2009 . All rights reserved.
//

#import "XspfManager.h"

#import "XspfMChannelManager.h"
#import "XspfMMainWindowController.h"

#import "XspfMThreadSpleepRequest.h"
#import "XspfMCheckFileModifiedRequest.h"
#import "XspfMMovieLoadRequest.h"

#import "UKKQueue.h"
#import "XSPFMXspfObject.h"

#import "NSPathUtilities-XspfQT-Extensions.h"

@implementation XspfManager
NSString *const XspfManagerDidAddXspfObjectsNotification = @"XspfManagerDidAddXspfObjectsNotification";

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


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel
{
	if(managedObjectModel != nil) {
	return managedObjectModel;
	}
	
	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
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
	if(persistentStoreCoordinator != nil) {
		return persistentStoreCoordinator;
	}

	NSFileManager *fileManager;
	NSString *applicationSupportFolder = nil;
	NSURL *url;
	NSError *error;
    
	fileManager = [NSFileManager defaultManager];
	applicationSupportFolder = [self applicationSupportFolder];
	if(![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL]) {
		[fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
	}
	
	url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"XspfManager.qdb"]];
	
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	if(!persistentStoreCoordinator) {
		NSLog(@"Could not create store coordinator");
		exit(-1);
	}
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, nil];
	
	if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]){
		[[NSApplication sharedApplication] presentError:error];
		NSLog(@"Error -> %@", [error localizedDescription]);
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


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction)saveAction:(id)sender
{
	NSError *error = nil;
	if(![[self managedObjectContext] save:&error]) {
		[[NSApplication sharedApplication] presentError:error];
	}
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	NSError *error;
	int reply = NSTerminateNow;
	
	if(managedObjectContext != nil) {
		if([managedObjectContext commitEditing]) {
			if([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

				BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
				if(errorResult == YES) {
					reply = NSTerminateCancel;
				} else {
					
					int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
					if(alertReturn == NSAlertAlternateReturn) {
						reply = NSTerminateCancel;	
					}
				}
			}
		} else {
			reply = NSTerminateCancel;
		}
	}
	
	return reply;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc
{
	[managedObjectContext release], managedObjectContext = nil;
	[persistentStoreCoordinator release], persistentStoreCoordinator = nil;
	[managedObjectModel release], managedObjectModel = nil;
	[super dealloc];
}

- (IBAction)launchXspfQT:(id)sender
{
	[[NSWorkspace sharedWorkspace] launchApplication:@"XspfQT"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	UKKQueue *queue = [UKKQueue sharedFileWatcher];
	[queue setDelegate:self];
	
	XspfMThreadSpleepRequest *request = [XspfMThreadSpleepRequest requestWithSleepTime:0.5];
	[[self channel] putRequest:request];
	
	[self performSelector:@selector(registerToUKKQueue) withObject:nil afterDelay:0.0];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (id<HMChannel>)channel
{
	if(!channel) {
		channel = [[XspfMChannelManager alloc] init];
	}
	
	return channel;
}

#pragma maark-
- (BOOL)didRegisteredURL:(NSURL *)url
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSInteger num;
	
	fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"Xspf" inManagedObjectContext:moc]];
	NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"urlString LIKE %@", [url absoluteString]];
	[fetch setPredicate:aPredicate];
	num = [moc countForFetchRequest:fetch error:&error];
	if(error) {
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	return num != 0;
}
- (XSPFMXspfObject *)registerWithURL:(NSURL *)url
{
	if([self didRegisteredURL:url]) return nil;
	
	XSPFMXspfObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Xspf"
														 inManagedObjectContext:[self managedObjectContext]];
	if(!obj) return nil;
	
	obj.url = url;
	obj.registerDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
	
	// will set in XspfMCheckFileModifiedRequest.
	//	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"modificationDate"];
	//	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"creationDate"];
	
	id<HMChannel> aChannel = [self channel];
	id<HMRequest> request = [XspfMCheckFileModifiedRequest requestWithObject:obj];
	[aChannel putRequest:request];
	request = [XspfMMovieLoadRequest requestWithObject:obj];
	[aChannel putRequest:request];
	
	[[UKKQueue sharedFileWatcher] addPathToQueue:obj.filePath];
	
	return obj;
}
- (void)registerFilePaths:(NSArray *)filePaths
{
	NSMutableArray *array = [NSMutableArray array];
	
	for(NSString *filePath in filePaths) {
		[array addObject:[NSURL fileURLWithPath:filePath]];
	}
	
	[self registerURLs:array];
}
- (void)registerURLs:(NSArray *)URLs
{
	NSMutableArray *addedObjects = [NSMutableArray array];
	
	XSPFMXspfObject *insertedObject = nil;
	for(id URL in URLs) {
		insertedObject = [self registerWithURL:URL];
		if(insertedObject) [addedObjects addObject:insertedObject];
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:XspfManagerDidAddXspfObjectsNotification
					  object:self
					userInfo:[NSDictionary dictionaryWithObject:addedObjects forKey:@"XspfManagerAddedXspfObjects"]];
}

#pragma mark#### UKKQUEUE ####
- (void)registerToUKKQueue
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"Xspf" inManagedObjectContext:moc]];
	
	NSArray *array = [moc executeFetchRequest:fetch error:&error];
	if(!array) {
		if(error) {
			NSLog(@"could not fetch : %@", [error localizedDescription]);
		}
		NSLog(@"Could not fetch.");
		return;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	UKKQueue *queue = [UKKQueue sharedFileWatcher];
	for(XSPFMXspfObject *obj in array) {
		NSString *filePath = obj.filePath;
		if([fm fileExistsAtPath:filePath]) {
			[queue addPathToQueue:filePath];
		} else {
			obj.deleted = YES;
		}
	}
}

-(void) watcher:(id<UKFileWatcher>)kq receivedNotification:(NSString*)notificationName forPath: (NSString*)filePath
{
	HMLog(HMLogLevelDebug, @"UKKQueue notification. %@", notificationName);
	if(![NSThread isMainThread]) {
		NSLog(@"there is not main thread.");
	}
	
	NSString *fileURL = [[NSURL fileURLWithPath:filePath] absoluteString];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlString = %@", fileURL];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Xspf"
											  inManagedObjectContext:[self managedObjectContext]]; 
	[fetch setPredicate:predicate];
	[fetch setEntity:entity];
	
	NSError *error = nil;
	NSArray *array = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	if(!array) {
		if(error) {
			NSLog(@"%@", [error localizedDescription]);
		}
		NSLog(@"Could not fetch.");
		return;
	}
	if([array count] == 0) {
		NSLog(@"Target file is not found.");
		return;
	}
	if([array count] > 1) {
		NSLog(@"Target found too many!!! (%d).", [array count]);
	}
	
	XSPFMXspfObject *obj = [array objectAtIndex:0];
	NSString *resolvedPath = [obj.alias resolvedPath];
	
	if([UKFileWatcherRenameNotification isEqualToString:notificationName]) {
		NSLog(@"File(%@) renamed", filePath);
		obj.url = [NSURL fileURLWithPath:resolvedPath];
		[[UKKQueue sharedFileWatcher] removePathFromQueue:filePath];
		[[UKKQueue sharedFileWatcher] addPathToQueue:obj.filePath];
		return;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if(!resolvedPath) {
		if(![fm fileExistsAtPath:filePath]) {
			NSLog(@"object already deleted. (%@)", filePath);
			[[UKKQueue sharedFileWatcher] removePathFromQueue:filePath];
			obj.deleted = YES;
			return;
		} else {
			obj.alias = [filePath aliasData];
		}
	}
	
	id attr = [fm fileAttributesAtPath:resolvedPath traverseLink:YES];
	NSDate *newModDate = [attr fileModificationDate];
	if(newModDate) {
		obj.modificationDate = newModDate;
	}
	obj.alias = [filePath aliasData];
}
@end

