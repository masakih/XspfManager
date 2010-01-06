//
//  XspfMLabelCell.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/04.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


enum _XspfMLabelStyle {
	XspfMCircleStyle,
	XspfMSquareStyle,
};


@interface XspfMLabelCell : NSActionCell
{
	NSGradient *gradient;
	
	NSInteger labelStyle;
	BOOL drawX;

}

- (void)setLabelStyle:(NSInteger)style;
- (NSInteger)labelStyle;
- (void)setDrawX:(BOOL)flag;
- (BOOL)isDrawX;

@end
