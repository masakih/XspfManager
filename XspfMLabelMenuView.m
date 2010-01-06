//
//  XspfMLabelMenuView.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/04.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMLabelMenuView.h"

#import "XspfMLabelCell.h"

@interface XspfMLabelMenuView(XspfMPrivate)
- (CGFloat)titleSize;
- (NSFont *)titleFont;
- (NSDictionary *)titleAttribute;
- (NSRect)titleRect;
- (NSFont *)labelNameFont;
- (NSRect)labelNameRect;
- (NSRect)labelRectForIndex:(NSInteger)index;
@end

@implementation XspfMLabelMenuView

const CGFloat labelCount = 8;

- (void)setupCells
{
	title = [[NSTextFieldCell alloc] initTextCell:@""];
	[title setControlSize:NSRegularControlSize];
	[title setFont:[self titleFont]];
	
	
	labelName = [[NSTextFieldCell alloc] initTextCell:@""];
	[labelName setControlSize:NSSmallControlSize];
	[labelName setFont:[self labelNameFont]];
	[labelName setAlignment:NSCenterTextAlignment];
	[labelName setTextColor:[NSColor disabledControlTextColor]];
	
	label01 = [[XspfMLabelCell alloc] initTextCell:@""];
	label02 = [[XspfMLabelCell alloc] initTextCell:@""];
	label03 = [[XspfMLabelCell alloc] initTextCell:@""];
	label04 = [[XspfMLabelCell alloc] initTextCell:@""];
	label05 = [[XspfMLabelCell alloc] initTextCell:@""];
	label06 = [[XspfMLabelCell alloc] initTextCell:@""];
	label07 = [[XspfMLabelCell alloc] initTextCell:@""];
	label08 = [[XspfMLabelCell alloc] initTextCell:@""];
	
	labelCells = [NSArray arrayWithObjects:label01, label02, label03, label04, label05, label06, label07, label08, nil];
	[labelCells retain];
	
	
	for(NSInteger i = 0; i < labelCount; i++) {
		XspfMLabelCell *cell = [labelCells objectAtIndex:i];
		[self addTrackingRect:[self labelRectForIndex:i] owner:self userData:[NSNumber numberWithInteger:i] assumeInside:NO];
		[cell setEnabled:YES];
		[cell setBordered:YES];
		[cell setIntegerValue:i];
		[cell setLabelStyle:XspfMSquareStyle];
		[cell setDrawX:YES];
	}
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCells];
    }
    return self;
}

- (void)sizeToFit
{
	CGFloat width = 200;
	CGFloat height = 0;
	
	NSRect rect = [self titleRect];
	width = MAX(width, NSMaxX(rect));
	height += rect.size.height;
	
	rect = [self labelNameRect];
	width = MAX(width, NSMaxX(rect));
	height += rect.size.height;
	
	rect = [self labelRectForIndex:0];
	width = MAX(width, NSMaxX(rect));
	height += rect.size.height;
	
	height += 6 + 6;
	
	[self setFrameSize:NSMakeSize(width, height)];
}

const CGFloat leftMargin = 19;

- (CGFloat)titleSize
{
	return [NSFont systemFontSizeForControlSize:NSRegularControlSize];
}
- (NSFont *)titleFont
{
	return [NSFont menuFontOfSize:[self titleSize]];
}
- (NSDictionary *)titleAttribute
{
	return [NSDictionary dictionaryWithObject:[self titleFont] forKey:NSFontAttributeName];
}
- (CGFloat)titleHeight
{
	if(titleHeight != 0) return titleHeight;
	
	NSSize size = [[title stringValue] sizeWithAttributes:[self titleAttribute]];
	titleHeight = size.height;
	
	return titleHeight;
}
- (NSRect)titleRect
{
	CGFloat height = [self titleHeight];
	NSRect rect = NSMakeRect(leftMargin, NSMaxY([self frame]) - height,
							 [self frame].size.width, height);
		
	return rect;
}
- (CGFloat)labelNameSize
{
	return [NSFont systemFontSizeForControlSize:NSSmallControlSize];
}
- (NSFont *)labelNameFont
{
	return [NSFont menuFontOfSize:[self labelNameSize]];
}
- (NSDictionary *)labelNameAttribute
{
	return [NSDictionary dictionaryWithObject:[self titleFont] forKey:NSFontAttributeName];
}
- (CGFloat)labelNameHeight
{
	if(labelNameHeight != 0) return labelNameHeight;
	
	NSSize size = [[title stringValue] sizeWithAttributes:[self titleAttribute]];
	labelNameHeight = size.height;
	
	return labelNameHeight;
}
- (NSRect)labelNameRect
{
	const CGFloat UIMargin = 6;
	CGFloat xMargin = 100;
	CGFloat height = [self labelNameHeight];
	NSRect rect = NSMakeRect(leftMargin + xMargin, NSMinY([self labelRectForIndex:0]) - height - 3,
							 [self frame].size.width - leftMargin - xMargin - UIMargin, height);
	
	return rect;
}
- (NSRect)labelRectForIndex:(NSInteger)index
{
	CGFloat maxY = NSMinY([self titleRect]);
	CGFloat height = 19;
	CGFloat xMargin = 3;
	CGFloat yMargin = 6;
	
	NSRect cellRect = NSMakeRect((height + xMargin) * index + leftMargin, maxY - height - yMargin, height, height);
	
	return cellRect;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	NSRect cellFrame = [self titleRect];
	if(NSIntersectsRect(rect, cellFrame)) {
		[title drawWithFrame:cellFrame inView:self];
	}
	
	for(NSInteger i = 0; i < labelCount; i++) {
		cellFrame = [self labelRectForIndex:i];
		if(NSIntersectsRect(rect, cellFrame)) {
			[[labelCells objectAtIndex:i] drawWithFrame:cellFrame inView:self];
		}
	}
	
	cellFrame = [self labelNameRect];
	if(NSIntersectsRect(rect, cellFrame)) {
		[labelName drawWithFrame:cellFrame inView:self];
	}
}
- (void)setMenuLabel:(NSString *)menuTitle
{
	[title setStringValue:menuTitle];
}
- (NSString *)menuLabel
{
	return [title stringValue];
}
- (void)setObjectValue:(id)value
{
	if([value respondsToSelector:@selector(integerValue)]) {
		[self setIntegerValue:[value integerValue]];
	} else {
		[super setObjectValue:value];
	}
}
- (id)objectValue
{
	return [NSNumber numberWithInteger:_value];
}
- (void)setIntegerValue:(NSInteger)value
{
	for(id cell in labelCells) {
		[cell setState:NSOffState];
	}
	if(value >= 0 && value < labelCount) {
		[[labelCells objectAtIndex:value] setState:NSOnState];
	}
	
	_value = value;
}
- (NSInteger)integerValue
{
	return _value;
}

