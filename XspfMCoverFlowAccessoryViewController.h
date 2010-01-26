//
//  XspfMCoverFlowAccessoryViewController.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/21.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMViewController.h"


@class XspfMDragControl;

@interface XspfMCoverFlowAccessoryViewController : XspfMViewController
{
	IBOutlet NSTextField *field;
	IBOutlet XspfMDragControl *dragControl;
}

- (XspfMDragControl *)dragControl;
- (void)setXspfMDragControlDelegate:(id)delegate;
@end
