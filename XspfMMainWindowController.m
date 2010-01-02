//
//  XspfManager.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMMainWindowController.h"

#import "XspfMMovieLoadRequest.h"
#import "XspfMCheckFileModifiedRequest.h"

#import "XspfMLibraryViewController.h"
#import "XspfMCollectionViewController.h"
#import "XspfMListViewController.h"
#import "XspfMDetailViewController.h"

#import "UKKQueue.h"
#import "NSPathUtilities-XspfQT-Extensions.h"

@interface XspfMMainWindowController(HMPrivate)
- (void)setupXspfLists;
- (void)setupDetailView;
- (void)setupAccessorylView;
- (void)changeViewType:(XspfMViewType)newType;
- (void)setCurrentListViewType:(XspfMViewType)newType;
@end

@interface XspfMMainWindowController(XspfMDeprecated)
- (BOOL)didRegisteredURL:(NSURL *)url;
- (XSPFMXspfObject *)registerWithURL:(NSURL *)url;
- (void)registerFilePaths:(NSArray *)filePaths;
- (void)registerURLs:(NSArray *)URLs;

- (void)registerToUKKQueue;
-(void) watcher:(id<UKFileWatcher>)kq receivedNotification:(NSString*)notificationName forPath: (NSString*)filePath;

@end


@interface XspfMMainWindowController(UKKQueueSupport) 
- (void)registerToUKKQueue;
@end

@implementation XspfMMainWindowController

static XspfMMainWindowController *sharedInstance = nil;

+ (XspfMMainWindowController *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


- (id)init
{
	[super initWithWindowNibName:@"MainWindow"];
	
	viewControllers = [[NSMutableDictionary alloc] init];
		
	return self;
}
- (void)awakeFromNib
{
	static BOOL didSetupOnMainMenu = NO;
	
	if(appDelegate && !didSetupOnMainMenu) {
		didSetupOnMainMenu = YES;
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(managerDidAddObjects:)
				   name:XspfManagerDidAddXspfObjectsNotification
				 object:appDelegate];
		
		[self window];
		
	}
}
- (void)windowDidLoad
{
	[[self window] setContentBorderThickness:38 forEdge:NSMinYEdge];
	
	[self setupXspfLists];
	[self setupDetailView];
	[self setupAccessorylView];
	if(currentListViewType == typeNotSelected) {
		[self setCurrentListViewType:typeTableView];
	}
	
	[self showWindow:nil];
}
#pragma mark#### KVC ####
- (NSManagedObjectContext *)managedObjectContext
{
	return [appDelegate managedObjectContext];
}
- (NSArrayController *)arrayController
{
	return controller;
}

- (XspfMViewType)currentListViewType
{
	return currentListViewType;
}
- (void)setCurrentListViewType:(XspfMViewType)newType
{
	if(currentListViewType == newType) return;
	
	[self changeViewType:newType];
}

#pragma mark#### Actions ####
- (IBAction)openXspf:(id)sender
{
	BOOL isSelected = [[controller valueForKeyPath:@"selectedObjects.@count"] boolValue];
	if(!isSelected) return;
	
	XSPFMXspfObject *rep = [controller valueForKeyPath:@"selection.self"];
	if(rep.deleted) {		
		NSRunCriticalAlertPanel( NSLocalizedString(@"Xspf is Deleted", @"Xspf is Deleted"),
								NSLocalizedString(@"\"%@\" is deleted",  @"\"%@\" is deleted"),
								nil, nil, nil, rep.title);
		return;
	}
	[[NSWorkspace sharedWorkspace] openFile:rep.filePath withApplication:@"XspfQT"];
	rep.lastPlayDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
}
- (IBAction)add:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"xspf", @"com.masakih.xspf", nil]];
	[panel setAllowsMultipleSelection:YES];
	[panel setDelegate:self];
	
	[panel beginSheetForDirectory:nil
							 file:nil
							types:[NSArray arrayWithObjects:@"xspf", @"com.masakih.xspf", nil]
				   modalForWindow:[self window]
					modalDelegate:self
				   didEndSelector:@selector(endOpenPanel:::)
					  contextInfo:NULL];
}
- (IBAction)remove:(id)sender
{
	XSPFMXspfObject *obj = [controller valueForKeyPath:@"selection.self"];
	[[UKKQueue sharedFileWatcher] removePathFromQueue:obj.filePath];
	[[self managedObjectContext] deleteObject:obj];
}


