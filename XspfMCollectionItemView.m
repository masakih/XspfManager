//
//  XspfMCollectionItemView.m
//  XspfManager
//
//  Created by Hori,Masaki on 11/01/25.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2011, masakih
 All rights reserved.
 
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に
 限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含
 めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表
 示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、
 コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、
 明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証
 も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューター
 も、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか
 厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する
 可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用
 サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定
 されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害につい
 て、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2011, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 1, Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in
 the documentation and/or other materials provided with the
 distribution.
 3, The names of its contributors may be used to endorse or promote
 products derived from this software without specific prior
 written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL,EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/

#import "XspfMCollectionItemView.h"

#import "XspfMLabelCell.h"
#import "XspfMShadowImageCell.h"


static NSString *const XspfMCollectionItemThumbnail = @"thumbnail";
static NSString *const XspfMCollectionItemTitle = @"title";
static NSString *const XspfMCollectionItemTitleColor = @"titleColor";
static NSString *const XspfMCollectionItemRating = @"rating";
static NSString *const XspfMCollectionItemLabel = @"label";


@implementation XspfMCollectionItemView

+ (void)initialize
{
	static BOOL isFirst = YES;
	if(isFirst){
		isFirst = NO;
		
		[self exposeBinding:XspfMCollectionItemThumbnail];
		[self exposeBinding:XspfMCollectionItemTitle];
		[self exposeBinding:XspfMCollectionItemTitleColor];
		[self exposeBinding:XspfMCollectionItemRating];
		[self exposeBinding:XspfMCollectionItemLabel];
	}
}

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
	controlSize = -1;;
	
	thumbnailCell = [[XspfMShadowImageCell alloc] initImageCell:nil];
	
	titleCell = [[NSTextFieldCell alloc] initTextCell:@""];
	[titleCell setEditable:YES];
	[titleCell setSelectable:YES];
	[titleCell setEnabled:YES];
	
	rateCell = [[NSLevelIndicatorCell alloc] initWithLevelIndicatorStyle:NSRatingLevelIndicatorStyle];
	[rateCell setEditable:YES];
	[rateCell setEnabled:YES];
	[rateCell setHighlighted:YES];
	
	rateTitleCell = [[NSTextFieldCell alloc] initTextCell:NSLocalizedString(@"Rate:", @"Icon view Rate label.")];
	[rateTitleCell setAlignment:NSRightTextAlignment];
	
	labelCell = [[XspfMLabelCell alloc] initTextCell:@""];
	[labelCell setLabelStyle:XspfMSquareStyle];
	[labelCell setDrawX:NO];
	
	if([self frame].size.height < 200) {
		[self setControlSize:NSSmallControlSize];
	} else {
		[self setControlSize:NSRegularControlSize];
	}
	
	[self calcSize];
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

- (void)setValue:(id)value forKey:(NSString *)key
{
	if([key isEqualToString:XspfMCollectionItemThumbnail]) {
		[thumbnailCell setImage:value];
		[self setNeedsDisplayInRect:selectedBounds];
		return;
	}
	if([key isEqualToString:XspfMCollectionItemTitle]) {
		value = value ? value : @"";
		[titleCell setStringValue:value];
		return;
	}
	if([key isEqualToString:XspfMCollectionItemTitleColor]) {
		[titleCell setTextColor:value];
		[self setNeedsDisplayInRect:titleBounds];
		return;
	}
	if([key isEqualToString:XspfMCollectionItemRating]) {
		[rateCell setObjectValue:value];
		return;
	}
	if([key isEqualToString:XspfMCollectionItemLabel]) {
		[labelCell setObjectValue:value];
		return;
	}
	
	[super setValue:value forKey:key];
}
- (id)valueForKey:(NSString *)key
{
	if([key isEqualToString:XspfMCollectionItemThumbnail]) {
		return [thumbnailCell image];
	}
	if([key isEqualToString:XspfMCollectionItemTitle]) {
		return [titleCell stringValue];
	}
	if([key isEqualToString:XspfMCollectionItemTitleColor]) {
		return [titleCell textColor];
	}
	if([key isEqualToString:XspfMCollectionItemRating]) {
		return [rateCell objectValue];
	}
	if([key isEqualToString:XspfMCollectionItemLabel]) {
		return [labelCell objectValue];
	}
	
	return [super valueForKey:key];
}


