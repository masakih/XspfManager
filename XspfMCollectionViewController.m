//
//  XspfMCollectionViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/05.
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

#import "XspfMCollectionViewController.h"

#import "XspfMCollectionView.h"
#import "XspfMCollectionViewItem.h"
#import "XspfMXspfObject.h"

#import "XspfMPreferences.h"

@interface NSCollectionView(CocoaPrivatemethods)
- (void)_getRow:(NSUInteger *)fp8 column:(NSUInteger *)fp12 forPoint:(NSPoint)fp16;
- (NSRect)_frameRectForIndexInGrid:(NSUInteger)fp8 gridSize:(NSSize)fp12;
- (NSRange)columnCountRange;
@end


@interface XspfMCollectionViewController (XspfMPrivate)
- (void)setCollectionItem:(XspfMCollectionViewItem *)newItem;
@end

static NSString *const XspfMCollectionItemSizeKey = @"Collection Item Size";

@implementation XspfMCollectionViewController

- (id)init
{
	[super initWithNibName:@"CollectionView" bundle:nil];
	
	return self;
}

- (void)awakeFromNib
{
	NSInteger type = [XspfMPreferences sharedPreference].collectionItemSize;
	[self setCollectionItem:type == 0 ? regularItem : smallItem];
}

- (void)setCollectionItem:(XspfMCollectionViewItem *)newItem
{
	if(collectionViewItem == newItem) return;
	
	
	// editing text field resign from first responder.
	[[[self view] window] endEditingFor:nil];
	
	[collectionView setItemPrototype:newItem];
	NSSize viewSize = [[newItem view] frame].size;
	[collectionView setMinItemSize:viewSize];
	[collectionView setMaxItemSize:viewSize];
	[scrollView setVerticalLineScroll:viewSize.height];
	collectionViewItem = newItem;
	
	[[[self view] window] makeFirstResponder:[self view]];
	
	
	[XspfMPreferences sharedPreference].collectionItemSize = collectionViewItem == regularItem ? 0 : 1;
}

- (IBAction)changeLabel:(id)sender
{
	XspfMXspfObject *object = [sender representedObject];
	object.label = [sender objectValue];
}

- (IBAction)collectionViewItemViewRegular:(id)sender
{
	[self setCollectionItem:regularItem];
}
- (IBAction)collectionViewItemViewSmall:(id)sender
{
	[self setCollectionItem:smallItem];
}

- (IBAction)scrollToSelection:(id)sender
{
	
	id item = nil;
	@try {
		item = [collectionView itemAtIndex:[[self representedObject] selectionIndex]];
	}
	@catch (id ex) {
		NSLog(@"Exception -> %@", ex);
	}
	if(!item) return;
	
	NSRect rect = [[item view] frame];
//	NSLog(@"selected rect -> %@", NSStringFromRect(rect));
	[collectionView scrollRectToVisible:rect];
}

- (XspfMCollectionItemType)collectionItemType
{
	if(collectionViewItem == regularItem) return typeXspfMRegularItem;
	if(collectionViewItem == smallItem) return typeXSpfMSmallItem;
	
	return typeXspfMUnknownItem;
}

#pragma mark#### XspfMCollectionView Delegate ####
- (void)enterAction:(XspfMCollectionView *)view
{
	[NSApp sendAction:@selector(openXspf:) to:nil from:self];
}

// QLPreviewPanel support
- (NSRect)selectionItemRectForLeopard
{
	NSRect collectionFrame = [collectionView frame];
	NSSize itemSize = [collectionView minItemSize];
	
	// get right edge item colum.
	NSPoint rightEdge = NSMakePoint(collectionFrame.size.width - 1, itemSize.height / 2);
	NSUInteger col = 0;
	NSUInteger row = 0;
	[collectionView _getRow:&row column:&col forPoint:rightEdge];
	
	// get selected item's row and column.
	NSUInteger index = [[self representedObject] selectionIndex];
	NSUInteger maxCol = col;
	col = index % maxCol;
	row = index / maxCol;
	
	// caluculate selected item view's image view point.
	NSPoint itemImagePoint;
	itemImagePoint.x = itemSize.width / 2 + itemSize.width * col;
	itemImagePoint.y = itemSize.height * .2 + itemSize.height * row;	// CollectionView is fliped.
	
	// get item image view.
	NSView *thumbnail = [collectionView hitTest:itemImagePoint];
	NSView *view = [[thumbnail superview] superview];
	
	NSRect frame = [thumbnail frame];
	
	NSRect convertedRect = [view convertRect:frame toView:collectionView];
	if(!NSIntersectsRect([collectionView visibleRect], convertedRect)) {
		return NSZeroRect;
	}
	
	frame = [view convertRectToBase:frame];
	frame.origin = [[view window] convertBaseToScreen:frame.origin];
	return frame;
}
- (NSRect)selectionItemRect
{
	if(![collectionView respondsToSelector:@selector(itemAtIndex:)]) {
		return [self selectionItemRectForLeopard];
	}
	
	id item = nil;
	@try {
		item = [collectionView itemAtIndex:[[self representedObject] selectionIndex]];
	}
	@catch (id ex) {
		NSLog(@"Exception -> %@", ex);
		return NSZeroRect;
	}
	
	NSRect rect = [item thumbnailFrameCoordinateBase];
	return rect;
}

#pragma mark#### Test ####
- (void)test01:(id)sender
{
	HMLog(HMLogLevelError, @"hoge");
}
	

@end
