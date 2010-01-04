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
	XspfMLabelCell *label01;
	XspfMLabelCell *label02;
	XspfMLabelCell *label03;
	XspfMLabelCell *label04;
	XspfMLabelCell *label05;
	XspfMLabelCell *label06;
	XspfMLabelCell *label07;
	XspfMLabelCell *label08;
	
	NSArray *labelCells;
	
	NSTextFieldCell *labelName;
	
	CGFloat titleHeight;
	CGFloat labelNameHeight;
	
	BOOL blinkMode;
	NSInteger blinkModeBlinkTime;
}

@end
