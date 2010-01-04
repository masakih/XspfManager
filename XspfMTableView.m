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

#pragma mark#### NSMenu Delegate ####
- (void)menuDidClose:(NSMenu *)menu
{
	HMLog(HMLogLevelDebug, @"Enter %@", NSStringFromSelector(_cmd));
	NSMenuItem *hiddenItem = [menu itemAtIndex:0];
	id rowValue = [hiddenItem representedObject];	
	HMLog(HMLogLevelDebug, @"rowValue is %@", rowValue);
	NSInteger row = [rowValue integerValue];
	NSRect rowRect = [self rectOfRow:row];
	[self setNeedsDisplayInRect:rowRect];
}
- (NSMenu *)menuForEvent:(NSEvent *)event
{
	if([[self dataSource] respondsToSelector:@selector(tableView:menuForEvent:)]) {
		NSMenu *menu = [[self dataSource] tableView:self menuForEvent:event];
		if(menu) {
			// draw select frame rectangle.
			NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
			NSInteger row = [self rowAtPoint:mouse];
			NSInteger col = [self columnAtPoint:mouse];
			NSRect rowRect= [self rectOfRow:row];
			[self lockFocus];
			[[self _highlightColorForCell:[self preparedCellAtColumn:col row:row]] set];
			NSFrameRectWithWidth(rowRect, 2);
			[self unlockFocus];
			
			if([menu delegate]) {
				HMLog(HMLogLevelAlert, @"-[%@ %@] method overwrite returned NSMenu's delegate.",
					  NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			}
			NSMenuItem *hiddenItem = [menu insertItemWithTitle:@"hidden" action:Nil keyEquivalent:@"" atIndex:0];
			[hiddenItem setHidden:YES];
			[hiddenItem setRepresentedObject:[NSNumber numberWithInteger:row]];
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
	}
	
	[super keyDown:theEvent];
}
@end
