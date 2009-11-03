//
//  XspfMCollectionView.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/03.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol XspfMCollectionView_Delegate;

@interface XspfMCollectionView : NSCollectionView
{
	IBOutlet id<XspfMCollectionView_Delegate> delegate;
}

@end

@protocol XspfMCollectionView_Delegate
- (void)enterAction:(XspfMCollectionView *)view;
@end