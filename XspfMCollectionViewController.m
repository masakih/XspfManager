//
//  XspfMCollectionViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/05.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionViewController.h"

#import "XspfMCollectionViewItem.h"


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

- (void)setCollectionItem:(NSCollectionViewItem *)newItem
{
	[collectionView setItemPrototype:newItem];
	NSSize viewSize = [[newItem view] frame].size;
	[collectionView setMinItemSize:viewSize];
	[collectionView setMaxItemSize:viewSize];
	[scrollView setVerticalLineScroll:viewSize.height];
}
- (IBAction)collectionViewItemViewRegular:(id)sender
{
	[self setCollectionItem:regularItem];
}
- (IBAction)collectionViewItemViewSmall:(id)sender
{
	[self setCollectionItem:smallItem];
}

#pragma mark#### XspfMCollectionView Delegate ####
- (void)enterAction:(XspfMCollectionView *)view
{
	[NSApp sendAction:@selector(openXspf:) to:nil from:self];
}

#pragma mark#### Test ####
- (void)test01:(id)sender
{
	HMLog(HMLogLevelError, @"hoge");
}
	

@end
