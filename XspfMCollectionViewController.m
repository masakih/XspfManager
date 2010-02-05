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

@interface NSCollectionView(CocoaPrivatemethods)
- (void)_getRow:(unsigned int *)fp8 column:(unsigned int *)fp12 forPoint:(struct _NSPoint)fp16;
- (NSRect)_frameRectForIndexInGrid:(unsigned int)fp8 gridSize:(struct _NSSize)fp12;
- (NSRange)columnCountRange;
@end

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
- (NSRect)selectionItemRectForLeopard
{
	NSRect collectionFrame = [collectionView frame];
	NSSize itemSize = [collectionView minItemSize];
	
	// get right edge item colum.
	NSPoint rightEdge = NSMakePoint(collectionFrame.size.width - 1, itemSize.height / 2);
	NSUInteger col = 0;
	NSUInteger row = 0;
	[collectionView _getRow:&row column:&col forPoint:rightEdge];
	
	// get selected item's row and column.
	NSUInteger index = [[self representedObject] selectionIndex];
	NSUInteger maxCol = col;
	col = index % maxCol;
	row = index / maxCol;
	
	// caluculate selected item view's image view point.
	NSPoint itemImagePoint;
	itemImagePoint.x = itemSize.width / 2 + itemSize.width * col;
	itemImagePoint.y = itemSize.height * .2 + itemSize.height * row;	// CollectionView is fliped.
	
	// get item image view.
	NSView *thumbnail = [collectionView hitTest:itemImagePoint];
	NSView *view = [[thumbnail superview] superview];
	
	NSRect frame = [thumbnail frame];
	
	NSRect convertedRect = [view convertRect:frame toView:collectionView];
	if(!NSIntersectsRect([collectionView visibleRect], convertedRect)) {
		return NSZeroRect;
	}
	
	frame = [view convertRectToBase:frame];
	frame.origin = [[view window] convertBaseToScreen:frame.origin];
	return frame;
}
- (NSRect)selectionItemRect
{
	if(![collectionView respondsToSelector:@selector(itemAtIndex:)]) {
		return [self selectionItemRectForLeopard];
	}
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
