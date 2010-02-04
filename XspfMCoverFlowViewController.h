//
//  XspfMCoverFlowViewController.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/21.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMViewController.h"

@class XspfMListViewController;

@interface XspfMCoverFlowViewController : XspfMViewController
{
	IBOutlet NSSplitView *splitView;
	IBOutlet id coverFlow;
	IBOutlet NSView *listPlaceHolder;
	
	XspfMListViewController *listViewController;
}

@end
