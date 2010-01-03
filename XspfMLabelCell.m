//
//  XspfMLabelCell.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/04.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMLabelCell.h"


@implementation XspfMLabelCell

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
- (NSColor *)baseColor
{
	NSColor *result = nil;
	switch([self integerValue]) {
		case 0:
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
	if(gradient) return gradient;
	gradient = [[NSGradient alloc] initWithStartingColor:[self startColor] endingColor:[self endColor]];
	
	return gradient;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	CGFloat circleRadius = (cellFrame.size.height - 2) / 2.0;
	
	NSRect circleRect = NSMakeRect(NSMidX(cellFrame) - circleRadius, NSMidY(cellFrame) - circleRadius,
								   circleRadius * 2, circleRadius * 2);
	id bezier = [NSBezierPath bezierPathWithOvalInRect:circleRect];
	[[self gradient] drawInBezierPath:bezier angle:90];
}

@end
