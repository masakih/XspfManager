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
	
	IBOutlet NSImageView *thumbnail;
	IBOutlet NSTextField *titleField;
	IBOutlet NSTextField *ratingLabel;
	IBOutlet NSLevelIndicator *rating;
}
@property (readonly) NSImageView *thumbnail;
@property (readonly) NSTextField *titleField;
@property (readonly) NSTextField *ratingLabel;
@property (readonly) NSLevelIndicator *rating;

- (void)setCollectionViewItem:(NSCollectionViewItem *)item;

@end
