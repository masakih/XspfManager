//
//  XspfMLibraryViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
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

#import "XspfMLibraryViewController.h"

#import "XspfMXspfListObject.h"

#import "XspfMRuleEditorDelegate.h"

#import "XspfMPreferences.h"


@interface XspfMLibraryViewController (HMPrivate)
- (NSArray *)sortDescriptors;
- (void)setupXspfList;
- (void)setupRules;

- (NSNumber *)orderForNewItem;

- (void)moveItemOfIndexSet:(NSIndexSet *)indexSet afterIndex:(NSInteger)afterIndex;
@end

enum {
	kLibraryOrder = 0,
	kFavoritesOrder,
	kSmartLibraryOrder,
};

const NSInteger initialOrder = 10000;
const NSInteger orderStep = 10000;

static NSString *const XspfMLibItemPbardType = @"XspfMLibItemPbardType";

@implementation XspfMLibraryViewController

- (id)init
{
	[super initWithNibName:@"LibraryView" bundle:nil];
	
	[self setupXspfList];
	[self setupRules];
	
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[[self representedObject] setSortDescriptors:[self sortDescriptors]];
	
	[tableView registerForDraggedTypes:[NSArray arrayWithObject:XspfMLibItemPbardType]];
	[tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
	
	
	[self performSelector:@selector(delayExcute:) withObject:self afterDelay:0.02];
}
- (void)delayExcute:(id)dummy
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(windowWillClose:)
			   name:NSWindowWillCloseNotification
			 object:[self.view window]];
	
	XspfMPreferences *pref = [XspfMPreferences sharedPreference];
	[xspfListController setSelectionIndex:pref.libraryLastSelectedIndexSet];
}

- (NSArray *)sortDescriptors
{
	id desc = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	return [NSArray arrayWithObject:[desc autorelease]];
}

- (void)addSmartLibrary:(NSString *)name predicate:(NSPredicate *)predicate order:(NSInteger)order
{
	id obj = [NSEntityDescription insertNewObjectForEntityForName:@"XspfList"
										   inManagedObjectContext:[self managedObjectContext]];
	[obj setValue:predicate forKey:@"predicate"];
	[obj setValue:name forKey:@"name"];
	[obj setValue:[self orderForNewItem] forKey:@"order"];
}
- (void)setupXspfList
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSInteger num;
	
	fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"XspfList"
								 inManagedObjectContext:moc]];
	num = [moc countForFetchRequest:fetch
							  error:&error];
	if(num != 0) return;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlString <> %@", @""];
	[self addSmartLibrary:@"Library"
				predicate:predicate
					order:kLibraryOrder];
	
	predicate = [NSPredicate predicateWithFormat:@"favorites = %@", [NSNumber numberWithBool:YES]];
	[self addSmartLibrary:@"Favorites"
				predicate:predicate
					order:kFavoritesOrder];
}

- (void)setupRules
{
	[XspfMRuleEditorDelegate registerStringTypeKeyPaths:[NSArray arrayWithObjects:@"title", @"information.voiceActorsList", @"information.productsList", nil]];
	[XspfMRuleEditorDelegate registerDateTypeKeyPaths:[NSArray arrayWithObjects:@"lastPlayDate", @"modificationDate", @"creationDate", nil]];
	[XspfMRuleEditorDelegate setUseRating:YES];
	[XspfMRuleEditorDelegate setUseLablel:YES];
}

- (BOOL)mouseInTableView
{
	NSEvent *event = [[[self view] window] currentEvent];
	NSPoint mouse = [[tableView superview] convertPoint:[event locationInWindow] fromView:nil];
	
	return NSPointInRect(mouse, [tableView visibleRect]);
}
- (XspfMXspfListObject *)targetObject
{
	id array = [[self representedObject] arrangedObjects];
	
	NSInteger row = [tableView clickedRow];
	if(row >= 0 && [array count] > row) {
		return [array objectAtIndex:row];
	}
	
	if(![self mouseInTableView]) {
		NSArray *selection = [[self representedObject] selectedObjects];
		if([selection count] != 0) {
			return [selection objectAtIndex:0];
		}
	}
	return nil;
}

	
- (BOOL)canUseNewSmartLibraryName:(NSString *)newName
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSPredicate *predicate;
	NSInteger num;
	
	fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"XspfList"
								 inManagedObjectContext:moc]];
	predicate = [NSPredicate predicateWithFormat:@"name = %@", newName];
	[fetch setPredicate:predicate];
	num = [moc countForFetchRequest:fetch
							  error:&error];
	
	return num == 0;
}
- (NSString *)usableSmartLibraryName
{
	NSString *template = NSLocalizedString(@"Untitled Library", @"Untitled Library");
	
	if([self canUseNewSmartLibraryName:template]) return template;
	
	NSInteger i = 1;
	do {
		NSString *name = [NSString stringWithFormat:@"%@ %d", template, i];
		if([self canUseNewSmartLibraryName:name]) return name;
	} while (i++ < INT_MAX);
	
	return @"hoge";
}