- (void)sendActionToTarget
{
	NSMenuItem *item = [self enclosingMenuItem];
	NSMenu *menu = [item menu];
	NSInteger index = [menu indexOfItem:item];
	[menu performActionForItemAtIndex:index];
}
- (void)blinkTimerOperate:(NSTimer *)timer
{
	if(blinkModeBlinkTime % 3) {
		blinkModeBlinkTime--;
		return;
	}
	
	id userInfo = [timer userInfo];
	NSInteger labelIndex = [[userInfo valueForKey:@"labelIndex"] integerValue];
	NSCell *cell = [labelCells objectAtIndex:labelIndex];
	NSRect cellFrame = NSInsetRect([self labelRectForIndex:labelIndex], -1,-1);
	
	NSInteger state = blinkModeBlinkTime % 6 ? NSOnState : NSOffState;
	
	[cell setState:state];
	[self setNeedsDisplayInRect:cellFrame];
	[self displayIfNeeded];
	
	if(blinkModeBlinkTime == 0) {
		[labelName setStringValue:@""];
		[self setNeedsDisplayInRect:[self labelNameRect]];
		
		[self sendActionToTarget];
		
		[[[self enclosingMenuItem] menu] cancelTracking];
		[timer invalidate];
		blinkMode = NO;
	}
	blinkModeBlinkTime--;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}
- (void)mouseDown:(NSEvent *)theEvent
{
	if(blinkMode) return;
	
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
	blinkMode = YES;
	
	[self setIntegerValue:labelIndex];
	
	id info = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			   [NSNumber numberWithInteger:labelIndex], @"labelIndex",
			   nil];
	blinkModeBlinkTime = 12;
	NSTimer *timer = [NSTimer timerWithTimeInterval:0.03
											 target:self
										   selector:@selector(blinkTimerOperate:)
										   userInfo:info
											repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
}
- (void)mouseEntered:(NSEvent *)theEvent
{
	if(blinkMode) return;
	
	id cellIndex = [theEvent userData];
	if(![cellIndex isKindOfClass:[NSNumber class]]) return;
	
	NSString *label = @"";
	NSInteger labelIndex = [cellIndex integerValue];
	switch(labelIndex) {
		case 0:
			label = @"None";
			break;
		case 1:
			label = @"Red";
			break;
		case 2:
			label = @"Orange";
			break;
		case 3:
			label = @"Yellow";
			break;
		case 4:
			label = @"Green";
			break;
		case 5:
			label = @"Blue";
			break;
		case 6:
			label = @"Purple";
			break;
		case 7:
			label = @"Gray";
			break;
		default:
			HMLog(HMLogLevelError, @"Unknown label number (%@).", cellIndex);
			return;
	}
	
	[[labelCells objectAtIndex:labelIndex] setState:NSOnState];
	[labelName setStringValue:label];
	[self setNeedsDisplayInRect:[self labelNameRect]];
	[self setNeedsDisplayInRect:[self labelRectForIndex:labelIndex]];
}
- (void)mouseExited:(NSEvent *)theEvent
{
	if(blinkMode) return;
	
	id cellIndex = [theEvent userData];
	if(![cellIndex isKindOfClass:[NSNumber class]]) return;
	
	[labelName setStringValue:@""];
	[self setNeedsDisplayInRect:[self labelNameRect]];
	
	NSInteger labelIndex = [cellIndex integerValue];
	if(labelIndex == 0 || [self integerValue] != labelIndex) {
		[[labelCells objectAtIndex:labelIndex] setState:NSOffState];
		[self setNeedsDisplayInRect:NSInsetRect([self labelRectForIndex:labelIndex], -1,-1)];
	}
}

@end
