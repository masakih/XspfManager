//
//  XspfMCollectionViewItem.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/10.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionViewItem.h"

#import "XspfMCollectionItemBox.h"
#import "XspfMXspfObject.h"
#import "XspfMLabelMenuItem.h"
#import "XspfMLabelCell.h"


@implementation XspfMCollectionViewItem

- (id)copyWithZone:(NSZone *)zone
{
	XspfMCollectionViewItem *result = [super copyWithZone:zone];
	
	result->menu = [menu copy];
	[result performSelector:@selector(setupBinding:) withObject:nil afterDelay:0.0];
	
	return result;
}

- (void)dealloc
{
	[collectionViewHolder removeObserver:self forKeyPath:@"isFirstResponder"];
		
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[self setBox:nil];
	
	[super dealloc];
}

- (void)setSelected:(BOOL)flag
{
	[super setSelected:flag];
	[self coodinateColors];
}

- (void)findAndSetBox
{
	id views = [[self view] subviews];
	for(id view in views) {
		if([view isKindOfClass:[XspfMCollectionItemBox class]]) {
			[self setBox:view];
		}
	}
}
- (void)setupBinding:(id)obj
{
	collectionViewHolder = [self collectionView];
	[collectionViewHolder addObserver:self
						   forKeyPath:@"isFirstResponder"
							  options:NSKeyValueObservingOptionNew
							  context:NULL];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(applicationDidBecomeOrResignActive:)
			   name:NSApplicationDidBecomeActiveNotification
			 object:NSApp];
	[nc addObserver:self selector:@selector(applicationDidBecomeOrResignActive:)
			   name:NSApplicationDidResignActiveNotification
			 object:NSApp];
		
	XspfMLabelMenuItem *item = (XspfMLabelMenuItem *)[menu itemWithTag:1000];
	XspfMXspfObject *object = [self representedObject];
	[item setRepresentedObject:object];
	[item setObjectValue:object.label];
	
	[[self view] setMenu:menu];
	[self findAndSetBox];
	
	[self coodinateColors];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"isFirstResponder"]) {
		[self willChangeValueForKey:@"firstResponder"];
		[self coodinateColors];
		[self didChangeValueForKey:@"firstResponder"];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
- (void)setBox:(XspfMCollectionItemBox *)box
{
	[_box autorelease];
	_box = [box retain];
	[_box setCollectionViewItem:self];
	
	[_box setMenu:menu];
}
- (void)setView:(NSView *)view
{
	[super setView:view];
	
	if(!view) return;
	
	[view setMenu:menu];
		
	[self findAndSetBox];
}
- (void)setMenu:(NSMenu *)aMenu
{
	menu = aMenu;
}

- (BOOL)isFirstResponder
{
	return [[self collectionView] isFirstResponder];
}

- (NSColor *)backgroundColor
{
	if(![self isSelected]) {
		return [NSColor whiteColor];
	}
	if([self isFirstResponder] && [NSApp isActive]) {
		return [NSColor colorWithCalibratedRed:65/255.0
										 green:120/255.0
										  blue:211/255.0
										 alpha:1.0];
	} else {
		return [NSColor colorWithCalibratedRed:212/255.0
										 green:212/255.0
										  blue:212/255.0
										 alpha:1.0];
	}
}

- (NSColor *)labelTextColor
{
	XspfMXspfObject *obj = [self representedObject];
	
	if([self isSelected] && [self isFirstResponder] && [NSApp isActive] && [obj.label integerValue] == XspfMLabelNone) {
		return [NSColor whiteColor];
	}
	return [NSColor blackColor];
}
- (NSColor *)textColor
{
	if([self isSelected] && [self isFirstResponder] && [NSApp isActive]) {
		return [NSColor whiteColor];
	}
	return [NSColor blackColor];
}
- (IBAction)changeRate:(id)sender
{
	[self performSelector:@selector(highlightRateIfNeeded) withObject:nil afterDelay:0.0];
}
- (void)highlightRateIfNeeded
{
	BOOL flag = [self isSelected] && [self isFirstResponder] && [NSApp isActive];
	NSLevelIndicatorCell *cell = [_box.rating cell];
	[cell setHighlighted:flag];
	[cell setBackgroundStyle:flag ? NSBackgroundStyleDark : NSBackgroundStyleLight];
}
- (void)coodinateColors
{
	[self willChangeValueForKey:@"backgroundColor"];
	[self didChangeValueForKey:@"backgroundColor"];
	
	[self willChangeValueForKey:@"textColor"];
	[self didChangeValueForKey:@"textColor"];
	
	[self willChangeValueForKey:@"labelTextColor"];
	[self didChangeValueForKey:@"labelTextColor"];
	
	[self highlightRateIfNeeded];
}
- (void)applicationDidBecomeOrResignActive:(id)notification
{
	[self coodinateColors];
}

@end
