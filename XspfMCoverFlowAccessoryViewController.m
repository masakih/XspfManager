//
//  XspfMCoverFlowAccessoryViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/21.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMCoverFlowAccessoryViewController.h"

#import "XspfMDragControl.h"


@implementation XspfMCoverFlowAccessoryViewController

- (id)init
{
	self = [super initWithNibName:@"XspfMCoverFlowAccessoryView" bundle:nil];
	[self view];
	return self;
}

- (void)awakeFromNib
{
	[dragControl setDrawsBackground:NO];
	[dragControl setDragPosition:NSImageAlignCenter];
	[dragControl setVertical:NO];
}

- (XspfMDragControl *)dragControl
{
	return dragControl;
}
- (void)setXspfMDragControlDelegate:(id)delegate
{
	[dragControl setDelegate:delegate];
}

@end
