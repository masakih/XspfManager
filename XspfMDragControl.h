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
}

- (void)setDelegae:(id)newDelegate;
- (id)delegate;

@end

@interface NSObject (XspfMDragControlDelegate)
- (void)dragControl:(XspfMDragControl *)control dragDelta:(NSSize)delta;
@end
