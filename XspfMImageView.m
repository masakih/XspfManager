//
//  XspfMImageView.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/03.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMImageView.h"


@interface NSImageCell (CocoaPrivate)
- (NSRect)_imageRectForDrawing:(id)fp8 inFrame:(NSRect)fp12 inView:(id)fp28;
@end

@implementation XspfMImageView
static inline NSRect enabledImageFrame(NSRect original)
{
	original = NSInsetRect(original, 5, 5);
	return NSOffsetRect(original, -1, 2);
}
- (NSRect)imageFrame
{
	NSImageCell *cell = [self cell];
	NSRect cellFrame = [self frame];
	cellFrame.origin = NSZeroPoint;
	if(![self isEnabled]) {		
		cellFrame = enabledImageFrame(cellFrame);
	}
	
	NSRect frame = [cell _imageRectForDrawing:[cell image] inFrame:cellFrame inView:self];
	frame = [self convertRect:frame toView:[self superview]];
	return frame;
}

- (void)drawRect:(NSRect)rect
{
	NSImageCell *cell = [self cell];
	
	NSRect cellFrame = [self frame];
	cellFrame.origin = NSZeroPoint;
	
	
	if(![self isEnabled]) {		
		[NSGraphicsContext saveGraphicsState];
		
		cellFrame = enabledImageFrame(cellFrame);
		
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(2.8, -2.8)];
		[shadow setShadowBlurRadius:5.6];
		[shadow setShadowColor:[NSColor darkGrayColor]];
		[shadow set];
		
		NSRect imageRect = [cell _imageRectForDrawing:[cell image] inFrame:cellFrame inView:self];
		[[NSColor whiteColor] set];
		NSRectFill(imageRect);
		
		[NSGraphicsContext restoreGraphicsState];
	}
	[cell drawInteriorWithFrame:cellFrame inView:self];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if([theEvent clickCount] != 2) return [super mouseDown:theEvent];
	
	[self sendAction:[self action] to:[self target]];
}
@end
