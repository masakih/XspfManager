//
//  XspfMCollectionTitleField.m
//  XspfManager
//
//  Created by Hori,Masaki on 11/01/25.
//  Copyright 2011 masakih. All rights reserved.
//

#import "XspfMCollectionItemView.h"

#import "XspfMLabelCell.h"
#import "XspfMShadowImageCell.h"

@implementation XspfMCollectionItemView

- (void)setup
{
	backgroundColor = [[NSColor colorWithCalibratedRed:65/255.0
												 green:120/255.0
												  blue:211/255.0
												 alpha:1.0] retain];
	
	thumbnailCell = [[XspfMShadowImageCell alloc] initImageCell:nil];
	
	titleCell = [[NSTextFieldCell alloc] initTextCell:@""];
	[titleCell setFont:[NSFont controlContentFontOfSize:13]];
	[titleCell setEditable:YES];
	[titleCell setSelectable:YES];
	[titleCell setEnabled:YES];
	
	rateCell = [[NSLevelIndicatorCell alloc] initWithLevelIndicatorStyle:NSRatingLevelIndicatorStyle];
	[rateCell setEditable:YES];
	[rateCell setEnabled:YES];
	[rateCell setHighlighted:YES];
	
	rateTitleCell = [[NSTextFieldCell alloc] initTextCell:NSLocalizedString(@"Rate:", @"Rate:")];
	[rateTitleCell setAlignment:NSRightTextAlignment];
	[rateTitleCell setFont:[NSFont controlContentFontOfSize:13]];
	
	labelCell = [[XspfMLabelCell alloc] initTextCell:@""];
	[labelCell setLabelStyle:XspfMSquareStyle];
	[labelCell setDrawX:NO];
}
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	
	[self setup];
	
	return self;
}	
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self) {
		[self setup];
	}
	return self;
}
- (void)dealloc
{
	[backgroundColor release];
	
	[thumbnailCell release];
	[titleCell release];
	[rateTitleCell release];
	[labelCell release];
	
	[super dealloc];
}

- (void)setRepresentedObject:(id)rep
{
	if(rep == representedObject) return;
	
	[representedObject removeObserver:self forKeyPath:@"representedObject.thumbnail"];
	[representedObject autorelease];
	representedObject = [rep retain];
	if(!representedObject) return;
	
	[thumbnailCell bind:NSValueBinding
			   toObject:representedObject
			withKeyPath:@"representedObject.thumbnail"
				options:nil];
	[titleCell bind:NSValueBinding
		   toObject:representedObject
		withKeyPath:@"representedObject.title"
			options:nil];
	[titleCell bind:NSTextColorBinding
		   toObject:representedObject
		withKeyPath:@"labelTextColor"
			options:nil];
	
	[rateCell bind:NSValueBinding
		  toObject:representedObject
	   withKeyPath:@"representedObject.rating"
		   options:nil];
	
	[labelCell bind:NSValueBinding
		   toObject:representedObject
		withKeyPath:@"representedObject.label"
			options:nil];
	[labelCell bind:NSEnabledBinding
		   toObject:representedObject
		withKeyPath:@"selected"
			options:nil];
	
	[self bind:@"backgroundColor"
	  toObject:representedObject
   withKeyPath:@"backgroundColor"
	   options:nil];
	[self bind:@"selected"
	  toObject:representedObject
   withKeyPath:@"selected"
	   options:nil];
	
	
	[representedObject addObserver:self
						forKeyPath:@"representedObject.thumbnail"
						   options:0
						   context:NULL];
}

- (NSInteger)tag
{
	return 1100;
}

- (void)setCollectionViewItem:(id)item
{
	[self setRepresentedObject:item];
}
- (void)setSelected:(BOOL)flag
{
	if(selected && flag) return;
	if(!selected && !flag) return;
	
	selected = flag;
	
	[self setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"representedObject.thumbnail"]) {
		[self setNeedsDisplay];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (NSRect)thumbnailFrame
{
	return NSMakeRect(12, 75, 182, 137);
}
- (NSRect)titleFrame
{
	return NSMakeRect(12, 27, 180, 34);
}
- (NSRect)rateFrame
{
	return NSMakeRect(69, 4, 65, 13);
}
- (NSRect)rateTitleFrame
{
	return NSMakeRect(13, 4, 56, 17);
}
- (NSRect)labelFrame
{
	return NSMakeRect(8, 25, 188, 38);
}

- (void)drawRect:(NSRect)dirtyFrame
{
	if(0) {
		NSRect frame = self.frame;
		frame.origin = NSZeroPoint;
		[[NSColor redColor] set];
		[NSBezierPath fillRect:frame];
	}
	if(selected) {
		NSRect frame = [self thumbnailFrame];
		frame = NSInsetRect(frame, -10, -10);
		const CGFloat radius = 8;
		NSBezierPath *bezier = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:radius yRadius:radius];
		[[NSColor gridColor] set];
		[bezier fill];
	}
	NSRect frame = [self labelFrame];
	const CGFloat radius = 5;
	NSBezierPath *bezier = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:radius yRadius:radius];
	[backgroundColor set];
	[bezier fill];
	
	
	[thumbnailCell drawWithFrame:[self thumbnailFrame] inView:self];
	[labelCell drawWithFrame:[self labelFrame] inView:self];
	[titleCell drawWithFrame:[self titleFrame] inView:self];
	[rateCell drawWithFrame:[self rateFrame] inView:self];
	[rateTitleCell drawWithFrame:[self rateTitleFrame] inView:self];
	
	
}

- (NSRect)imageFrame
{
	return [(XspfMShadowImageCell *)thumbnailCell imageRectForBounds:[self thumbnailFrame] inView:self];
}


- (void)mouseDown:(NSEvent *)event
{
	[self.window endEditingFor:self];
	
	NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if([self mouse:mouse inRect:[self rateFrame]]) {
		[rateCell trackMouse:event inRect:[self rateFrame] ofView:self untilMouseUp:YES];
		[self setNeedsDisplay];
		return;
	}
	
	if([event clickCount] == 2 && [self mouse:mouse inRect:[self titleFrame]]) {
		NSText *fieldEditor = [self.window fieldEditor:YES forObject:self];
		[titleCell setTextColor:[NSColor textColor]];
		[titleCell setBezeled:YES];
		[titleCell editWithFrame:[self titleFrame]
						  inView:self
						  editor:fieldEditor
						delegate:self
						   event:event];
		[fieldEditor selectAll:nil];
		return;
	}
	
	return [super mouseDown:event];
}
- (void)textDidEndEditing:(NSNotification *)notification
{
	NSText *fieldEditor =[notification object];
	[titleCell setStringValue:[[fieldEditor string] copy]];
	[titleCell setBezeled:NO];
	[titleCell setDrawsBackground:NO];
	[titleCell endEditing:fieldEditor];
	[self.window makeFirstResponder:self.superview.superview];
	
	[representedObject setValue:[titleCell stringValue] forKeyPath:@"representedObject.title"];
	
	[self setNeedsDisplay];
}

@end
