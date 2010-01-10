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
	[_menu release];
	
	[super dealloc];
}
- (NSMenu *)menu
{
	return _menu;
}
- (void)menuDidClose:(NSMenu *)menu
{
	[[self cell] setState:NSOffState];
	[self display];
	[menu setDelegate:nil];
}
- (void)mouseDown:(NSEvent *)event
{
	HMLog(HMLogLevelDebug, @"Enter -> %@", NSStringFromSelector(_cmd));
	NSMenu *menu = [self menu];
	if(!menu) return;
	[menu setDelegate:self];
		
	[[self cell] setState:NSOnState];
	[self display];
	
	[NSMenu popUpContextMenu:menu withEvent:event forView:self];
}

@end
