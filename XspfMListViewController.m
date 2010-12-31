//
//  XspfMListViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/07.
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

#import "XspfMListViewController.h"

#import "XspfManager.h"

#import "XspfMTableView.h"

#import "XspfMXspfObject.h"


@implementation XspfMListViewController

- (id)init
{
	[super initWithNibName:@"ListView" bundle:nil];
	
	return self;
}
- (void)awakeFromNib
{
	[tableView setDoubleAction:@selector(openXspf:)];
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (NSMenu *)contextMenuForObject:(XspfMXspfObject *)object
{
	NSMenu *objMenu = [[NSApp delegate] menuForXspfObject:object];
	return objMenu;
}

- (NSMenu *)tableView:(XspfMTableView *)table menuForEvent:(NSEvent *)event
{
	NSPoint mouse = [table convertPoint:[event locationInWindow] fromView:nil];
	NSInteger row = [table rowAtPoint:mouse];
	if(row == NSNotFound || row == -1) return nil;
	
	XspfMXspfObject *object = [[[self representedObject] arrangedObjects] objectAtIndex:row];
	return [self contextMenuForObject:object];
}
- (void)tableView:(NSTableView *)table sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
//	HMLog(HMLogLevelDebug, @"Enter %@, desc-> %@", NSStringFromSelector(_cmd), [table sortDescriptors]);
	id controller = [self representedObject];
	[controller willChangeValueForKey:@"selectionIndexes"];
	[controller didChangeValueForKey:@"selectionIndexes"];
}


- (NSDragOperation)tableView:(NSTableView*)table
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(NSInteger)row
	   proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	id pb = [info draggingPasteboard];
	id plist = [pb propertyListForType:NSFilenamesPboardType];
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSError *error = nil;
	for(NSString *filePath in plist) {
		NSString *type = [ws typeOfFile:filePath error:&error];
		if(![ws type:type conformsToType:@"com.masakih.xspf"]) {
			return NSDragOperationNone;
		}
	}
	[table setDropRow:row dropOperation:NSTableViewDropAbove];
	
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView*)table
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(NSInteger)row
	dropOperation:(NSTableViewDropOperation)dropOperation
{
	id pb = [info draggingPasteboard];
	id plist = [pb propertyListForType:NSFilenamesPboardType];
	
	[[NSApp delegate] registerFilePaths:plist];
	
	return YES;
}

- (IBAction)scrollToSelection:(id)sender
{
	NSInteger col = [tableView columnWithIdentifier:@"title"];
	NSInteger row = [tableView selectedRow];
	NSRect rect = [tableView frameOfCellAtColumn:col row:row];
	
	[tableView scrollRectToVisible:rect];
}
- (void)moveUp:(id)sender
{
	NSUInteger row = [tableView selectedRow];
	if(row == 0) return;
	
	NSIndexSet *newSelection = [NSIndexSet indexSetWithIndex:row - 1];
	[tableView selectRowIndexes:newSelection byExtendingSelection:NO];
}
- (void)moveDown:(id)sender
{
	NSUInteger row = [tableView selectedRow];
	if(row == [tableView numberOfRows] - 1) return;
	
	NSIndexSet *newSelection = [NSIndexSet indexSetWithIndex:row + 1];
	[tableView selectRowIndexes:newSelection byExtendingSelection:NO];
}


// QLPreviewPanel support
- (NSRect)selectionItemRect
{
	NSInteger col = [tableView columnWithIdentifier:@"title"];
	NSInteger row = [tableView selectedRow];
	NSRect rect = [tableView frameOfCellAtColumn:col row:row];
	
	if(!NSIntersectsRect([tableView visibleRect], rect)) {
		return NSZeroRect;
	}
	
	rect = [tableView convertRectToBase:rect];
	rect.origin = [[tableView window] convertBaseToScreen:rect.origin];
	rect.size.width = rect.size.height;
	return rect;
}
@end