- (void)setSelected:(BOOL)flag
{
	if(selected && flag) return;
	if(!selected && !flag) return;
	
	selected = flag;
	
	[self setNeedsDisplayInRect:selectedBounds];
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
- (void)setFrameSize:(NSSize)newSize
{
	[super setFrameSize:newSize];
	[self calcSize];
}

- (void)calcSize
{
	if([self frame].size.height < 200) {
		[self setControlSize:NSSmallControlSize];
	} else {
		[self setControlSize:NSRegularControlSize];
	}
	
	CGFloat margin = 10;
	CGFloat titleTopMargin = 3;
	CGFloat padding = (controlSize == NSSmallControlSize) ? 5 : 10;
	NSSize labelInsetSize = (controlSize == NSSmallControlSize) ? NSMakeSize(-2, -1) : NSMakeSize(-4, -2);
	NSSize slectInsetSize = (controlSize == NSSmallControlSize) ? NSMakeSize(-5, -5) : NSMakeSize(-10, -10);
	
	NSRect myBounds = [self bounds];
	CGFloat fontHeight = [[titleCell font] pointSize];
	NSSize rateSize = NSMakeSize(65, 13);
	
	CGFloat thumbnailWidth = NSWidth(myBounds) - 2 * (margin + padding);
	CGFloat thumbnailHeight = ceil(thumbnailWidth * 3 / 4);
	CGFloat titleHeight = ceil(fontHeight * 2 * 1.3);
	CGFloat rateTitleWidth = ceil(thumbnailWidth * 0.4);
	
	thumbnailBounds = NSMakeRect(margin + padding, NSHeight(myBounds) - margin - padding - thumbnailHeight,
								 thumbnailWidth, thumbnailHeight);
	titleBounds = NSMakeRect(NSMinX(thumbnailBounds), NSMinY(thumbnailBounds) - padding - titleTopMargin - titleHeight + labelInsetSize.height,
							 thumbnailWidth, titleHeight);
	rateLabelBounds = NSMakeRect(NSMinX(thumbnailBounds), margin, rateTitleWidth, fontHeight + 4);
	rateBounds = NSMakeRect(NSMaxX(rateLabelBounds), margin, rateSize.width, rateSize.height);
	labelBounds = NSInsetRect(titleBounds, labelInsetSize.width, labelInsetSize.height);
	selectedBounds = NSInsetRect(thumbnailBounds, slectInsetSize.width, slectInsetSize.height);
}

- (CGFloat)selectRectRadius
{
	CGFloat radius = 0.0;
	switch(controlSize) {
		case NSRegularControlSize:
			radius = 8;
			break;
		case NSSmallControlSize:
			radius = 5;
			break;
	}
	return radius;
}
- (CGFloat)selectedTitleRectRadius
{
	CGFloat radius = 0.0;
	switch(controlSize) {
		case NSRegularControlSize:
			radius = 5;
			break;
		case NSSmallControlSize:
			radius = 3;
			break;
	}
	return radius;
}

- (void)drawRect:(NSRect)dirtyFrame
{
#if 0
		[[NSColor redColor] set];
		[NSBezierPath strokeRect:[self bounds]];
#endif
	
	BOOL drawThumbnail = NSIntersectsRect(selectedBounds, dirtyFrame);
	BOOL drawLabel = NSIntersectsRect(labelBounds, dirtyFrame);
	
	if(selected && drawThumbnail) {
		CGFloat radius = [self selectRectRadius];
		NSRect frame = selectedBounds;
		NSBezierPath *bezier = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:radius yRadius:radius];
		[[NSColor gridColor] set];
		[bezier fill];
	}
	
	if(drawThumbnail) {
		[thumbnailCell drawWithFrame:thumbnailBounds inView:self];
	}
	
	if(drawLabel) {
		NSRect frame = labelBounds;
		CGFloat radius = [self selectedTitleRectRadius];
		NSBezierPath *bezier = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:radius yRadius:radius];
		[backgroundColor set];
		[bezier fill];
		
		[labelCell drawWithFrame:labelBounds inView:self];
		
		if(selected && [labelCell integerValue] != 0) {
			frame = NSInsetRect(frame, 2, 2);
			radius = radius - 2;
			bezier = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:radius yRadius:radius];
			[bezier fill];
		}
		[titleCell drawWithFrame:titleBounds inView:self];
	}
	if(NSIntersectsRect(rateBounds, dirtyFrame)) {
		[rateCell drawWithFrame:rateBounds inView:self];
	}
	if(NSIntersectsRect(rateLabelBounds, dirtyFrame)) {
		[rateTitleCell drawWithFrame:rateLabelBounds inView:self];
	}
	
#if 0
	[[NSColor redColor] set];
	[NSBezierPath strokeRect:rateLabelBounds];
#endif
}

- (NSRect)imageFrame
{
	return [(XspfMShadowImageCell *)thumbnailCell imageRectForBounds:thumbnailBounds inView:self];
}

- (void)setTarget:(id)newTarget
{
	target = newTarget;
}
- (void)setAction:(SEL)newAction
{
	action = newAction;
}
- (void)mouseDown:(NSEvent *)event
{
	[self.window endEditingFor:self];
	
	NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if([self mouse:mouse inRect:rateBounds]) {
		[rateCell trackMouse:event inRect:rateBounds ofView:self untilMouseUp:YES];
		id dict = [self infoForBinding:XspfMCollectionItemRating];
		id obj = [dict objectForKey:NSObservedObjectKey];
		id key = [dict objectForKey:NSObservedKeyPathKey];
		[obj setValue:[rateCell objectValue] forKeyPath:key];
		[self setNeedsDisplayInRect:rateBounds];
		return;
	}
	
	if([event clickCount] == 2 && [self mouse:mouse inRect:titleBounds]) {
		NSText *fieldEditor = [self.window fieldEditor:YES forObject:self];
		[titleCell setTextColor:[NSColor textColor]];
		[titleCell setBezeled:YES];
		[titleCell setShowsFirstResponder:YES];
		[titleCell editWithFrame:titleBounds
						  inView:self
						  editor:fieldEditor
						delegate:self
						   event:event];
		[fieldEditor selectAll:nil];
		
		return;
	}
	if([event clickCount] == 2 && [self mouse:mouse inRect:thumbnailBounds]) {
		[self sendAction:action to:target];
		
		return;
	}
	
	return [super mouseDown:event];
}
- (void)textDidEndEditing:(NSNotification *)notification
{
	NSText *fieldEditor =[notification object];
	[titleCell setStringValue:[[[fieldEditor string] copy] autorelease]];
	[titleCell setBezeled:NO];
	[titleCell setDrawsBackground:NO];
	[titleCell endEditing:fieldEditor];
	[self.window makeFirstResponder:self.superview];
	
	id dict = [self infoForBinding:XspfMCollectionItemTitle];
	id obj = [dict objectForKey:NSObservedObjectKey];
	id key = [dict objectForKey:NSObservedKeyPathKey];
	[obj setValue:[titleCell stringValue] forKeyPath:key];
	
	[self setNeedsDisplayInRect:labelBounds];
}

@end
