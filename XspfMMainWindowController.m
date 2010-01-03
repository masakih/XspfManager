//
//  XspfManager.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMMainWindowController.h"

#import "XspfMMovieLoadRequest.h"
//#import "XspfMCheckFileModifiedRequest.h"

#import "XspfMViewController.h"
#import "XspfMLibraryViewController.h"
#import "XspfMCollectionViewController.h"
#import "XspfMListViewController.h"
#import "XspfMDetailViewController.h"

#import "XspfMDragControl.h"

#import "UKKQueue.h"

@interface XspfMMainWindowController(HMPrivate)
- (void)setupXspfLists;
- (void)setupDetailView;
- (void)setupAccessorylView;
- (void)changeViewType:(XspfMViewType)newType;
- (void)setCurrentListViewType:(XspfMViewType)newType;
- (void)recalculateKeyViewLoop;
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
	[self recalculateKeyViewLoop];
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
- (IBAction)switchListView:(id)sender
{
	[self setCurrentListViewType:typeTableView];
}
- (IBAction)switchRegularIconView:(id)sender
{
	[self setCurrentListViewType:typeCollectionView];
	[(XspfMCollectionViewController *)listViewController collectionViewItemViewRegular:sender];
}
- (IBAction)switchSmallIconView:(id)sender
{
	[self setCurrentListViewType:typeCollectionView];
	[(XspfMCollectionViewController *)listViewController collectionViewItemViewSmall:sender];
}
- (void)sortByKey:(NSString *)key
{
	NSMutableArray *sortDescs = [[controller sortDescriptors] mutableCopy];
	NSSortDescriptor *sortDesc = nil;
	
	// key is descs first key.
	if([sortDescs count] > 1) {
		NSSortDescriptor *firstDesc = [sortDescs objectAtIndex:0];
		if([key isEqualToString:[firstDesc key]]) {
			sortDesc = [[[NSSortDescriptor alloc] initWithKey:key ascending:![firstDesc ascending]] autorelease];
			[sortDescs removeObject:firstDesc];
		}
	}
	// remove same key.
	if(!sortDesc) {
		BOOL newAscending = NO;
		NSSortDescriptor *foundDesc = nil;
		for(id desc in sortDescs) {
			if([key isEqualToString:[desc key]]) {
				foundDesc = desc;
				break;
			}
		}
		if(foundDesc) {
			newAscending = [foundDesc ascending];
			[sortDescs removeObject:foundDesc];
		}
		
		sortDesc = [[[NSSortDescriptor alloc] initWithKey:key ascending:newAscending] autorelease];
	}
	
	[sortDescs insertObject:sortDesc atIndex:0];
	
	NSArray *selectedObjects = [controller selectedObjects];
	[controller setSortDescriptors:sortDescs];
	[controller setSelectedObjects:selectedObjects];
}
- (IBAction)sortByTitle:(id)sender
{
	[self sortByKey:@"title"];
}
- (IBAction)sortByLastPlayDate:(id)sender
{
	[self sortByKey:@"lastPlayDate"];
}
- (IBAction)sortByModificationDate:(id)sender
{
	[self sortByKey:@"modificationDate"];
}
- (IBAction)sortByCreationDate:(id)sender
{
	[self sortByKey:@"creationDate"];
}
- (IBAction)sortByRegisterDate:(id)sender
{
	[self sortByKey:@"registerDate"];
}
- (IBAction)sortByRate:(id)sender
{
	[self sortByKey:@"rating"];
}
- (IBAction)sortByMovieNumber:(id)sender
{
	[self sortByKey:@"movieNum"];
}
- (IBAction)sortByLabel:(id)sender
{
	[self doesNotRecognizeSelector:_cmd];
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
- (void)endOpenPanel:(NSOpenPanel *)panel :(NSInteger)returnCode :(void *)context
{
	[panel orderOut:nil];
	
	if(returnCode == NSCancelButton) return;
	
	NSArray *URLs = [panel URLs];
	if([URLs count] == 0) return;
	
	[appDelegate registerURLs:URLs];
}
- (IBAction)remove:(id)sender
{
	XSPFMXspfObject *obj = [controller valueForKeyPath:@"selection.self"];
	[[UKKQueue sharedFileWatcher] removePathFromQueue:obj.filePath];
	[[self managedObjectContext] deleteObject:obj];
}

- (IBAction)newPredicate:(id)sender
{
	[libraryViewController newPredicate:sender];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	BOOL enabled = YES;
	SEL action = [menuItem action];
	
	if(action == @selector(switchListView:)) {
		if(currentListViewType == typeTableView) {
			[menuItem setState:NSOnState];
		} else {
			[menuItem setState:NSOffState];
		}
	} else if(action == @selector(switchRegularIconView:)) {
		if(currentListViewType == typeCollectionView 
		   && [(XspfMCollectionViewController*)listViewController collectionItemType] == typeXspfMRegularItem) {
			[menuItem setState:NSOnState];
		} else {
			[menuItem setState:NSOffState];
		}
	} else if(action == @selector(switchSmallIconView:)) {
		if(currentListViewType == typeCollectionView
			&& [(XspfMCollectionViewController*)listViewController collectionItemType] == typeXSpfMSmallItem) {
			[menuItem setState:NSOnState];
		} else {
			[menuItem setState:NSOffState];
		}
	} else if(action == @selector(sortByLabel:)) {
		enabled = NO;
	}
	
	return enabled;
}

#pragma mark#### Other methods ####
- (void)recalculateKeyViewLoop
{
	[searchField setNextKeyView:[libraryViewController firstKeyView]];
	[libraryViewController setNextKeyView:[listViewController firstKeyView]];
	[listViewController setNextKeyView:[detailViewController firstKeyView]];
	[detailViewController setNextKeyView:searchField];
}
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
	
	XspfMViewController *targetContorller = [viewControllers objectForKey:className];
	if(!targetContorller) {
		targetContorller = [[[NSClassFromString(className) alloc] init] autorelease];
		if(!targetContorller) return;
		
		id selectionIndexes = [controller selectionIndexes];
		[viewControllers setObject:targetContorller forKey:className];
		[targetContorller view];
		[targetContorller setRepresentedObject:controller];
		[targetContorller recalculateKeyViewLoop];
		[controller setSelectionIndexes:selectionIndexes];
	}
	
	[[listViewController view] removeFromSuperview];
	listViewController = targetContorller;
	[listView addSubview:[listViewController view]];
	[[listViewController view] setFrame:[listView bounds]];
//	[[self window] recalculateKeyViewLoop];
	[self recalculateKeyViewLoop];
}


