//
//  XspfMCollectionViewItem.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/10.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionViewItem.h"

#import "XspfMCollectionItemBox.h"


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
- (void)setView:(NSView *)view
{
	[super setView:view];
	
	if(view) {
		id views = [view subviews];
		for(id view in views) {
			if([view isKindOfClass:[XspfMCollectionItemBox class]]) {
				[view setCollectionViewItem:self];
				NSArray *boxViews = [[view contentView] subviews];
				for(id aView in boxViews) {
					if([aView isKindOfClass:[NSLevelIndicator class]]) {
						rating = aView;
						break;
					}
				}
			}
		}
	}	
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
	NSLevelIndicatorCell *cell = [rating cell];
	[cell setHighlighted:flag];
	[cell setBackgroundStyle:flag ? NSBackgroundStyleDark : NSBackgroundStyleLight];
}
- (void)coodinateColors
{
	[self willChangeValueForKey:@"backgroundColor"];
	[self didChangeValueForKey:@"backgroundColor"];
	
	[self willChangeValueForKey:@"textColor"];
	[self didChangeValueForKey:@"textColor"];
	
	[self highlightRateIfNeeded];
}
- (void)applicationDidBecomeOrResignActive:(id)notification
{
	[self coodinateColors];
}

@end
