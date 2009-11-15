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

#import "XspfMViewController.h"

@interface XspfMCollectionViewController : XspfMViewController <XspfMCollectionView_Delegate>
{
	IBOutlet NSCollectionView *collectionView;
}
@end
