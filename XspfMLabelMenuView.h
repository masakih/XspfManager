//
//  XspfMLabelMenuView.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/04.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class XspfMLabelCell;

@interface XspfMLabelMenuView : NSControl
{
	NSInteger _value;
	
	NSTextFieldCell *title;
	
	NSArray *labelCells;
	
	NSTextFieldCell *labelName;
	
	
	CGFloat titleHeight;
	CGFloat labelNameHeight;
	
	BOOL blinkMode;
	NSInteger blinkModeBlinkTime;
}

- (void)setMenuLabel:(NSString *)menuLabel;
- (NSString *)menuLabel;
@end