- (void)endOpenPanel:(NSOpenPanel *)panel :(NSInteger)returnCode :(void *)context
{
	[panel orderOut:nil];
	
	if(returnCode == NSCancelButton) return;
	
	NSArray *URLs = [panel URLs];
	if([URLs count] == 0) return;
	
	[appDelegate registerURLs:URLs];
}

#pragma mark#### Other methods ####

- (void)changeViewType:(XspfMViewType)viewType
{
	if(currentListViewType == viewType) return;
	currentListViewType = viewType;
	
	NSString *className = nil;
	switch(currentListViewType) {
		case typeCollectionView:
			className = @"XspfMCollectionViewController";
			break;
		case typeTableView:
			className = @"XspfMListViewController";
			break;
	}
	if(!className) return;
	
	NSViewController *targetContorller = [viewControllers objectForKey:className];
	if(!targetContorller) {
		targetContorller = [[[NSClassFromString(className) alloc] init] autorelease];
		if(!targetContorller) return;
		[viewControllers setObject:targetContorller forKey:className];
		[targetContorller view];
		[targetContorller setRepresentedObject:controller];
	}
	
	[[listViewController view] removeFromSuperview];
	listViewController = targetContorller;
	[listView addSubview:[listViewController view]];
	[[listViewController view] setFrame:[listView bounds]];
	[[self window] recalculateKeyViewLoop];
}


- (void)setupXspfLists
{
	if(libraryViewController) return;
	
	libraryViewController = [[XspfMLibraryViewController alloc] init];
	[libraryViewController setRepresentedObject:listController];
	[libraryView addSubview:[libraryViewController view]];
	[[libraryViewController view] setFrame:[libraryView bounds]];
}
- (void)setupDetailView
{
	if(detailViewController) return;
	
	detailViewController = [[XspfMDetailViewController alloc] init];
	[detailViewController setRepresentedObject:controller];
	[detailView addSubview:[detailViewController view]];
	[[detailViewController view] setFrame:[detailView bounds]];
}
- (void)setupAccessorylView
{
	if(accessoryViewController) return;
	
	accessoryViewController = [[NSViewController alloc] initWithNibName:@"AccessoryView" bundle:nil];
	[accessoryViewController setRepresentedObject:[appDelegate channel]];
	[accessoryView addSubview:[accessoryViewController view]];
	[[accessoryViewController view] setFrame:[accessoryView bounds]];
}
#pragma mark#### NSWidnow Delegate ####
/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[appDelegate managedObjectContext] undoManager];
}

#pragma mark#### NSOpenPanel Delegate ####
- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
	return ![appDelegate didRegisteredURL:[NSURL fileURLWithPath:filename]];
}

#pragma mark#### XspfManager Notifications ####
- (void)managerDidAddObjects:(NSNotification *)notification
{
	id addedObjects = [[notification userInfo] objectForKey:@"XspfManagerAddedXspfObjects"];
	if(!addedObjects || ![addedObjects isKindOfClass:[NSArray class]] || [addedObjects count] == 0) return;
	
	[controller performSelector:@selector(setSelectedObjects:)
					 withObject:addedObjects
					 afterDelay:0.01];
}

