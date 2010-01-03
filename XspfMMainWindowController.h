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
@class XspfMLibraryViewController, XspfMDetailViewController;

@interface XspfMMainWindowController : NSWindowController
{
	IBOutlet NSArrayController *controller;
	IBOutlet id	appDelegate;
	
	IBOutlet NSWindow *progressPanel;
	IBOutlet NSTextField *progressMessage;
	IBOutlet NSProgressIndicator *progressBar;
	
	IBOutlet NSSplitView *splitView;
	
	IBOutlet NSView *listView;
	XspfMViewController *listViewController;
	XspfMViewType currentListViewType;
	NSMutableDictionary *viewControllers;
	
	IBOutlet NSView *libraryView;
	XspfMLibraryViewController *libraryViewController;
	
	IBOutlet NSView *detailView;
	XspfMDetailViewController *detailViewController;
	
	IBOutlet NSView *accessoryView;
	NSViewController *accessoryViewController;
	
	IBOutlet NSArrayController *listController;
	
	IBOutlet NSSearchField *searchField;
}

//- (void)registerFilePaths:(NSArray *)filePaths;
//- (void)registerURLs:(NSArray *)URLs;

- (IBAction)openXspf:(id)sender;

- (IBAction)switchListView:(id)sender;
- (IBAction)switchRegularIconView:(id)sender;
- (IBAction)switchSmallIconView:(id)sender;

- (IBAction)sortByTitle:(id)sender;
- (IBAction)sortByLastPlayDate:(id)sender;
- (IBAction)sortByModificationDate:(id)sender;
- (IBAction)sortByCreationDate:(id)sender;
- (IBAction)sortByRegisterDate:(id)sender;
- (IBAction)sortByRate:(id)sender;
- (IBAction)sortByMovieNumber:(id)sender;
- (IBAction)sortByLabel:(id)sender;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

//
- (IBAction)newPredicate:(id)sender;


- (IBAction)test01:(id)sender;
- (IBAction)test02:(id)sender;
- (IBAction)test03:(id)sender;

- (NSArrayController *)arrayController;

@end

