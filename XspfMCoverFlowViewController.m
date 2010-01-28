//
//  XspfMCoverFlowViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/21.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMCoverFlowViewController.h"

#import "MBCoverFlowView.h"
#import "XspfMListViewController.h"
#import "XspfMCoverFlowAccessoryViewController.h"

#import "XspfMDragControl.h"


@implementation XspfMCoverFlowViewController

- (id)init
{
	self = [super initWithNibName:@"XspfMCoverFlowView" bundle:nil];
	
	return self;
}

- (void)awakeFromNib
{
	NSArrayController *rep = [self representedObject];
	
	coverFlow.imageKeyPath = @"thumbnail";
	coverFlow.showsScrollbar = YES;
	
	[dragControl setDrawsBackground:NO];
	[dragControl setDragPosition:NSImageAlignCenter];
	[dragControl setVertical:NO];
	
	listViewController = [[XspfMListViewController alloc] init];
	[listViewController view];
	[listViewController setRepresentedObject:rep];
	[listViewController recalculateKeyViewLoop];
	[listPlaceHolder addSubview:[listViewController view]];
	[[listViewController view] setFrame:[listPlaceHolder bounds]];
	[self recalculateKeyViewLoop];
	
	accessoryController = [[XspfMCoverFlowAccessoryViewController alloc] init];
	[accessoryController setXspfMDragControlDelegate:self];
	coverFlow.dragControl = [accessoryController dragControl];
	coverFlow.accessoryController = accessoryController;
}

- (void)setRepresentedObject:(id)representedObject
{
	[super setRepresentedObject:representedObject];
	[listViewController setRepresentedObject:representedObject];
	
	if(representedObject) {
		coverFlow.itemSize = NSMakeSize(200, 150);
		[coverFlow bind:@"content" toObject:representedObject withKeyPath:@"arrangedObjects" options:nil];
		[coverFlow bind:@"selectionIndex" toObject:representedObject withKeyPath:@"selectionIndex" options:nil];
	} else {
		[coverFlow unbind:@"content"];
		[coverFlow unbind:@"selectionIndex"];
	}
}

- (void)dragControl:(XspfMDragControl *)control dragDelta:(NSSize)delta
{
	HMLog(HMLogLevelDebug, @"Enter %@", NSStringFromSelector(_cmd));
	
	CGFloat libWidth = [coverFlow frame].size.height;
	[splitView setPosition:libWidth - delta.height ofDividerAtIndex:0];
}


@end