#pragma mark #### Actions ####
- (IBAction)createPredicate:(id)sender
{
	if([editor numberOfRows] == 0) {
		[editor addRow:self];
	}
		
	[nameField setStringValue:[self usableSmartLibraryName]];
	[nameField selectText:self];
	
	[NSApp beginSheet:predicatePanel
	   modalForWindow:[tableView window]
		modalDelegate:self
	   didEndSelector:@selector(didEndEditPredicate:returnCode:contextInfo:)
		  contextInfo:@"Createion"];
}
- (IBAction)editPredicate:(id)sender
{
	XspfMXspfListObject *obj = [sender representedObject];
	if(!obj) {
		HMLog(HMLogLevelError, @"-[%@ %@] paramater's representedObject is nil.",
			  NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}
	[nameField setStringValue:obj.name];
	[nameField selectText:self];
	
	[ruleEditorDelegate setPredicate:obj.predicate];
	
	[NSApp beginSheet:predicatePanel
	   modalForWindow:[tableView window]
		modalDelegate:self
	   didEndSelector:@selector(didEndEditPredicate:returnCode:contextInfo:)
		  contextInfo:obj];
}
- (IBAction)deletePredicate:(id)sender
{
	XspfMXspfListObject *obj = [sender representedObject];
	if(!obj) {
		HMLog(HMLogLevelError, @"-[%@ %@] paramater's representedObject is nil.",
			  NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}
	NSBeginInformationalAlertSheet(nil, nil, @"Cancel", nil, [[self view] window],
								   self, @selector(didEndAskDelete:::), Nil, obj,
								   NSLocalizedString(@"Do you really delete smart library \"%@\"?", @"Do you really delete smart library \"%@\"?"),
								   obj.name);
}
- (IBAction)didEndEditPredicate:(id)sender
{
	[predicatePanel orderOut:self];
	[NSApp endSheet:predicatePanel returnCode:[sender tag]];
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

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	if(action == @selector(editPredicate:)
	   || action == @selector(deletePredicate:)) {
		XspfMXspfListObject *obj = [self targetObject];
		if(!obj) return NO;
		if(obj.order == kLibraryOrder || obj.order == kFavoritesOrder) return NO;
		[menuItem setRepresentedObject:obj];
	}
	
	return YES;
}

- (void)didEndEditPredicate:(id)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSCancelButton) return;
	
	[editor reloadPredicate];
	NSPredicate *predicate = [editor predicate];
	
	if(!predicate || ![predicate isKindOfClass:[NSPredicate class]]) {
		HMLog(HMLogLevelError, @"Could not create NSPredicate.");
		NSBeep();
		return;
	}
	if(![predicate isKindOfClass:[NSCompoundPredicate class]]) {
		predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObject:predicate]];
	}
	
	NSString *name = [nameField stringValue];
	if([name length] == 0) {
		NSBeep();
		NSBeginAlertSheet(nil, nil, nil, nil, [[self view] window],
						  self, @selector(retryEditPredicate:::), Nil, contextInfo,
						  NSLocalizedString(@"Name must not be empty.", @"Name must not be empty."));
		return;
	}
	
	if([(id)contextInfo isKindOfClass:[NSString class]]) {
		[self addSmartLibrary:name predicate:predicate order:kSmartLibraryOrder];
	} else {
		XspfMXspfListObject *obj = contextInfo;
		obj.name = name;
		obj.predicate = predicate;
	}
}
- (void)retryEditPredicate:(NSWindow *)sheet :(NSInteger)returnCode :(void *)contextInfo
{
	if([(id)contextInfo isKindOfClass:[NSString class]]) {
		[self performSelector:@selector(createPredicate:) withObject:nil afterDelay:0.0];
	} else {
		[self performSelector:@selector(editPredicate:) withObject:nil afterDelay:0.0];
	}
}
- (void)didEndAskDelete:(NSWindow *)sheet :(NSInteger)returnCode :(void *)contextInfo
{
	if(returnCode == NSCancelButton) return;
	
	[[self managedObjectContext] deleteObject:contextInfo];
}

#pragma mark#### NSTableView Data Source ####
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	if([rowIndexes containsIndex:0] || [rowIndexes containsIndex:1]) return NO;
	
	[pboard declareTypes:[NSArray arrayWithObject:XspfMLibItemPbardType] owner:self];
	
	return [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:rowIndexes] forType:XspfMLibItemPbardType];
}

