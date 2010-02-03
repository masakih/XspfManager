//
//  XspfManager.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMMainWindowController.h"

#import "XspfMXspfObject.h"

#import "XspfMViewController.h"
#import "XspfMLibraryViewController.h"
#import "XspfMCollectionViewController.h"
#import "XspfMListViewController.h"
#import "XspfMDetailViewController.h"
#import "XspfMCoverFlowViewController.h"


#import "XspfMDragControl.h"


@interface XspfMMainWindowController(HMPrivate)
- (void)setupXspfLists;
- (void)setupDetailView;
- (void)setupAccessorylView;
- (void)changeViewType:(XspfMViewType)newType;
- (void)setCurrentListViewType:(XspfMViewType)newType;
- (void)recalculateKeyViewLoop;

- (void)removeSelectedItem;
@end

static NSInteger osVersion = 0;
static id previewPanel = nil;

@implementation XspfMMainWindowController
+ (void)initialize
{
	if([[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/QuickLookUI.framework"] load]) {
		NSLog(@"Quick Look loaded!");
		osVersion = 105;
	}
	if([[NSBundle bundleWithPath:@"/System/Library/Frameworks/Quartz.framework/Frameworks/QuickLookUI.framework"] load]) {
		NSLog(@"Quick Look loaded!");
		osVersion = 106;
	}
}

- (id)init
{
	self = [super initWithWindowNibName:@"MainWindow"];
	if(self) {
		viewControllers = [[NSMutableDictionary alloc] init];
	}
		
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
	[[self window] setContentBorderThickness:32 forEdge:NSMinYEdge];
	
	[splitView setDelegate:self];
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
	
	XspfMXspfObject *rep = [controller valueForKeyPath:@"selection.self"];
	BOOL didOpen = [[NSWorkspace sharedWorkspace] openFile:rep.filePath withApplication:@"XspfQT"];
	if(didOpen) {
		rep.lastPlayDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
		return;
	}
	
	NSInteger result = NSRunCriticalAlertPanel(NSLocalizedString(@"Xspf is not found", @"Xspf is not found"),
											   NSLocalizedString(@"\"%@\" is not found.",  @"\"%@\" is not found."),
											   nil, nil/*@"Search Original"*/, nil, rep.title);
	if(result == NSAlertDefaultReturn) {
		return;
	} else if(result == NSAlertAlternateReturn) {
		//
#warning shuld implement.
	}
	
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
- (IBAction)switchCoverFlowView:(id)sender
{
	[self setCurrentListViewType:typeCoverFlowView];
}

- (void)sortByKey:(NSString *)key
{
	NSMutableArray *sortDescs = [[[controller sortDescriptors] mutableCopy] autorelease];
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
	[self sortByKey:@"label"];
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
	[self removeSelectedItem];
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
	} else if(action == @selector(switchCoverFlowView:)) {
		if(currentListViewType == typeCoverFlowView) {
			[menuItem setState:NSOnState];
		} else {
			[menuItem setState:NSOffState];
		}
	}
	
	return enabled;
}

#pragma mark#### Other methods ####
- (void)removeSelectedItem
{
	XspfMXspfObject *obj = [controller valueForKeyPath:@"selection.self"];
	
	NSBeginInformationalAlertSheet(nil, nil, @"Cancel", nil, [self window],
								   self, @selector(didEndAskDelete:::), Nil, obj,
								   NSLocalizedString(@"Do you really delete item  \"%@\" from list?", @"Do you really delete item  \"%@\" from list?"),
								   obj.title);
}
- (void)didEndAskDelete:(NSWindow *)sheet :(NSInteger)returnCode :(void *)contextInfo
{
	if(returnCode == NSCancelButton) return;
	
	[appDelegate removeObject:contextInfo];
}

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
		case typeCoverFlowView:
			className = @"XspfMCoverFlowViewController";
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
	[[libraryViewController dragControl] setDelegate:self];
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
#pragma mark#### NSSplitView Delegate ####
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return 130;
}
- (void)splitView:(NSSplitView *)aSplitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
	NSView *rightView = [[splitView subviews] objectAtIndex:1];
	NSRect newFrame = [splitView frame];
	NSRect libFrame = [libraryView frame];
	NSRect listFrame = [rightView frame];
	CGFloat dividerThickness = [splitView dividerThickness];
	
	libFrame.size.height = newFrame.size.height;
	listFrame.size.height = newFrame.size.height;
	
	listFrame.size.width = newFrame.size.width - libFrame.size.width - dividerThickness;
	
	if(listFrame.size.width < 0) listFrame.size.width = 0;
	
	[libraryView setFrame:libFrame];
	[rightView setFrame:listFrame];
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

#pragma mark#### PreviewPanel Support ####
- (IBAction)togglePreviewPanel:(id)panel
{
	Class aClass = NSClassFromString(@"QLPreviewPanel");
	if(!aClass) {
		NSBeep();
		return;
	}
	id qlPanel = [aClass sharedPreviewPanel];
	if(osVersion == 105) {
		[qlPanel setURLs:[[controller arrangedObjects] mutableArrayValueForKey:@"url"]
			currentIndex:[controller selectionIndex]
  preservingDisplayState:YES];
	} else if(osVersion <= 106) {
		//		[qlPanel setCurrentPreviewItemIndex:[controller selectionIndex]];
		[qlPanel makeKeyAndOrderFront:nil];
	}
}

#pragma mark---- QLPreviewPanelController ----
- (BOOL)acceptsPreviewPanelControl:(id /*QLPreviewPanel* */)panel
{
	return YES;
}
- (void)beginPreviewPanelControl:(id /*QLPreviewPanel* */)panel
{
	// This document is now responsible of the preview panel
	// It is allowed to set the delegate, data source and refresh panel.
	previewPanel = [panel retain];
	[panel setDelegate:self];
	[panel setDataSource:self];
	[previewPanel setCurrentPreviewItemIndex:[controller selectionIndex]];
}
- (void)endPreviewPanelControl:(id /*QLPreviewPanel* */)panel
{
	// This document loses its responsisibility on the preview panel
	// Until the next call to -beginPreviewPanelControl: it must not
	// change the panel's delegate, data source or refresh it.
	[previewPanel release];
	previewPanel = nil;
}

#pragma mark---- QLPreviewPanelDataSource ----
- (NSInteger)numberOfPreviewItemsInPreviewPanel:(id /*QLPreviewPanel* */)panel
{
	return [[controller arrangedObjects] count];
}
- (id /*<QLPreviewItem>*/)previewPanel:(id)panel previewItemAtIndex:(NSInteger)index
{
	return [[controller arrangedObjects] objectAtIndex:index];
}

#pragma mark---- QLPreviewPanelDelegate ----
- (BOOL)previewPanel:(id /*QLPreviewPanel* */)panel handleEvent:(NSEvent *)event
{
	// redirect all key down events to the table view
	if ([event type] == NSKeyDown) {
		NSResponder *target = nil;
		target = [listViewController initialFirstResponder];
		if(!target) {
			target = [listViewController firstKeyView];
		}
		if(!target) {
			target = [listViewController view];
		}
		if(!target) return NO;
		
		NSLog(@"target -> %@", target);
		[target keyDown:event];
		return YES;
	}
	return NO;
}
- (NSRect)previewPanel:(id /*QLPreviewPanel* */)panel sourceFrameOnScreenForPreviewItem:(id /*<QLPreviewItem>*/)item
{
//	NSInteger index = [downloads indexOfObject:item];
//	if (index == NSNotFound) {
//		return NSZeroRect;
//	}
//	
//	NSRect iconRect = [downloadsTableView frameOfCellAtColumn:0 row:index];
//	
//	// check that the icon rect is visible on screen
//	NSRect visibleRect = [downloadsTableView visibleRect];
//	
//	if (!NSIntersectsRect(visibleRect, iconRect)) {
//		return NSZeroRect;
//	}
//	
//	// convert icon rect to screen coordinates
//	iconRect = [downloadsTableView convertRectToBase:iconRect];
//	iconRect.origin = [[downloadsTableView window] convertBaseToScreen:iconRect.origin];
//	
//	return iconRect;
	return NSZeroRect;
}

// This delegate method provides a transition image between the table view and the preview panel
- (id)previewPanel:(id /*QLPreviewPanel* */)panel transitionImageForPreviewItem:(id /*<QLPreviewItem>*/)item contentRect:(NSRect *)contentRect
{
//	DownloadItem* downloadItem = (DownloadItem *)item;
//	
//	return downloadItem.iconImage;
	XspfMXspfObject *obj = item;
	return obj.thumbnail;
}
#pragma mark#### Test ####
- (IBAction)test01:(id)sender
{
	XspfMXspfObject *obj = [controller valueForKeyPath:@"selection.self"];
	srandom([[NSDate date] timeIntervalSince1970]);
	obj.label = [NSNumber numberWithInteger:random() % 8];
	HMLog(HMLogLevelDebug, @"HMLogLevelDebug -> %@", obj);
	
	NSButtonCell *cell = [sender cell];
	HMLog(HMLogLevelDebug, @"boardered -> %@\nbezeled -> %@\ngradientType -> %d\n bezelStyle -> %d",
		  [cell isBordered] ? @"YES" : @"NO", [cell isBezeled] ? @"YES" : @"NO",
		  [cell gradientType], [cell bezelStyle]);
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

@implementation XspfMXspfObject (XspfMPreviewPanelSupport)
- (NSString *)previewItemTitle
{
	return self.title;
}
- (NSURL *)previewItemURL
{
	return self.url;
}
@end
