//
//  XspfMCollectionViewItem.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/10.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionViewItem.h"


@implementation XspfMCollectionViewItem

- (id)copyWithZone:(NSZone *)zone
{
	id result = [super copyWithZone:zone];
	[result performSelector:@selector(setupBinding:) withObject:nil afterDelay:0.0];
	
	return result;
}

- (void)dealloc
{
	[collectionViewHolder removeObserver:self forKeyPath:@"isFirstResponder"];
	
	[thumbnail unbind:@"enabled2"];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}

- (void)setSelected:(BOOL)flag
{
	[super setSelected:flag];
	[self coodinateColors];
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

- (BOOL)isFirstResponder
{
	return [[self collectionView] isFirstResponder];
}

- (NSColor *)backgrounColor
{
	if(![self isSelected]) {
		return [NSColor whiteColor];
	}
	if([[self collectionView] isFirstResponder] && [NSApp isActive]) {
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

- (NSColor *)textColor
{
	if([self isSelected] && [[self collectionView] isFirstResponder] && [NSApp isActive]) {
		return [NSColor whiteColor];
	}
	return [NSColor blackColor];
}

- (void)coodinateColors
{
	[box setFillColor:[self backgrounColor]];
	[box setBorderColor:[self backgrounColor]];
	
	[self willChangeValueForKey:@"textColor"];
	[self didChangeValueForKey:@"textColor"];
}
- (void)applicationDidBecomeOrResignActive:(id)notification
{
	[self coodinateColors];
}

@end
