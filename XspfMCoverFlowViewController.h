//
//  XspfMCoverFlowViewController.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/21.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMViewController.h"

@class MBCoverFlowView;
@class XspfMDragControl;
@class XspfMListViewController, XspfMCoverFlowAccessoryViewController;

@interface XspfMCoverFlowViewController : XspfMViewController
{
	IBOutlet NSSplitView *splitView;
	IBOutlet MBCoverFlowView *coverFlow;
	IBOutlet NSView *listPlaceHolder;
	IBOutlet XspfMDragControl *dragControl;
	
	XspfMListViewController *listViewController;
	XspfMCoverFlowAccessoryViewController *accessoryController;
}

@end
