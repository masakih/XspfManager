//
//  XspfMPreviewPanelController.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/02/13.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class XspfMMainWindowController;
@interface XspfMPreviewPanelController : NSResponder
{
	XspfMMainWindowController *mainWController;
	NSArrayController *controller;
}
@property (assign) XspfMMainWindowController *mainWController;
@property (assign) NSArrayController *controller;

- (IBAction)togglePreviewPanel:(id)panel;
@end
