//
//  XspfManager.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HMChannel.h"

#import "XspfMCollectionView.h"


@interface XspfManager : NSWindowController <XspfMCollectionView_Delegate>
{
//	IBOutlet NSWindow *window;
	IBOutlet NSArrayController *controller;
	IBOutlet id	appDelegate;
	
	IBOutlet NSWindow *progressPanel;
	IBOutlet NSTextField *progressMessage;
	IBOutlet NSProgressIndicator *progressBar;
	
	NSInteger selectedSegmentTag;
	
	HMChannel *channel;
}

- (IBAction)openXspf:(id)sender;
- (IBAction)add:(id)sender;

- (IBAction)test01:(id)sender;
- (IBAction)test02:(id)sender;
- (IBAction)test03:(id)sender;

- (void)addItem:(id)item;
- (void)removeItem:(id)item;

@end
