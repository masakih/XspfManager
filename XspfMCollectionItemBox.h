//
//  XspfMCollectionItemBox.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/11.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMCollectionItemBox : NSBox
{
	IBOutlet NSCollectionViewItem *viewItem;
}

- (void)setCollectionViewItem:(NSCollectionViewItem *)item;
@end
