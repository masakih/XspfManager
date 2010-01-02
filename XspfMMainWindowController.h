//
//  XspfManager.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfManager.h"


typedef enum {
	typeNotSelected = 0,
	typeCollectionView = 1,
	typeTableView,
} XspfMViewType;

@class XspfMViewController;

@interface XspfMMainWindowController : NSWindowController
{
	IBOutlet NSArrayController *controller;
	IBOutlet id	appDelegate;
	
	IBOutlet NSWindow *progressPanel;
	IBOutlet NSTextField *progressMessage;
	IBOutlet NSProgressIndicator *progressBar;
	
	IBOutlet NSView *listView;
	XspfMViewController *listViewController;
	XspfMViewType currentListViewType;
	NSMutableDictionary *viewControllers;
	
	IBOutlet NSView *libraryView;
	XspfMViewController *libraryViewController;
	
	IBOutlet NSView *detailView;
	XspfMViewController *detailViewController;
	
	IBOutlet NSView *accessoryView;
	NSViewController *accessoryViewController;
	
	IBOutlet NSArrayController *listController;
	
	IBOutlet NSSearchField *searchField;
}

//- (void)registerFilePaths:(NSArray *)filePaths;
//- (void)registerURLs:(NSArray *)URLs;

- (IBAction)openXspf:(id)sender;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

- (IBAction)test01:(id)sender;
- (IBAction)test02:(id)sender;
- (IBAction)test03:(id)sender;

- (NSArrayController *)arrayController;

@end