#pragma mark#### Test ####
- (IBAction)test01:(id)sender
{
	HMLog(HMLogLevelDebug, @"HMLogLevelDebug");
	HMLog(HMLogLevelNotice, @"HMLogLevelNotice");
	HMLog(HMLogLevelCaution, @"HMLogLevelCaution");
	HMLog(HMLogLevelAlert, @"HMLogLevelAlert");
	HMLog(HMLogLevelError, @"HMLogLevelError");
	
	HMLog(HMLogLevelDebug, @"HMLogLevelDebug -> %@", @"DEBUG");
}
- (IBAction)test02:(id)sender
{
	NSResponder *responder = [[self window] firstResponder];
	while(responder) {
		NSLog(@"Responder -> %@", responder);
		responder = [responder nextResponder];
	}
}
- (IBAction)test03:(id)sender
{
	id keyView = [[self window] firstResponder];
	NSView *firstKeyView = keyView;
	while(keyView) {
		NSLog(@"Keyview -> %@", keyView);
		keyView = [keyView nextKeyView];
		if(keyView == firstKeyView) break;
	}
	
	NSLog(@"Valid next view -> %@", [firstKeyView nextValidKeyView]);
}
@end

@implementation XspfMMainWindowController(XspfMDeprecated)

- (BOOL)didRegisteredURL:(NSURL *)url
{
	NSLog(@"-[%@ %@] is Deprecated.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
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
#pragma mark#### UKKQUEUE ####
- (void)registerToUKKQueue
{
	NSLog(@"-[%@ %@] is Deprecated.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
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
- (XSPFMXspfObject *)registerWithURL:(NSURL *)url
{
	NSLog(@"-[%@ %@] is Deprecated.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	
	if([appDelegate didRegisteredURL:url]) return nil;
	
	XSPFMXspfObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Xspf"
														 inManagedObjectContext:[appDelegate managedObjectContext]];
	if(!obj) return nil;
	
	obj.url = url;
	obj.registerDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
	
	// will set in XspfMCheckFileModifiedRequest.
	//	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"modificationDate"];
	//	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"creationDate"];
	
	id<HMChannel> channel = [appDelegate channel];
	id<HMRequest> request = [XspfMCheckFileModifiedRequest requestWithObject:obj];
	[channel putRequest:request];
	request = [XspfMMovieLoadRequest requestWithObject:obj];
	[channel putRequest:request];
	
	[[UKKQueue sharedFileWatcher] addPathToQueue:obj.filePath];
	
	return obj;
}
- (void)registerFilePaths:(NSArray *)filePaths
{
	NSLog(@"-[%@ %@] is Deprecated.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	
	NSMutableArray *array = [NSMutableArray array];
	
	for(NSString *filePath in filePaths) {
		[array addObject:[NSURL fileURLWithPath:filePath]];
	}
	
	[self registerURLs:array];
}
- (void)registerURLs:(NSArray *)URLs
{
	NSLog(@"-[%@ %@] is Deprecated.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	
	[progressBar setUsesThreadedAnimation:YES];
	[progressBar startAnimation:self];
	[progressMessage setStringValue:@"During register."];
	
	[NSApp beginSheet:progressPanel
	   modalForWindow:[self window]
		modalDelegate:nil
	   didEndSelector:Nil
		  contextInfo:NULL];
	
	XSPFMXspfObject *insertedObject = nil;
	for(id URL in URLs) {
		insertedObject = [appDelegate registerWithURL:URL];
	}
	if(insertedObject) {
		[controller performSelector:@selector(setSelectedObjects:)
						 withObject:[NSArray arrayWithObject:insertedObject]
						 afterDelay:0.0];
	}
	
	[progressBar stopAnimation:self];
	[progressPanel orderOut:self];
	[NSApp endSheet:progressPanel];
}
-(void) watcher:(id<UKFileWatcher>)kq receivedNotification:(NSString*)notificationName forPath: (NSString*)filePath
{
	NSLog(@"-[%@ %@] is Deprecated.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	
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
		obj.url = [NSURL fileURLWithPath:resolvedPath];
		[[UKKQueue sharedFileWatcher] removePathFromQueue:filePath];
		[[UKKQueue sharedFileWatcher] addPathToQueue:obj.filePath];
		return;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if(!resolvedPath) {
		if(![fm fileExistsAtPath:filePath]) {
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
