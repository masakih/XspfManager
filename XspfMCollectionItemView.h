//
//  XspfMCollectionTitleField.h
//  XspfManager
//
//  Created by Hori,Masaki on 11/01/25.
//  Copyright 2011 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XspfMLabelCell;

@interface XspfMCollectionItemView : NSControl
{
	NSColor *backgroundColor;
	
	NSImageCell *thumbnailCell;
	NSTextFieldCell *titleCell;
	NSLevelIndicatorCell *rateCell;
	NSTextFieldCell *rateTitleCell;
	XspfMLabelCell *labelCell;
		
	IBOutlet id representedObject;
	
	BOOL selected;
}

//@property (nonatomic, readonly) NSLevelIndicatorCell* rating;

@end
