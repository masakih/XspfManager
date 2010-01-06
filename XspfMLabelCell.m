//
//  XspfMLabelCell.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/04.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMLabelCell.h"


@implementation XspfMLabelCell

- (void)setIntegerValue:(NSInteger)integer
{
	if(integer == [self integerValue]) return;
	
	[gradient release];
	gradient = nil;
	
	[super setIntegerValue:integer];
}

- (void)setObjectValue:(id)value
{
	if([value isEqual:[self objectValue]]) return;
	
	[gradient release];
	gradient = nil;
	
	[super setObjectValue:value];
}
- (void)dealloc
{
	[gradient release];
	gradient = nil;
	
	[super dealloc];
}

- (void)setLabelStyle:(NSInteger)style
{
	labelStyle = style;
}
- (NSInteger)labelStyle
{
	return labelStyle;
}
- (void)setDrawX:(BOOL)flag
{
	drawX = flag;
}
- (BOOL)isDrawX
{
	return drawX;
}

- (NSColor *)baseColor
{
	NSColor *result = nil;
	switch([self integerValue]) {
		case 0:
			result = [NSColor darkGrayColor];
			break;
		case 1:
			result = [NSColor redColor];
			break;
		case 2:
			result = [NSColor orangeColor];
			break;
		case 3:
			result = [NSColor yellowColor];
			break;
		case 4:
			result = [NSColor greenColor];
			break;
		case 5:
			result = [NSColor blueColor];
			break;
		case 6:
			result = [NSColor purpleColor];
			break;
		case 7:
			result = [NSColor grayColor];
			break;
	}
	
	return result;
}
- (NSColor *)endColor
{
	return [[self baseColor] highlightWithLevel:0.1];
}
- (NSColor *)startColor
{
	return [[self baseColor] highlightWithLevel:0.7];
}
- (NSGradient *)gradient
{
	if([self integerValue] == 0) return nil;
	
	if(gradient) return gradient;
	gradient = [[NSGradient alloc] initWithStartingColor:[self startColor] endingColor:[self endColor]];
	
	return gradient;
}
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect interFrame;
	if([self isBordered]) {
		interFrame = NSInsetRect(cellFrame, 2, 2);
	} else {
		interFrame = cellFrame;
	}
	if(![self isEnabled] || ![self isBordered] || NSOnState != [self state]) {
		[self drawInteriorWithFrame:interFrame inView:controlView];
		return;
	}
	
	[NSGraphicsContext saveGraphicsState];
	
	[[NSColor lightGrayColor] set];
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(.3, .3)];
	[shadow setShadowBlurRadius:0.5];
	[shadow set];
	NSFrameRect(cellFrame);
	
	[NSGraphicsContext restoreGraphicsState];
	
	[self drawInteriorWithFrame:interFrame inView:controlView];
}
- (NSBezierPath *)bezierWithFrame:(NSRect)cellFrame
{
	if(labelStyle == XspfMSquareStyle) {
		CGFloat radius = cellFrame.size.width / 10;
		radius = MIN(radius, cellFrame.size.height / 10);
		return [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:radius yRadius:radius];
	}
	
	CGFloat circleRadius = (cellFrame.size.height - 2) / 2.0;
	
	NSRect circleRect = NSMakeRect(NSMidX(cellFrame) - circleRadius, NSMidY(cellFrame) - circleRadius,
								   circleRadius * 2, circleRadius * 2);
	return [NSBezierPath bezierPathWithOvalInRect:circleRect];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if(drawX && [self integerValue] == 0) {
		cellFrame = NSInsetRect(cellFrame, 3, 3);
		CGFloat maxX, midX, minX, maxY, midY, minY;
		maxX = NSMaxX(cellFrame); midX = NSMidX(cellFrame); minX = NSMinX(cellFrame);
		maxY = NSMaxY(cellFrame); midY = NSMidY(cellFrame); minY = NSMinY(cellFrame);
		CGFloat d = 1;
		
		NSBezierPath *result = [NSBezierPath bezierPath];
		[result setLineWidth:1];
		[result moveToPoint:NSMakePoint(minX + d, minY)];
		[result lineToPoint:NSMakePoint(midX, midY - d)];
		[result lineToPoint:NSMakePoint(maxX - d, minY)];
		[result lineToPoint:NSMakePoint(maxX, minY + d)];
		[result lineToPoint:NSMakePoint(midX + d, midY)];
		[result lineToPoint:NSMakePoint(maxX, maxY - d)];
		[result lineToPoint:NSMakePoint(maxX - d, maxY)];
		[result lineToPoint:NSMakePoint(midX, midY + d)];
		[result lineToPoint:NSMakePoint(minX + d, maxY)];
		[result lineToPoint:NSMakePoint(minX, maxY - d)];
		[result lineToPoint:NSMakePoint(midX - d, midY)];
		[result lineToPoint:NSMakePoint(minX, minY + d)];
		[result closePath];
		
		
		[[self baseColor] set];
		[result fill];
		
		return;
	}
	
	[[self gradient] drawInBezierPath:[self bezierWithFrame:cellFrame] angle:90];
}

@end
