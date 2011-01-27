//
//  XspfMShadowImageCell.m
//  XspfManager
//
//  Created by Hori,Masaki on 11/01/26.
//  Copyright 2011 masakih. All rights reserved.
//

#import "XspfMShadowImageCell.h"

@interface NSImageCell (CocoaPrivate)
- (NSRect)_imageRectForDrawing:(id)fp8 inFrame:(NSRect)fp12 inView:(id)fp28;
@end

@interface XspfMShadowImageCell(XspfMPrivate)
+ (NSShadow *)shadow;
- (NSShadow *)shadow;
@end

@implementation XspfMShadowImageCell
+ (NSShadow *)shadow
{
	static NSShadow *shadow = nil;
	
	if(shadow) return shadow;
	
	shadow = [[NSShadow alloc] init];
	[shadow setShadowOffset:NSMakeSize(2.8, -2.8)];
	[shadow setShadowBlurRadius:5.6];
	[shadow setShadowColor:[NSColor darkGrayColor]];
	
	return shadow;
}
- (NSShadow *)shadow
{
	return [[self class] shadow];
}

static inline NSRect enabledImageFrame(NSRect original)
{
	original = NSInsetRect(original, 5, 5);
	return NSOffsetRect(original, -1, 2);
}

- (NSRect)imageRectForBounds:(NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame = enabledImageFrame(cellFrame);
	
	NSRect frame = [self _imageRectForDrawing:[self image] inFrame:cellFrame inView:controlView];
	return frame;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
	[NSGraphicsContext saveGraphicsState];
	
	cellFrame = enabledImageFrame(cellFrame);
	
	[[self shadow] set];
	
	NSRect imageRect = [self _imageRectForDrawing:[self image] inFrame:cellFrame inView:controlView];
	[[NSColor whiteColor] set];
	NSRectFill(imageRect);
	
	[NSGraphicsContext restoreGraphicsState];
	
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
