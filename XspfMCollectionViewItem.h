//
//  XspfMCollectionViewItem.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/10.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XspfMCollectionItemBox;

@interface XspfMCollectionViewItem : NSCollectionViewItem
{
	IBOutlet NSMenu *menu;
	
	// because [self conllectionView] is already nil at [self dealloc].
	NSCollectionView *collectionViewHolder;	// not retained.
	
	XspfMCollectionItemBox *_box;
}

- (IBAction)changeRate:(id)sender;
- (void)setBox:(XspfMCollectionItemBox *)box;

- (void)coodinateColors;
@end
