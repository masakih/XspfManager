//
//  XspfManager.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfManager_AppDelegate.h"
#import "HMChannel.h"


@interface XspfManager : NSWindowController
{
//	IBOutlet NSWindow *window;
	IBOutlet NSArrayController *controller;
	IBOutlet id	appDelegate;
	
	IBOutlet NSWindow *progressPanel;
	IBOutlet NSTextField *progressMessage;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSView *listView;
	
	NSViewController *listViewController;
	
	NSInteger selectedSegmentTag;
	
	HMChannel *channel;
}

- (IBAction)openXspf:(id)sender;

- (IBAction)add:(id)sender;

- (IBAction)test01:(id)sender;
- (IBAction)test02:(id)sender;
- (IBAction)test03:(id)sender;

- (NSArrayController *)arrayController;

- (void)addItem:(id)item;
- (void)removeItem:(id)item;

@end

