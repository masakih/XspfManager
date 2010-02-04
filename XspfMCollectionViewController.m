//
//  XspfMCollectionViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/05.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionViewController.h"

#import "XspfMCollectionView.h"
#import "XspfMCollectionViewItem.h"
#import "XspfMXspfObject.h"


@implementation XspfMCollectionViewController

- (id)init
{
	[super initWithNibName:@"CollectionView" bundle:nil];
	
	return self;
}

- (void)awakeFromNib
{
	NSView *view = [collectionViewItem view];
	
	[scrollView setVerticalLineScroll:[view frame].size.height];
}

- (void)setCollectionItem:(XspfMCollectionViewItem *)newItem
{
	[collectionView setItemPrototype:newItem];
	NSSize viewSize = [[newItem view] frame].size;
	[collectionView setMinItemSize:viewSize];
	[collectionView setMaxItemSize:viewSize];
	[scrollView setVerticalLineScroll:viewSize.height];
	collectionViewItem = newItem;
}

- (IBAction)changeLabel:(id)sender
{
	XspfMXspfObject *object = [sender representedObject];
	object.label = [sender objectValue];
}

- (IBAction)collectionViewItemViewRegular:(id)sender
{
	[self setCollectionItem:regularItem];
}
- (IBAction)collectionViewItemViewSmall:(id)sender
{
	[self setCollectionItem:smallItem];
}

- (XspfMCollectionItemType)collectionItemType
{
	if(collectionViewItem == regularItem) return typeXspfMRegularItem;
	if(collectionViewItem == smallItem) return typeXSpfMSmallItem;
	
	return typeXspfMUnknownItem;
}

#pragma mark#### XspfMCollectionView Delegate ####
- (void)enterAction:(XspfMCollectionView *)view
{
	[NSApp sendAction:@selector(openXspf:) to:nil from:self];
}

// QLPreviewPanel support
- (NSRect)selectionItemRect
{
	id item = [collectionView itemAtIndex:[[self representedObject] selectionIndex]];
	NSRect rect = [item thumbnailFrameCoordinateBase];
	return rect;
}

#pragma mark#### Test ####
- (void)test01:(id)sender
{
	HMLog(HMLogLevelError, @"hoge");
}
	

@end
