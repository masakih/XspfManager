//
//  XspfMCollectionViewController.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/05.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMCollectionView.h"
#import "XspfManager.h"

@interface XspfMCollectionViewController : NSViewController <XspfMCollectionView_Delegate>
{
	IBOutlet NSCollectionView *collectionView;
	XspfManager *xspfManager;
}
@end
