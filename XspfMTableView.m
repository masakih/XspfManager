//
//  XspfMTableView.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/15.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMTableView.h"


@interface XspfMTableView (XspfM_CocoaPravateMethodHack)
- (NSColor *)_highlightColorForCell:(NSCell *)cell;
@end


@implementation XspfMTableView

+(void)initialize
{
	static BOOL isFirst = YES;
	if(isFirst) {
		isFirst = NO;
		
		if(![self instancesRespondToSelector:@selector(_highlightColorForCell:)]) {
			HMLog(HMLogLevelError, @"this version of Mac OS X not supported!");
			exit(-3);
		}
	}
}

- (void)setup
{
	contextMenuRow = -1;
}
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if(self) {
		[self setup];
	}
	return self;
}
- (id)initWithCoder:(id)decoder
{
	self = [super initWithCoder:decoder];
	if(self) {
		[self setup];
	}
	return self;
}

#pragma mark#### NSMenu Delegate ####
- (void)menuDidClose:(NSMenu *)menu
{
	HMLog(HMLogLevelDebug, @"Enter %@", NSStringFromSelector(_cmd));
	NSRect rowRect = [self rectOfRow:contextMenuRow];
	[self setNeedsDisplayInRect:rowRect];
	[menu setDelegate:nil];
	
	contextMenuRow = -1;
}
- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if(contextMenuRow == -1) return;
	
	NSRect rowRect = [self rectOfRow:contextMenuRow];
	[[self _highlightColorForCell:[self preparedCellAtColumn:0 row:contextMenuRow]] set];
	NSFrameRectWithWidth(rowRect, 2);
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
	if([[self dataSource] respondsToSelector:@selector(tableView:menuForEvent:)]) {
		NSMenu *menu = [[self dataSource] tableView:self menuForEvent:event];
		if(menu) {
			// draw select frame rectangle.
			NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
			contextMenuRow = [self rowAtPoint:mouse];
			NSRect rowRect= [self rectOfRow:contextMenuRow];
			[self setNeedsDisplayInRect:rowRect];
			[self displayIfNeeded];
			
			if([menu delegate]) {
				HMLog(HMLogLevelAlert, @"-[%@ %@] method overwrite returned NSMenu's delegate.",
					  NSStringFromClass([self class]), NSStringFromSelector(_cmd));
				HMLog(HMLogLevelAlert, @"Delegate is %@(%p)", NSStringFromClass([[menu delegate] class]), [menu delegate]);
			}
			[menu setDelegate:self];
			
			return menu;
		}
	}
	
	return nil;
}

- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent isARepeat]) return [super keyDown:theEvent];
	
#define kRETURN_KEY	36
#define kENTER_KEY	52
	
	unsigned short code = [theEvent keyCode];
	//	HMLog(HMLogLevelDebug, @"code -> %d", code);
	switch(code) {
		case kRETURN_KEY:
		case kENTER_KEY:
			if([self doubleAction]) {
				[self sendAction:[self doubleAction] to:[self target]];
				return;
			}
			break;
		case 49:
			[NSApp sendAction:@selector(togglePreviewPanel:) to:nil from:nil];
			break;
	}
	
	[super keyDown:theEvent];
}
@end
