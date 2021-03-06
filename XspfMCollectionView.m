//
//  XspfMCollectionView.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/03.
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

#import "XspfMCollectionView.h"

#import "XspfManager.h"

@implementation XspfMCollectionView
@synthesize delegate;

- (void)awakeFromNib
{
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if(draggingHilight) {
		NSRect visible = [self visibleRect];
		[[NSColor selectedControlColor] set];
//		NSSetFocusRingStyle(NSFocusRingOnly);
		NSFrameRectWithWidth(visible, 3);
	}
}

#pragma mark#### NSDragging ####
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	id pb = [sender draggingPasteboard];
	id plist = [pb propertyListForType:NSFilenamesPboardType];
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSError *error = nil;
	for(NSString *filePath in plist) {
		NSString *type = [ws typeOfFile:filePath error:&error];
		if(![ws type:type conformsToType:@"com.masakih.xspf"]) {
			return NSDragOperationNone;
		}
	}
	
	[[[self enclosingScrollView] contentView] setCopiesOnScroll:NO];
	draggingHilight = YES;
	[self displayRect:[self visibleRect]];
	
	return NSDragOperationCopy;
}
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{	
	return [self draggingEntered:sender];
}
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	draggingHilight = NO;
	[self displayRect:[self visibleRect]];
}
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	id pb = [sender draggingPasteboard];
	id plist = [pb propertyListForType:NSFilenamesPboardType];
	
	[[NSApp delegate] registerFilePaths:plist];
	
	return YES;
}
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
//	HMLog(HMLogLevelDebug, @"Enter method %@", NSStringFromSelector(_cmd));
}
- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
	[[[self enclosingScrollView] contentView] setCopiesOnScroll:YES];
	draggingHilight = NO;
	[self displayRect:[self visibleRect]];
}
- (BOOL)wantsPeriodicDraggingUpdates
{
	return NO;
}

#pragma mark#### NSResponder ####
//- (void)mouseDown:(NSEvent *)theEvent
//{
//	if([theEvent clickCount] != 2) return [super mouseDown:theEvent];
//	
//	if(delegate) {
//		[delegate enterAction:self];
//	}
//}
- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent isARepeat]) return [super keyDown:theEvent];
	
	NSString *charactor = [theEvent charactersIgnoringModifiers];
	if([charactor length] == 0) return [super keyDown:theEvent];
	
	unichar uc = [charactor characterAtIndex:0];
	switch(uc) {
		case NSEnterCharacter:
		case NSNewlineCharacter:
		case NSFormFeedCharacter:
		case NSCarriageReturnCharacter:
			if(delegate) {
				[delegate enterAction:self];
				return;
			}
			break;
		case NSTabCharacter:
			if(([theEvent modifierFlags] | NSShiftKeyMask) == NSShiftKeyMask) {
				[[self window] selectPreviousKeyView:nil];
			} else {
				[[self window] selectNextKeyView:nil];
			}
			return;
			break;
		case ' ':
			[NSApp sendAction:@selector(togglePreviewPanel:) to:nil from:nil];
			return;
			break;
	}
	
	[super keyDown:theEvent];
}

@end
