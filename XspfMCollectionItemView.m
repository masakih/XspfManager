//
//  XspfMCollectionTitleField.m
//  XspfManager
//
//  Created by Hori,Masaki on 11/01/25.
//  Copyright 2011 masakih. All rights reserved.
//

#import "XspfMCollectionItemView.h"

#import "XspfMLabelCell.h"

@implementation XspfMCollectionItemView

@synthesize rating=rateCell;

- (void)setup
{
	backgroundColor = [[NSColor colorWithCalibratedRed:65/255.0
												 green:120/255.0
												  blue:211/255.0
												 alpha:1.0] retain];
	
	thumbnailCell = [[NSImageCell alloc] initImageCell:nil];
	
	titleCell = [[NSTextFieldCell alloc] initTextCell:@""];
	[titleCell setFont:[NSFont controlContentFontOfSize:13]];
	
	rateCell = [[NSLevelIndicatorCell alloc] initWithLevelIndicatorStyle:NSRatingLevelIndicatorStyle];
	
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
	
//	[representedObject removeObserver:self forKeyPath:@"representedObject"];
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
//	[rateTitleCell bind:NSTextColorBinding
//			   toObject:representedObject
//			withKeyPath:@"textColor"
//				options:nil];
	
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
	
//	[representedObject addObserver:self
//						forKeyPath:@"representedObject"
//						   options:0
//						   context:NULL];
	[representedObject addObserver:self
					forKeyPath:@"representedObject.thumbnail"
					   options:0
					   context:NULL];
//	[representedObject addObserver:self
//						forKeyPath:@"selected"
//						   options:0
//						   context:NULL];
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
//	if([keyPath isEqualToString:@"representedObject"]) {
//		[self setNeedsDisplay];
//		return;
//	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (BOOL)enabled
{
	return YES;
}


- (NSRect)imageFrame
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
		NSRect frame = [self imageFrame];
		frame = NSInsetRect(frame, -6, -6);
		const CGFloat radius = 5;
		NSBezierPath *bezier = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:radius yRadius:radius];
		[[NSColor lightGrayColor] set];
		[bezier fill];
	}
	NSRect frame = [self labelFrame];
//	frame.origin = NSZeroPoint;
	const CGFloat radius = 5;
	NSBezierPath *bezier = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:radius yRadius:radius];
	[backgroundColor set];
	[bezier fill];
	
	
	[thumbnailCell drawWithFrame:[self imageFrame] inView:self];
	[labelCell drawWithFrame:[self labelFrame] inView:self];
	[titleCell drawWithFrame:[self titleFrame] inView:self];
	[rateCell drawWithFrame:[self rateFrame] inView:self];
	[rateTitleCell drawWithFrame:[self rateTitleFrame] inView:self];
	
	
}
@end
