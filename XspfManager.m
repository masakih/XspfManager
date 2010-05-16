//
//  XspfManager.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//

/*
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューターも、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害について、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1, Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3, The names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "XspfManager.h"

#import "XspfMChannelManager.h"
#import "XspfMMainWindowController.h"
#import "XspfMPreviewPanelController.h"

#import "XspfMThreadSpleepRequest.h"
#import "XspfMCheckFileModifiedRequest.h"
#import "XspfMMovieLoadRequest.h"

#import "UKKQueue.h"
#import "XspfMXspfObject.h"
#import "XspfMLabelMenuItem.h"

#import "NSPathUtilities-HMExtensions.h"
#import "NSWorkspace-HMExtensions.h"

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
//	HMLog(HMLogLevelDebug, @"ManagedObjectModel -> %@", managedObjectModel);
	return managedObjectModel;
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
	
	url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"XspfManager.qdb"]];
	
	return url;
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

	NSError *error;
    
	NSURL *url = [self storeURL];
	
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	if(!persistentStoreCoordinator) {
		HMLog(HMLogLevelError, @"Could not create store coordinator");
		exit(-1);
	}
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 nil];
	
	if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]){
		[[NSApplication sharedApplication] presentError:error];
		HMLog(HMLogLevelError, @"Error -> %@", error);// localizedDescription]);
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
	NSUInteger reply = NSTerminateNow;
	
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
					
					NSInteger alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
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


-(IBAction)toggleEnableLog:(id)sender
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setBool:![ud boolForKey:@"HMLogEnable"] forKey:@"HMLogEnable"];
}
- (IBAction)changeLogLevel:(id)sender
{
	NSInteger level = [sender tag];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setInteger:level forKey:@"HMLogLevel"];
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	NSInteger tag = [menuItem tag];
	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	if(action == @selector(toggleEnableLog:)) {
		if([ud boolForKey:@"HMLogEnable"]) {
			[menuItem setTitle:@"Disable log"];
		} else {
			[menuItem setTitle:@"Enable log"];
		}
	} else if(action == @selector(changeLogLevel:)) {
		NSInteger level = [ud integerForKey:@"HMLogLevel"];
		if(level == tag) {
			[menuItem setState:NSOnState];
		} else {
			[menuItem setState:NSOffState];
		}
	}
	
	return YES;
}
- (void)setupDebugMenu
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if(![ud boolForKey:@"HMEnableDebugMenu"]) return;
	
	NSMenu *debugMenu = [[[NSMenu alloc] initWithTitle:@"Debug"] autorelease];
	NSMenuItem *enableLogItem = [[[NSMenuItem alloc] initWithTitle:@"Enable log"
															action:@selector(toggleEnableLog:)
													 keyEquivalent:@""] autorelease];
	[debugMenu addItem:enableLogItem];
	
	[debugMenu addItem:[NSMenuItem separatorItem]];
	
	NSMenuItem *logLevelItem = [[[NSMenuItem alloc] initWithTitle:@"Debug level"
														   action:@selector(changeLogLevel:)
													keyEquivalent:@""] autorelease];
	[logLevelItem setTag:HMLogLevelDebug];
	[debugMenu addItem:logLevelItem];
	
	logLevelItem = [[[NSMenuItem alloc] initWithTitle:@"Notice level"
											   action:@selector(changeLogLevel:)
										keyEquivalent:@""] autorelease];
	[logLevelItem setTag:HMLogLevelNotice];
	[debugMenu addItem:logLevelItem];
	
	logLevelItem = [[[NSMenuItem alloc] initWithTitle:@"Caution level"
											   action:@selector(changeLogLevel:)
										keyEquivalent:@""] autorelease];
	[logLevelItem setTag:HMLogLevelCaution];
	[debugMenu addItem:logLevelItem];
	
	logLevelItem = [[[NSMenuItem alloc] initWithTitle:@"Alert level"
											   action:@selector(changeLogLevel:)
										keyEquivalent:@""] autorelease];
	[logLevelItem setTag:HMLogLevelAlert];
	[debugMenu addItem:logLevelItem];
	
	[debugMenu addItem:[NSMenuItem separatorItem]];
	
	NSMenuItem *testItem;
	
	testItem = [[[NSMenuItem alloc] initWithTitle:@"test01"
										   action:@selector(test01:)
									keyEquivalent:@""] autorelease];
	[debugMenu addItem:testItem];
	
	testItem = [[[NSMenuItem alloc] initWithTitle:@"test02"
										   action:@selector(test02:)
									keyEquivalent:@""] autorelease];
	[debugMenu addItem:testItem];
	
	testItem = [[[NSMenuItem alloc] initWithTitle:@"test03"
										   action:@selector(test03:)
									keyEquivalent:@""] autorelease];
	[debugMenu addItem:testItem];
	
	NSMenu *menubar = [NSApp mainMenu];
	NSUInteger itemCount = [[menubar itemArray] count];
	NSMenuItem *debugMenuItem = [menubar insertItemWithTitle:@"Debug"
													  action:Nil
											   keyEquivalent:@""
													 atIndex:itemCount - 1];
	[debugMenuItem setSubmenu:debugMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self setupDebugMenu];
	
	UKKQueue *queue = [UKKQueue sharedFileWatcher];
	[queue setDelegate:self];
	
	XspfMThreadSpleepRequest *request = [XspfMThreadSpleepRequest requestWithSleepTime:0.5];
	[[self channel] putRequest:request];
	
	[self performSelector:@selector(registerToUKKQueue) withObject:nil afterDelay:0.0];
	
	pController = [[XspfMPreviewPanelController alloc] init];
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
		HMLog(HMLogLevelError, @"%@", [error localizedDescription]);
		return NO;
	}
	
	return num != 0;
}
- (XspfMXspfObject *)registerWithURL:(NSURL *)url
{
	if([self didRegisteredURL:url]) return nil;
	
	XspfMXspfObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Xspf"
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
	
	XspfMXspfObject *insertedObject = nil;
	for(id URL in URLs) {
		insertedObject = [self registerWithURL:URL];
		if(insertedObject) [addedObjects addObject:insertedObject];
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:XspfManagerDidAddXspfObjectsNotification
					  object:self
					userInfo:[NSDictionary dictionaryWithObject:addedObjects forKey:@"XspfManagerAddedXspfObjects"]];
}
- (void)removeObject:(XspfMXspfObject *)obj
{
	[[UKKQueue sharedFileWatcher] removePathFromQueue:obj.filePath];
	[[self managedObjectContext] deleteObject:obj];
}

- (void)setObectMenu:(NSMenu *)menu
{
	[objectMenu release];
	objectMenu = [menu retain];
}
- (NSMenu *)objectMenu
{
	return objectMenu;
}
- (NSMenu *)menuForXspfObject:(XspfMXspfObject *)object
{
	NSMenu *result = [self objectMenu];
	
	for(id item in [result itemArray]) {
		[item setRepresentedObject:object];
		if([item isKindOfClass:[XspfMLabelMenuItem class]]) {
			[item setObjectValue:object.label];
		}
	}
	
	return result;
}

- (IBAction)showXSPFInFinder:(id)sender
{
	XspfMXspfObject *object = [sender representedObject];
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws selectFile:object.filePath inFileViewerRootedAtPath:@""];
}
- (IBAction)showXSPFInformation:(id)sender
{
	XspfMXspfObject *object = [sender representedObject];
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws showInformationInFinder:object.filePath];
}
- (IBAction)changeLabel:(id)sender
{
	XspfMXspfObject *object = [sender representedObject];
	object.label = [sender objectValue];
}
- (IBAction)togglePreviewPanel:(id)panel
{
	[pController togglePreviewPanel:panel];
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
			HMLog(HMLogLevelError, @"could not fetch : %@", [error localizedDescription]);
		}
		HMLog(HMLogLevelError, @"Could not fetch.");
		return;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	UKKQueue *queue = [UKKQueue sharedFileWatcher];
	for(XspfMXspfObject *obj in array) {
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
		HMLog(HMLogLevelError, @"there is not main thread.");
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
			HMLog(HMLogLevelError, @"%@", [error localizedDescription]);
		}
		HMLog(HMLogLevelError, @"Could not fetch.");
		return;
	}
	if([array count] == 0) {
		HMLog(HMLogLevelError, @"Target file(%@) is not found.", filePath);
		return;
	}
	if([array count] > 1) {
		HMLog(HMLogLevelError, @"Target found too many!!! (%d).", [array count]);
	}
	
	XspfMXspfObject *obj = [array objectAtIndex:0];
	NSString *resolvedPath = [obj.alias resolvedPath];
	
	if([UKFileWatcherRenameNotification isEqualToString:notificationName]) {
		HMLog(HMLogLevelNotice, @"File(%@) renamed", filePath);
		obj.url = [NSURL fileURLWithPath:resolvedPath];
		[[UKKQueue sharedFileWatcher] removePathFromQueue:filePath];
		[[UKKQueue sharedFileWatcher] addPathToQueue:obj.filePath];
		return;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if(!resolvedPath) {
		if(![fm fileExistsAtPath:filePath]) {
			HMLog(HMLogLevelNotice, @"object already deleted. (%@)", filePath);
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

