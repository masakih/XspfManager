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

- (id)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode
{
	self = [super initWithTitle:aString action:aSelector keyEquivalent:charCode];
	if(self) {
		NSRect viewFrame = NSMakeRect(0,0,200, 62);
		XspfMLabelMenuView *view = [[[XspfMLabelMenuView alloc] initWithFrame:viewFrame] autorelease];
		[view setAction:[self action]];
		[view setTarget:[self target]];
		[super setView:view];
	}
	
	return self;
}

- (void)setView:(NSView *)view
{
	// ignore.
}
- (XspfMLabelMenuView *)view
{
	return (XspfMLabelMenuView *)[super view];
}

- (void)setObjectValue:(id)value
{
	[[self view] setObjectValue:value];
}
- (id)objectValue
{
	return [[self view] objectValue];
}
- (void)setIntegerValue:(NSInteger)value
{
	[[self view] setIntegerValue:value];
}
- (NSInteger)integerValue
{
	return [[self view] integerValue];
}


@end
