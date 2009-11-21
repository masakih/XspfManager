//
//  XspfManager.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfManager_AppDelegate.h"


typedef enum {
	typeNotSelected = 0,
	typeCollectionView = 1,
	typeTableView,
} XspfMViewType;

@interface XspfManager : NSWindowController
{
	IBOutlet NSArrayController *controller;
	IBOutlet id	appDelegate;
	
	IBOutlet NSWindow *progressPanel;
	IBOutlet NSTextField *progressMessage;
	IBOutlet NSProgressIndicator *progressBar;
	
	IBOutlet NSView *listView;
	NSViewController *listViewController;
	XspfMViewType currentListViewType;
	NSMutableDictionary *viewControllers;
	
	IBOutlet NSView *libraryView;
	NSViewController *libraryViewController;
	
	IBOutlet NSView *detailView;
	NSViewController *detailViewController;
	
	IBOutlet NSView *accessoryView;
	NSViewController *accessoryViewController;
	
	IBOutlet NSArrayController *listController;
}

//@property (retain) id xspfList;

- (IBAction)openXspf:(id)sender;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

- (IBAction)test01:(id)sender;
- (IBAction)test02:(id)sender;
- (IBAction)test03:(id)sender;

- (NSArrayController *)arrayController;

@end

