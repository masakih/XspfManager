//
//  XspfMPopUpButton.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/10.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMPopUpButton.h"


@implementation XspfMPopUpButton

- (void)setup
{
	NSImage *image = [[self cell] image];
	[image setScalesWhenResized:YES];
	[image setSize:NSMakeSize(12, 12)];
	[image setScalesWhenResized:NO];
}
	
- (id)initWithFrame:(NSRect)rect
{
	self = [super initWithFrame:rect];
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
- (void)dealloc
{
	[menu release];
	
	[super dealloc];
}
- (void)setMenu:(NSMenu *)aMenu
{
	HMLog(HMLogLevelDebug, @"Enter -> %@", NSStringFromSelector(_cmd));
	[menu autorelease];
	menu = [aMenu retain];
}
- (NSMenu *)menu
{
	return menu;
}
- (void)menuDidClose:(NSMenu *)aMenu
{
	[[self cell] setState:NSOffState];
	[self display];
	[aMenu setDelegate:nil];
}
- (void)mouseDown:(NSEvent *)event
{
	HMLog(HMLogLevelDebug, @"Enter -> %@", NSStringFromSelector(_cmd));
	NSMenu *aMenu = [self menu];
	if(!aMenu) return;
	[aMenu setDelegate:self];
		
	[[self cell] setState:NSOnState];
	[self display];
	
	[NSMenu popUpContextMenu:aMenu withEvent:event forView:self];
}

@end
