//
//  XspfMCollectionViewItem.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/10.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMCollectionViewItem : NSCollectionViewItem
{
	// because [self conllectionView] is already nil at [self dealloc].
	NSCollectionView *collectionViewHolder;	// not retained.
}

- (void)coodinateColors;
@end