- (void)setupXspfLists
{
	if(libraryViewController) return;
	
	libraryViewController = [[XspfMLibraryViewController alloc] init];
	[libraryViewController setRepresentedObject:listController];
	[libraryView addSubview:[libraryViewController view]];
	NSRect rect = [libraryView bounds];
	rect.size.width += 2;
	rect.origin.x -= 1;
	[[libraryViewController view] setFrame:rect];
	[libraryViewController recalculateKeyViewLoop];
}
- (void)setupDetailView
{
	if(detailViewController) return;
	
	detailViewController = [[XspfMDetailViewController alloc] init];
	[detailViewController setRepresentedObject:controller];
	[detailView addSubview:[detailViewController view]];
	[[detailViewController view] setFrame:[detailView bounds]];
	[detailViewController recalculateKeyViewLoop];
}
- (void)setupAccessorylView
{
	if(accessoryViewController) return;
	
	accessoryViewController = [[NSViewController alloc] initWithNibName:@"AccessoryView" bundle:nil];
	[accessoryViewController setRepresentedObject:[appDelegate channel]];
	[accessoryView addSubview:[accessoryViewController view]];
	[[accessoryViewController view] setFrame:[accessoryView bounds]];
//	[accessoryViewController recalculateKeyViewLoop];
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

#pragma mark#### XspfMDragControl Delegate ####
- (void)dragControl:(XspfMDragControl *)control dragDelta:(NSSize)delta
{
	HMLog(HMLogLevelDebug, @"Enter %@", NSStringFromSelector(_cmd));
	CGFloat libWidth = [libraryView frame].size.width;
	[splitView setPosition:libWidth + delta.width ofDividerAtIndex:0];
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
		HMLog(HMLogLevelDebug, @"Responder -> %@", responder);
		responder = [responder nextResponder];
	}
}
- (IBAction)test03:(id)sender
{
	id keyView = [[self window] firstResponder];
	NSView *firstKeyView = keyView;
	while(keyView) {
		HMLog(HMLogLevelDebug, @"Keyview -> %@", keyView);
		keyView = [keyView nextKeyView];
		if(keyView == firstKeyView) break;
	}
	
	HMLog(HMLogLevelDebug, @"Valid next view -> %@", [firstKeyView nextValidKeyView]);
}
@end
