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
		case XspfMLabelNone:
			result = [NSColor darkGrayColor];
			break;
		case XspfMLabelRed:
			result = [NSColor colorWithCalibratedRed:238 / 255.0
											   green:93 / 255.0
												blue:84 / 255.0
											   alpha:1.0];
			break;
		case XpsfMLabelOrange:
			result = [NSColor orangeColor];
			break;
		case XpsfMLabelYellow:
			result = [NSColor colorWithCalibratedRed:225 / 255.0
											   green:207 / 255.0
												blue:60 / 255.0
											   alpha:1.0];
			break;
		case XSpfMLabelGreen:
			result = [NSColor colorWithCalibratedRed:160 /255.0
											   green:190/ 255.0
												blue:59 / 255.0
											   alpha:1.0];
			break;
		case XspfMLabelBlue:
			result = [NSColor colorWithCalibratedRed:80 / 255.0
											   green:145 / 255.0
												blue:230 / 255.0
											   alpha:1.0];
			break;
		case XspfMLabelPurple:
			result = [NSColor colorWithCalibratedRed:141 / 255.0
											   green:104 / 255.0
												blue:160 / 255.0
											   alpha:1.0];
			break;
		case XspfMLabelGray:
			result = [NSColor grayColor];
			break;
	}
	
	return result;
}
- (NSColor *)highlightColor
{
	return [[self baseColor] highlightWithLevel:0.45];
}
- (NSGradient *)gradient
{
	if([self integerValue] == XspfMLabelNone) return nil;
	
	if(gradient) return gradient;
	gradient = [[NSGradient alloc] initWithStartingColor:[self highlightColor] endingColor:[self baseColor]];
	
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
		CGFloat radius = cellFrame.size.width * 0.1;
		radius = MIN(radius, cellFrame.size.height * 0.1);
		return [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:radius yRadius:radius];
	}
	
	CGFloat circleRadius = (cellFrame.size.height - 2) / 2.0;
	
	NSRect circleRect = NSMakeRect(NSMidX(cellFrame) - circleRadius, NSMidY(cellFrame) - circleRadius,
								   circleRadius * 2, circleRadius * 2);
	return [NSBezierPath bezierPathWithOvalInRect:circleRect];
}
- (CGFloat)gradientAngle
{
	if(labelStyle == XspfMSquareStyle) return -90.0;
	return 90.0;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if(drawX && [self integerValue] == XspfMLabelNone) {
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
	
	[[self gradient] drawInBezierPath:[self bezierWithFrame:cellFrame] angle:[self gradientAngle]];
}

@end
