//
//  XspfMCollectionViewItem.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/10.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2009-2010, masakih
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
 Copyright (c) 2009-2010, masakih
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

#import "XspfMCollectionViewItem.h"

#import "XspfManager.h"

#import "XspfMCollectionItemBox.h"
#import "XspfMLabelCell.h"
#import "XspfMXspfObject.h"

@interface XspfMCollectionViewItem (XspfMPrivate)
- (void)setMenu:(NSMenu *)menu;
- (void)setupMenu;
@end

@implementation XspfMCollectionViewItem

- (id)copyWithZone:(NSZone *)zone
{
	XspfMCollectionViewItem *result = [super copyWithZone:zone];
	
	[result setMenu:[[menu copy] autorelease]];
	[result performSelector:@selector(setupBinding:) withObject:nil afterDelay:0.0];
	
	return result;
}

- (void)dealloc
{
	[collectionViewHolder removeObserver:self forKeyPath:@"isFirstResponder"];
		
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[self setBox:nil];
	[menu release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	id item = [menu itemAtIndex:0];
	HMLog(HMLogLevelDebug, @"initial menu -> %@ item -> %@, SEL -> %@, target -> %@", menu, item, NSStringFromSelector([item action]), [item target]);
}

- (void)setSelected:(BOOL)flag
{
	[super setSelected:flag];
	[self coodinateColors];
}

- (void)findAndSetBox
{
	[self setBox:[[self view] viewWithTag:1100]];
}
- (void)setupBinding:(id)obj
{
	collectionViewHolder = [self collectionView];
	[collectionViewHolder addObserver:self
						   forKeyPath:@"isFirstResponder"
							  options:NSKeyValueObservingOptionNew
							  context:NULL];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(applicationDidBecomeOrResignActive:)
			   name:NSApplicationDidBecomeActiveNotification
			 object:NSApp];
	[nc addObserver:self selector:@selector(applicationDidBecomeOrResignActive:)
			   name:NSApplicationDidResignActiveNotification
			 object:NSApp];
	
	[self setupMenu];
	[[self view] setMenu:menu];
	[self findAndSetBox];
	
	[self coodinateColors];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"isFirstResponder"]) {
		[self willChangeValueForKey:@"firstResponder"];
		[self coodinateColors];
		[self didChangeValueForKey:@"firstResponder"];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
- (NSRect)thumbnailFrameCoordinateBase
{
//	NSRect frame = [_box.thumbnail frame];
	NSRect frame= [_box.thumbnail imageFrame];
	
	if(!NSIntersectsRect([_box visibleRect], frame)) {
		return NSZeroRect;
	}
	
	frame = [_box convertRectToBase:frame];
	frame.origin = [[_box window] convertBaseToScreen:frame.origin];
	return frame;
}
- (void)setBox:(XspfMCollectionItemBox *)box
{
	[_box autorelease];
	_box = [box retain];
	[_box setCollectionViewItem:self];
	
	[_box setMenu:menu];
}
- (void)setView:(NSView *)view
{
	[super setView:view];
	
	if(!view) return;
	
	[self setupMenu];
	[view setMenu:menu];
	
	[self findAndSetBox];
}
- (void)setupMenu
{
	id object = [self representedObject];
	if(!object) return;
	NSMenu *objMenu = [[[NSApp delegate] menuForXspfObject:object] copy];
	
	NSArray *itemArray = [objMenu itemArray];
	NSInteger count = [itemArray count];
	if(count == 0) {
		[objMenu release];
		return;
	}
	
	[menu addItem:[NSMenuItem separatorItem]];
	for(NSInteger i = 0; i < count; i++) {
		id item = [itemArray objectAtIndex:i];
		[objMenu removeItem:item];
		[menu addItem:item];
	}
	[objMenu release];
}
- (void)setMenu:(NSMenu *)aMenu
{
	if(menu == aMenu) return;
	[menu autorelease];
	menu = [aMenu retain];
}

- (BOOL)isFirstResponder
{
	return [[self collectionView] isFirstResponder];
}

- (NSColor *)backgroundColor
{
	if(![self isSelected]) {
		return [NSColor whiteColor];
	}
	if([self isFirstResponder] && [NSApp isActive]) {
		return [NSColor colorWithCalibratedRed:65/255.0
										 green:120/255.0
										  blue:211/255.0
										 alpha:1.0];
	} else {
		return [NSColor colorWithCalibratedRed:212/255.0
										 green:212/255.0
										  blue:212/255.0
										 alpha:1.0];
	}
}

- (NSColor *)labelTextColor
{
	XspfMXspfObject *obj = [self representedObject];
	
	if([self isSelected] && [self isFirstResponder] && [NSApp isActive] && [obj.label integerValue] == XspfMLabelNone) {
		return [NSColor whiteColor];
	}
	return [NSColor blackColor];
}
- (NSColor *)textColor
{
	if([self isSelected] && [self isFirstResponder] && [NSApp isActive]) {
		return [NSColor whiteColor];
	}
	return [NSColor blackColor];
}
- (IBAction)changeRate:(id)sender
{
	[self performSelector:@selector(highlightRateIfNeeded) withObject:nil afterDelay:0.0];
}
- (void)highlightRateIfNeeded
{
	BOOL flag = [self isSelected] && [self isFirstResponder] && [NSApp isActive];
	NSLevelIndicatorCell *cell = [_box.rating cell];
	[cell setHighlighted:flag];
	[cell setBackgroundStyle:flag ? NSBackgroundStyleDark : NSBackgroundStyleLight];
}
- (void)coodinateColors
{
	[self willChangeValueForKey:@"backgroundColor"];
	[self didChangeValueForKey:@"backgroundColor"];
	
	[self willChangeValueForKey:@"textColor"];
	[self didChangeValueForKey:@"textColor"];
	
	[self willChangeValueForKey:@"labelTextColor"];
	[self didChangeValueForKey:@"labelTextColor"];
	
	[self highlightRateIfNeeded];
}
- (void)applicationDidBecomeOrResignActive:(id)notification
{
	[self coodinateColors];
}

@end
