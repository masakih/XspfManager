//
//  XspfMCollectionViewController.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/05.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMCollectionView.h"
#import "XspfMMainWindowController.h"

#import "XspfMViewController.h"

@class XspfMCollectionViewItem;

@interface XspfMCollectionViewController : XspfMViewController <XspfMCollectionView_Delegate>
{
	IBOutlet NSScrollView *scrollView;
	IBOutlet NSCollectionView *collectionView;
	IBOutlet XspfMCollectionViewItem *collectionViewItem;
	
	IBOutlet XspfMCollectionViewItem *regularItem;
	IBOutlet XspfMCollectionViewItem *smallItem;
}

- (IBAction)collectionViewItemViewRegular:(id)sender;
- (IBAction)collectionViewItemViewSmall:(id)sender;

@end
