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
	BOOL selected;
	
	NSImageCell *thumbnailCell;
	NSTextFieldCell *titleCell;
	NSLevelIndicatorCell *rateCell;
	NSTextFieldCell *rateTitleCell;
	XspfMLabelCell *labelCell;
	
	NSControlSize controlSize;
	
	id titleBinder;
	NSString *titleBindKey;
	
	id thumbnailBinder;
	NSString *thumbnailBindKey;
}

- (void)setControlSize:(NSControlSize)size;
- (NSControlSize)controlSize;

@end
