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


static NSString *const XspfMCollectionItemThumbnail = @"thumbnail";
static NSString *const XspfMCollectionItemTitle = @"title";
static NSString *const XspfMCollectionItemTitleColor = @"titleColor";
static NSString *const XspfMCollectionItemRating = @"rating";
static NSString *const XspfMCollectionItemLabel = @"label";


@implementation XspfMCollectionItemView

- (NSArray *)exposedBindings
{
	NSMutableArray *bindings = [[[super exposedBindings] mutableCopy] autorelease];
	[bindings addObject:XspfMCollectionItemThumbnail];
	[bindings addObject:XspfMCollectionItemTitle];
	[bindings addObject:XspfMCollectionItemTitleColor];
	[bindings addObject:XspfMCollectionItemRating];
	[bindings addObject:XspfMCollectionItemLabel];
	
	return bindings;
}
- (Class)valueClassForBinding:(NSString *)binding
{
	if([binding isEqualToString:XspfMCollectionItemThumbnail]) {
		return [NSImage class];
	}
	if([binding isEqualToString:XspfMCollectionItemTitle]) {
		return [NSString class];
	}
	if([binding isEqualToString:XspfMCollectionItemTitleColor]) {
		return [NSColor class];
	}
	if([binding isEqualToString:XspfMCollectionItemRating]) {
		return [NSValue class];
	}
	if([binding isEqualToString:XspfMCollectionItemLabel]) {
		return [NSValue class];
	}
	
	return [super valueClassForBinding:binding];
}

- (void)setup
{
	controlSize = NSRegularControlSize;
	
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
	
	if([self frame].size.height < 200) {
		[self setControlSize:NSSmallControlSize];
	}
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
	
	[titleBindKey release];
	
	[super dealloc];
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	if([binding isEqualToString:XspfMCollectionItemThumbnail]) {
		[thumbnailCell bind:NSValueBinding
				   toObject:observable
				withKeyPath:keyPath
					options:options];
		
		if(thumbnailBinder) {
			[thumbnailBinder removeObserver:self forKeyPath:thumbnailBindKey];
		}
		
		thumbnailBinder = observable;
		thumbnailBindKey = [keyPath copy];
		[thumbnailBinder addObserver:self
						  forKeyPath:thumbnailBindKey
							 options:0
							 context:NULL];
		return;
	}
	if([binding isEqualToString:XspfMCollectionItemTitle]) {
		[titleCell bind:NSValueBinding
			   toObject:observable
			withKeyPath:keyPath
				options:options];
		titleBinder = observable;
		titleBindKey = [keyPath copy];
		return;
	}
	if([binding isEqualToString:XspfMCollectionItemTitleColor]) {
		[titleCell bind:NSTextColorBinding
			   toObject:observable
			withKeyPath:keyPath
				options:options];
		return;
	}
	if([binding isEqualToString:XspfMCollectionItemRating]) {
		[rateCell bind:NSValueBinding
			  toObject:observable
		   withKeyPath:keyPath
			   options:options];
		return;
	}
	if([binding isEqualToString:XspfMCollectionItemLabel]) {
		[labelCell bind:NSValueBinding
			   toObject:observable
			withKeyPath:keyPath
				options:options];
		return;
	}
	
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
}
- (void)unbind:(NSString *)binding
{
	if([binding isEqualToString:XspfMCollectionItemThumbnail]) {
		[thumbnailCell unbind:NSValueBinding];
		
		if(thumbnailBinder) {
			[thumbnailBinder removeObserver:self forKeyPath:thumbnailBindKey];
		}
		
		thumbnailBinder = nil;
		[thumbnailBindKey release];
		thumbnailBindKey = nil;
		return;
	}
	if([binding isEqualToString:XspfMCollectionItemTitle]) {
		[titleCell unbind:NSValueBinding];
		
		titleBinder = nil;
		[titleBindKey release];
		thumbnailBindKey = nil;
		return;
	}
	if([binding isEqualToString:XspfMCollectionItemTitleColor]) {
		[titleCell unbind:NSTextColorBinding];
		return;
	}
	if([binding isEqualToString:XspfMCollectionItemRating]) {
		[rateCell unbind:NSValueBinding];
		return;
	}
	if([binding isEqualToString:XspfMCollectionItemLabel]) {
		[labelCell unbind:NSValueBinding];
		return;
	}
	
	[super unbind:binding];
}

- (NSInteger)tag
{
	return 1100;
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
	if([keyPath isEqualToString:thumbnailBindKey]) {
		[self setNeedsDisplay];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setControlSize:(NSControlSize)size
{
	if(size == controlSize) return;
	controlSize = size;
	
	NSFont *titleFont = nil;
	switch(controlSize) {
		case NSRegularControlSize:
			titleFont = [NSFont controlContentFontOfSize:13];
			break;
		case NSSmallControlSize:
			titleFont = [NSFont controlContentFontOfSize:11];
			break;
	}
	
	[titleCell setFont:titleFont];
	[rateTitleCell setFont:titleFont];
	
	[titleCell setControlSize:size];
	[thumbnailCell setControlSize:size];
	[rateCell setControlSize:size];
	[rateTitleCell setControlSize:size];
}

- (NSControlSize)controlSize
{
	return controlSize;
}

- (NSRect)thumbnailFrame
{
	if(controlSize == NSRegularControlSize) {
		return NSMakeRect(20, 83, 182, 137);
	} else if(controlSize == NSSmallControlSize) {
		return NSMakeRect(16, 73, 129, 95);
	}
	return NSZeroRect;
}
- (NSRect)titleFrame
{
	if(controlSize == NSRegularControlSize) {
		return NSMakeRect(20, 35, 180, 34);
	} else if(controlSize == NSSmallControlSize) {
		return NSMakeRect(16, 41, 129, 28);
	}
	return NSZeroRect;
}
- (NSRect)rateFrame
{
	if(controlSize == NSRegularControlSize) {
		return NSMakeRect(77, 12, 65, 13);
	} else if(controlSize == NSSmallControlSize) {
		return NSMakeRect(63, 19, 65, 13);
	}
	return NSZeroRect;
}
- (NSRect)rateTitleFrame
{
	if(controlSize == NSRegularControlSize) {
		return NSMakeRect(21, 12, 56, 17);
	} else if(controlSize == NSSmallControlSize) {
		return NSMakeRect(16, 19, 48, 14);
	}
	return NSZeroRect;
}
- (NSRect)labelFrame
{
	if(controlSize == NSRegularControlSize) {
		return NSMakeRect(16, 33, 188, 38);
	} else if(controlSize == NSSmallControlSize) {
		return NSMakeRect(14, 40, 134, 31);
	}
	return NSZeroRect;
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
		CGFloat radius = 8;
		NSRect frame = [self thumbnailFrame];
		if([self controlSize] == NSRegularControlSize) {
			frame = NSInsetRect(frame, -10, -10);
		} else {
			frame = NSInsetRect(frame, -5, 0);
			radius = 5;
		}
		
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
	[self.window makeFirstResponder:self.superview];
	
	[titleBinder setValue:[titleCell stringValue] forKeyPath:titleBindKey];
	
	[self setNeedsDisplay];
}

@end
