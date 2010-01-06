//
//  XspfMLabelMenuItem.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/04.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMLabelMenuItem.h"

#import "XspfMLabelMenuView.h"

@implementation XspfMLabelMenuItem

- (void)setupView
{
	NSRect viewFrame = NSMakeRect(0,0,200, 62);
	XspfMLabelMenuView *view = [[[XspfMLabelMenuView alloc] initWithFrame:viewFrame] autorelease];
	[view setAction:[self action]];
	[view setTarget:[self target]];
	[view setMenuLabel:[self title]];
	[view sizeToFit];
	[super setView:view];
}
- (id)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode
{
	self = [super initWithTitle:aString action:aSelector keyEquivalent:charCode];
	if(self) {
		[self setupView];
	}
	
	return self;
}
- (id)initWithCoder:(id)decoder
{
	self = [super initWithCoder:decoder];
	if(self) {
		[self setupView];
	}
	return self;
}

- (void)setView:(NSView *)view
{
	// ignore.
}
- (XspfMLabelMenuView *)labelView
{
	return (XspfMLabelMenuView *)[super view];
}

- (void)setObjectValue:(id)value
{
	[[self labelView] setObjectValue:value];
}
- (id)objectValue
{
	return [[self labelView] objectValue];
}
- (void)setIntegerValue:(NSInteger)value
{
	[[self labelView] setIntegerValue:value];
}
- (NSInteger)integerValue
{
	return [[self labelView] integerValue];
}


@end
