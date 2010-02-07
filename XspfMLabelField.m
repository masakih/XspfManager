//
//  XspfMLabelField.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/11.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMLabelField.h"

#import "XspfMLabelCell.h"

@interface XspfMLabelField (XspfMPrivate)
- (NSRect)labelRectForIndex:(NSInteger)index;
@end

static const NSInteger labelCount = 8;

static const CGFloat leftMargin = 6;
static const CGFloat rightMargin = 6;
static const CGFloat labelMargin = 1;
static const CGFloat labelSize = 19;
static const CGFloat yMargin = 6;

@implementation XspfMLabelField

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	for(NSInteger i = 0; i < labelCount; i++) {
		NSCell *cell = [labelCells objectAtIndex:i];
		[cell drawWithFrame:[self labelRectForIndex:i] inView:self];
	}
}

- (NSRect)labelRectForIndex:(NSInteger)index
{
	NSRect cellRect = NSMakeRect((labelSize + labelMargin) * index + leftMargin, yMargin, labelSize, labelSize);
	
	return cellRect;
}
- (void)setup
{
	NSMutableArray *cells = [NSMutableArray arrayWithCapacity:labelCount];
	for(NSInteger i = 0; i < labelCount; i++) {
		XspfMLabelCell *cell = [[[XspfMLabelCell alloc] initTextCell:@""] autorelease];
		[cell setIntegerValue:i];
		[cell setEnabled:YES];
		[cell setBordered:YES];
		[cells addObject:cell];
		[self addTrackingRect:[self labelRectForIndex:i] owner:self userData:[NSNumber numberWithInteger:i] assumeInside:NO];
	}
	[self setCell:[cells objectAtIndex:0]];
	[self setIntegerValue:0];
	[[cells objectAtIndex:0] setState:NSOnState];
	
	labelCells = [[NSArray arrayWithArray:cells] retain];
}
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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
	[labelCells release];
	[super dealloc];
}
- (void)sizeToFit
{
	NSRect newRect = [self labelRectForIndex:labelCount - 1];
	NSSize newSize;
	newSize.width = NSMaxX(newRect);
	newSize.width += rightMargin;
	newSize.height = yMargin + labelSize + yMargin;
	
	[self setFrameSize:newSize];
	[self setNeedsDisplay];
}
- (void)setObjectValue:(id)aValue
{
	if([aValue respondsToSelector:@selector(integerValue)]) {
		[self setIntegerValue:[aValue integerValue]];
	} else {
		[super setObjectValue:aValue];
	}
}
- (id)objectValue
{
	return [NSNumber numberWithInteger:value];
}
- (void)setIntegerValue:(NSInteger)aValue
{
	if(aValue < 0 || aValue > labelCount) return;
	if(value == aValue) return;
	
	for(id cell in labelCells) {
		[cell setState:NSOffState];
	}
	[[labelCells objectAtIndex:aValue] setState:NSOnState];
	
	value = aValue;
	[self setNeedsDisplay];
}
- (NSInteger)integerValue
{
	return value;
}
- (void)setLabelStyle:(NSInteger)style
{
	for(id cell in labelCells) {
		[cell setLabelStyle:style];
	}
}
- (NSInteger)labelStyle
{
	return [[self cell] labelStyle];
}
- (void)setDrawX:(BOOL)flag
{
	[[self cell] setDrawX:flag];
}
- (BOOL)isDrawX
{
	return [[self cell] isDrawX];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	BOOL inLabelCell = NO;
	NSInteger labelIndex = NSNotFound;
	NSPoint mouse = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	for(NSInteger i = 0; i < labelCount; i++) {
		if([self mouse:mouse inRect:[self labelRectForIndex:i]]) {
			inLabelCell = YES;
			labelIndex = i;
			break;
		}
	}
	if(!inLabelCell) return;
	
	[self setIntegerValue:labelIndex];
	[self sendAction:[self action] to:[self target]];
}
- (void)mouseEntered:(NSEvent *)theEvent
{
	id cellIndex = [theEvent userData];
	if(![cellIndex isKindOfClass:[NSNumber class]]) return;
	
	NSInteger labelIndex = [cellIndex integerValue];
	[[labelCells objectAtIndex:labelIndex] setState:NSOnState];
	[self setNeedsDisplayInRect:[self labelRectForIndex:labelIndex]];
}
- (void)mouseExited:(NSEvent *)theEvent
{
	id cellIndex = [theEvent userData];
	if(![cellIndex isKindOfClass:[NSNumber class]]) return;
		
	NSInteger labelIndex = [cellIndex integerValue];
	if([self integerValue] != labelIndex) {
		[[labelCells objectAtIndex:labelIndex] setState:NSOffState];
		[self setNeedsDisplayInRect:NSInsetRect([self labelRectForIndex:labelIndex], -1,-1)];
	}
}


@end