- (NSDragOperation)tableView:(NSTableView*)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	if(row == 0 || row == 1) return NSDragOperationNone;
	
	if(dropOperation == NSTableViewDropOn) {
		[aTableView setDropRow:row
				dropOperation:NSTableViewDropAbove];
	}
	
	return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView*)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
	NSPasteboard *pboard = [info draggingPasteboard];
	NSIndexSet *indexSet = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:XspfMLibItemPbardType]];
	
	[self moveItemOfIndexSet:indexSet afterIndex:row - 1];
	[xspfListController rearrangeObjects];
		
	return YES;
}


#pragma mark-
- (void)packOrder
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order <> %@ AND order <> %@",
							  [NSNumber numberWithInt:kLibraryOrder], [NSNumber numberWithInt:kFavoritesOrder]];
	NSEntityDescription *entry = [NSEntityDescription entityForName:@"XspfList"
											 inManagedObjectContext:moc];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:entry];
	[fetch setPredicate:predicate];
	[fetch setSortDescriptors:[self sortDescriptors]];
	
	NSError *error = nil;
	NSArray *objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			HMLog(HMLogLevelError, @"fail fetch reason -> %@", error);
		}
	}
	
	NSInteger newOrder = initialOrder;
	for(XspfMXspfListObject *obj in objects) {
		obj.order = newOrder;
		newOrder += orderStep;
	}
}

- (NSNumber *)orderForNewItem
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order <> %@ AND order <> %@",
							  [NSNumber numberWithInt:kLibraryOrder], [NSNumber numberWithInt:kFavoritesOrder]];
	NSEntityDescription *entry = [NSEntityDescription entityForName:@"XspfList"
											 inManagedObjectContext:moc];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:entry];
	[fetch setPredicate:predicate];
	[fetch setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO] autorelease]]];
	[fetch setFetchLimit:1];
	
	NSError *error = nil;
	NSArray *objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			HMLog(HMLogLevelError, @"fail fetch reason -> %@", error);
		}
	}
	HMLog(HMLogLevelDebug, @"objects -> %@", objects);
	
	if(!objects && [objects count] == 0) return [NSNumber numberWithInteger:initialOrder];
	XspfMXspfListObject *last = [objects lastObject];
	
	return [NSNumber numberWithInteger:last.order + orderStep];
}

- (void)moveToLastFromIndexSet:(NSIndexSet *)indexSet
{
	id array = [[self representedObject] arrangedObjects];
	XspfMXspfListObject *afterItem = [array lastObject];
	NSInteger insertPoint = afterItem.order + orderStep;
	NSUInteger targetIndex = [indexSet firstIndex];
	while(targetIndex != NSNotFound) {
		XspfMXspfListObject *targetItem = [array objectAtIndex:targetIndex];
		targetItem.order = insertPoint;
		insertPoint += orderStep;
		
		targetIndex = [indexSet indexGreaterThanIndex:targetIndex];
	}
}
- (void)moveItemOfIndexSet:(NSIndexSet *)indexSet afterIndex:(NSInteger)afterIndex
{
	id array = [[self representedObject] arrangedObjects];
	
	if([array count] <= afterIndex + 1) {
		[self moveToLastFromIndexSet:indexSet];
		return;
	}
	
	XspfMXspfListObject *afterItem = [array objectAtIndex:afterIndex];
	XspfMXspfListObject *beforeItem = [array objectAtIndex:afterIndex + 1];
	
	NSInteger diff = beforeItem.order - afterItem.order;
	if(diff - 1 < [indexSet count]) {
		[self packOrder];
		[self moveItemOfIndexSet:indexSet afterIndex:afterIndex];
		return;
	}
	
	NSInteger step = diff / ([indexSet count] + 1);
	NSInteger insertPoint = afterItem.order + step;
	NSUInteger targetIndex = [indexSet firstIndex];
	while(targetIndex != NSNotFound) {
		XspfMXspfListObject *targetItem = [array objectAtIndex:targetIndex];
		targetItem.order = insertPoint;
		insertPoint += step;
		
		targetIndex = [indexSet indexGreaterThanIndex:targetIndex];
	}
	
	[self packOrder];
}

#pragma mark#### NSWindow Delegate ####
- (void)windowWillClose:(NSNotification *)notification
{
	if(self.view.window != notification.object) return;
	
	XspfMPreferences *pref = [XspfMPreferences sharedPreference];
	pref.libraryLastSelectedIndexSet = xspfListController.selectionIndex;
}

#pragma mark-

//- (IBAction)test01:(id)sender
//{
//	NSArray *array = [editor rowTemplates];
	
//	for(id templ in array) {
//		HMLog(HMLogLevelDebug @"Views -> %@", [templ templateViews]);
//		for(id v in [templ templateViews]) {
//			if([v respondsToSelector:@selector(tag)]) {
//				HMLog(HMLogLevelDebug, @"tag -> %d", [v tag]);
//			}
//		}
//	}
//	for(id templ in array) {
//		HMLog(HMLogLevelDebug, @"template -> %@", templ);
//	}
//}

@end
