//
//  XspfMDragControl.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/03.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMDragControl : NSControl
{
	id delegate;
	
	BOOL drawsBackground;
	BOOL _vertical;
	NSImageAlignment _position;
	
}

- (void)setDelegate:(id)newDelegate;
- (id)delegate;

- (void)setDrawsBackground:(BOOL)flag;
- (void)setVertical:(BOOL)flag;
- (void)setDragPosition:(NSImageAlignment)position;

@end

@interface NSObject (XspfMDragControlDelegate)
- (void)dragControl:(XspfMDragControl *)control dragDelta:(NSSize)delta;
@end
