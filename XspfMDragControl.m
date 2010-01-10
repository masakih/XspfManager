//
//  XspfMDragControl.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/03.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMDragControl.h"


@interface XspfMDragControl (XspfMPrivate)
- (void)setup;
- (NSRect)draggingRect;
@end

@implementation XspfMDragControl

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self) {
		[self setup];
		[self resetCursorRects];
	}
	
	return self;
}
- (id)initWithCoder:(id)decoder
{
	self = [super initWithCoder:decoder];
	if(self) {
		[self setup];
		[self resetCursorRects];
	}
	
	return self;
}

- (void)setup
{
	NSButtonCell *cell = [[[NSButtonCell alloc] initTextCell:@""] autorelease];
	[cell setBordered:YES];
	[cell setBezelStyle:NSSmallSquareBezelStyle];
	[cell setControlSize:NSSmallControlSize];
	
	[self setCell:cell];
}
- (void)resetCursorRects
{
	[self addCursorRect:[self draggingRect] cursor:[NSCursor resizeLeftRightCursor]];
}
- (NSRect)draggingRect
{
	const CGFloat draggingWidth = 20;
	
	NSRect frame = [self frame];
	frame.origin.x = frame.size.width - draggingWidth;
	frame.origin.y = 0;
	frame.size.width = draggingWidth;
	
	return frame;
}
- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	[[NSColor darkGrayColor] set];
	
	NSRect drawRect = [self draggingRect];
	drawRect.origin = NSMakePoint(drawRect.origin.x + 7, 6);
	drawRect.size.width = 1;
	drawRect.size.height = 10;
	NSRectFill(drawRect);
	drawRect.origin.x += 3;
	NSRectFill(drawRect);
	drawRect.origin.x += 3;
	NSRectFill(drawRect);
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSEvent *event;
	
	NSPoint prevMouse = [theEvent locationInWindow];
	
	NSPoint mouse = [self convertPoint:prevMouse fromView:nil];
	if(!NSPointInRect(mouse, [self draggingRect])) return;
	
	while(YES) {
		event = [NSApp nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask
								   untilDate:[NSDate distantFuture]
									  inMode:NSEventTrackingRunLoopMode
									 dequeue:YES];
		NSPoint newMouse = [event locationInWindow];
		NSSize delta = NSMakeSize(newMouse.x - prevMouse.x, newMouse.y - prevMouse.y);
		[delegate dragControl:self dragDelta:delta];
		
		if([event type] == NSLeftMouseUp) {
			break;
		}
		prevMouse = newMouse;
	}
}

- (void)setDelegae:(id)newDelegate
{
	if(!newDelegate) delegate = nil;
	
	if(![newDelegate respondsToSelector:@selector(dragControl:dragDelta:)]) {
		HMLog(HMLogLevelAlert, @"XspfMDragControl delegate must respond dragControl:dragDelta:.");
		return;
	}
	delegate = newDelegate;
}
- (id)delegate
{
	return delegate;
}
@end
