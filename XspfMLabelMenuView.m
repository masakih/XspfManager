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
- (NSFont *)titleFont;
- (NSDictionary *)titleAttribute;
- (NSRect)titleRect;
- (NSFont *)labelNameFont;
- (NSRect)labelNameRect;
- (NSRect)labelRectForIndex:(NSInteger)index;
@end

@implementation XspfMLabelMenuView

static const NSInteger labelCount = 8;

static const CGFloat leftMargin = 19;
static const CGFloat rightMargin = 23;
static const CGFloat labelMargin = 3;
static const CGFloat labelSize = 19;

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
	
	NSMutableArray *cells = [NSMutableArray arrayWithCapacity:labelCount];
	for(NSInteger i = 0; i < labelCount; i++) {
		XspfMLabelCell *cell = [[[XspfMLabelCell alloc] initTextCell:@""] autorelease];
		[cells addObject:cell];
		[self addTrackingRect:[self labelRectForIndex:i] owner:self userData:[NSNumber numberWithInteger:i] assumeInside:NO];
		[cell setEnabled:YES];
		[cell setBordered:YES];
		[cell setIntegerValue:i];
		[cell setLabelStyle:XspfMSquareStyle];
		[cell setDrawX:YES];
	}
	labelCells = [[NSArray alloc] initWithArray:cells];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCells];
    }
    return self;
}
- (void)dealloc
{
	[title release];
	[labelCells release];
	[labelName release];
	
	[super dealloc];
}
- (void)sizeToFit
{
	CGFloat width = 200;
	CGFloat height = 0;
	
	NSSize size = [[title stringValue] sizeWithAttributes:[self titleAttribute]];
	HMLog(HMLogLevelDebug, @"title size is %@", NSStringFromSize(size));
	width = MAX(width, size.width + leftMargin);
	height += size.height;
	
	NSRect rect = [self labelNameRect];
	height += rect.size.height;
	
	rect = [self labelRectForIndex:labelCount - 1];
	width = MAX(width, NSMaxX(rect));
	height += rect.size.height;
	
	width += rightMargin;
	height += 6 + 6;
	
	[self setFrameSize:NSMakeSize(width, height)];
}


-(CGFloat)titleFontSize
{
	return [[NSFont menuFontOfSize:0] pointSize] + 1;
}
- (NSFont *)titleFont
{
	return [NSFont menuFontOfSize:[self titleFontSize]];
	
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
	CGFloat height = [self labelNameHeight];
	NSRect rect = NSMakeRect(leftMargin, NSMinY([self labelRectForIndex:0]) - height - 3,
							 (labelSize + labelMargin) * (labelCount - 1) + labelSize, height);
	
	return rect;
}
- (NSRect)labelRectForIndex:(NSInteger)index
{
	CGFloat maxY = NSMinY([self titleRect]);
	CGFloat yMargin = 6;
	
	NSRect cellRect = NSMakeRect((labelSize + labelMargin) * index + leftMargin, maxY - labelSize - yMargin, labelSize, labelSize);
	
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
	
//	[[NSColor redColor] set];
//	NSFrameRect([self frame]);
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
		
		[self setIntegerValue:labelIndex];
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
			label = NSLocalizedString(@"None", @"LabelNameNone");
			break;
		case 1:
			label = NSLocalizedString(@"Red", @"LabelNameRed");
			break;
		case 2:
			label = NSLocalizedString(@"Orange", @"LabelNameOrange");
			break;
		case 3:
			label = NSLocalizedString(@"Yellow", @"LabelNameYellow");
			break;
		case 4:
			label = NSLocalizedString(@"Green", @"LabelNameGreen");
			break;
		case 5:
			label = NSLocalizedString(@"Blue", @"LabelNameBlue");
			break;
		case 6:
			label = NSLocalizedString(@"Purple", @"LabelNamePurple");
			break;
		case 7:
			label = NSLocalizedString(@"Gray", @"LabelNameGray");
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
