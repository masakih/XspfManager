//
//  XspfMLabelField.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/11.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMLabelField : NSControl
{
	NSInteger value;
	NSArray *labelCells;
}
- (void)setLabelStyle:(NSInteger)style;
- (NSInteger)labelStyle;
- (void)setDrawX:(BOOL)flag;
- (BOOL)isDrawX;
@end
