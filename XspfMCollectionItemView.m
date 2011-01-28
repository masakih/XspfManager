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
		return NSMakeRect(16, 78, 129, 95);
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
	if(selected) {
		CGFloat radius = 8;
		NSRect frame = [self thumbnailFrame];
		if([self controlSize] == NSRegularControlSize) {
			frame = NSInsetRect(frame, -10, -10);
		} else {
			frame = NSInsetRect(frame, -5, -5);
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
