//
//  XspfMCoverFlowViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/21.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2010, masakih
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
 Copyright (c) 2010, masakih
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

#import "XspfMCoverFlowViewController.h"

#import "XspfMListViewController.h"

#import "XspfMXspfObject.h"
#import <Quartz/Quartz.h>

#import <objc/runtime.h>

@interface NSObject(XpsfMIKImageFlowViewSupport)
- (void)setShowSplitter:(BOOL)flag;
- (void)setInlinePreviewEnabled:(BOOL)flag;
- (void)setSelectedIndex:(NSUInteger)index;
- (NSRect)selectedImageFrame;
- (id)cacheManager;


- (void)IKCleanTimedOutCache;
@end

@implementation XspfMCoverFlowViewController

static IMP originalKeyDown = NULL;
+ (void)initialize
{
	static BOOL isFirst = YES;
	if(isFirst) {
		isFirst = NO;
		
		Method originalMethod = class_getInstanceMethod(NSClassFromString(@"IKImageFlowView"), @selector(keyDown:));
		Method replacedMethod = class_getInstanceMethod(self, @selector(hackKeyDown:));
		IMP replacedIMP = method_getImplementation(replacedMethod);
		originalKeyDown = method_setImplementation(originalMethod, replacedIMP);
	}
}
- (void)hackKeyDown:(NSEvent *)theEvent
{
	if([theEvent isARepeat]) goto finish;
	
#define kRETURN_KEY	36
#define kENTER_KEY	52
	unsigned short code = [theEvent keyCode];
	switch(code) {
		case kRETURN_KEY:
		case kENTER_KEY:
			[NSApp sendAction:@selector(openXspf:) to:nil from:nil];
			return;
		case 49:
			[NSApp sendAction:@selector(togglePreviewPanel:) to:nil from:nil];
			return;
	}
finish:
	originalKeyDown(self, _cmd, theEvent);
}

- (id)init
{
	self = [super initWithNibName:@"XspfMCoverFlowView" bundle:nil];
	
	return self;
}

- (void)awakeFromNib
{
	NSArrayController *rep = [self representedObject];
	
	[coverFlow setShowSplitter:YES];
	if([coverFlow respondsToSelector:@selector(setInlinePreviewEnabled:)]) {
		[coverFlow setInlinePreviewEnabled:YES];
	}
	[coverFlow setDataSource:self];
	[coverFlow setDelegate:self];
	
	listViewController = [[XspfMListViewController alloc] init];
	[listViewController view];
	[listViewController setRepresentedObject:rep];
	[listViewController recalculateKeyViewLoop];
	[listPlaceHolder addSubview:[listViewController view]];
	[[listViewController view] setFrame:[listPlaceHolder bounds]];
	[self recalculateKeyViewLoop];
	
	[splitView setDelegate:self];
}

- (void)setupLate
{
	[[NSApp mainWindow] addObserver:self forKeyPath:@"firstResponder" options:0 context:NULL];
}

- (void)setRepresentedObject:(id)representedObject
{
	id oldRep = [self representedObject];
	if([oldRep isEqual:representedObject]) return;
	
	if(representedObject) {
		[representedObject addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
		[representedObject addObserver:self forKeyPath:@"selectionIndex" options:0 context:NULL];
		[coverFlow setSelectedIndex:[representedObject selectionIndex]];
	}
	
	[super setRepresentedObject:representedObject];
	[listViewController setRepresentedObject:representedObject];
	[coverFlow reloadData];
	
	[self performSelector:@selector(setupLate) withObject:nil afterDelay:0.5];
}
- (void)recalculateKeyViewLoop
{
//	[coverFlow setNextKeyView:[listViewController firstKeyView]];
	
	// TODO: change key view loop if list view is not visible.
//	lastKeyView = [listViewController lastKeyView];
	
	firstKeyView = [listViewController firstKeyView];
	initialFirstResponder = [listViewController firstKeyView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"arrangedObjects"]) {
		[coverFlow reloadData];
		return;
	}
	if([keyPath isEqualToString:@"selectionIndex"]) {
		[coverFlow setSelectedIndex:[[self representedObject] selectionIndex]];
		[listViewController scrollToSelection:self];
		return;
	}
	if([keyPath isEqualToString:@"firstResponder"]) {
		id firstResponder = [[splitView window] firstResponder];
		if(firstResponder == coverFlow) {
			[[splitView window] makeFirstResponder:[listViewController view]];
		}
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)keyDown:(NSEvent *)theEvent
{
	unsigned short code = [theEvent keyCode];
#define kLEFT_ARROW_KEY 123
#define kRIGHT_ARROW_KEY 124
	switch(code) {
		case kLEFT_ARROW_KEY:
		case kRIGHT_ARROW_KEY:
			return [coverFlow keyDown:theEvent];
			break;
	}
	NSBeep();
}

- (IBAction)clearCoverFlowCache:(id)sender
{
	if(![coverFlow respondsToSelector:@selector(cacheManager)]) {
		NSBeep();
		return;
	}
	id cacheManager = [coverFlow cacheManager];
	if(![cacheManager respondsToSelector:@selector(IKCleanTimedOutCache)]) {
		NSBeep();
		return;
	}
	[cacheManager IKCleanTimedOutCache];
}
- (IBAction)test01:(id)sender
{
	[self clearCoverFlowCache:sender];
}

- (NSUInteger)numberOfItemsInImageFlow:(id)imageFlowView
{
	return [[[self representedObject] arrangedObjects] count];
}
- (id)imageFlow:(id)imageFlowView itemAtIndex:(NSUInteger)index
{
	return [[[self representedObject] arrangedObjects] objectAtIndex:index];
}

- (void)setRepSelectedIndex:(NSNumber *)indexValue
{
	[[self representedObject] setSelectionIndex:[indexValue unsignedIntegerValue]];
}
- (void)imageFlow:(id)imageFlowView didSelectItemAtIndex:(NSUInteger)index
{
//	[[self representedObject] setSelectionIndex:index];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(setRepSelectedIndex:)
			   withObject:[NSNumber numberWithUnsignedInteger:index]
			   afterDelay:0.5];
}
- (void)imageFlow:(id)imageFlowView cellWasDoubleClickedAtIndex:(NSUInteger)index
{
	[NSApp sendAction:@selector(openXspf:) to:nil from:nil];
}
- (void)imageFlow:(id)imageFlowView startResizingWithEvent:(NSEvent *)theEvent
{
	NSPoint offset = [imageFlowView convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSWindow *window = [imageFlowView window];
	while (theEvent = [window nextEventMatchingMask:NSLeftMouseDraggedMask | NSLeftMouseUpMask]) {
		if(NSEventMaskFromType([theEvent type]) == NSLeftMouseUpMask) break;
		
		NSPoint p = [splitView convertPoint:[theEvent locationInWindow] fromView:nil];
		[splitView setPosition:p.y+offset.y ofDividerAtIndex:0];
	}
}

- (IBAction)scrollToSelection:(id)sender
{
	[listViewController scrollToSelection:sender];
}

// QLPreviewPanel support
- (NSRect)selectionItemRect
{
	NSRect rect = [coverFlow selectedImageFrame];
	rect = [coverFlow convertRectToBase:rect];
	rect.origin = [[coverFlow window] convertBaseToScreen:rect.origin];
	return rect;
}

#pragma mark#### NSSplitView Delegate ####
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return 130;
}
- (void)splitView:(NSSplitView *)aSplitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
	NSView *rightView = [[splitView subviews] objectAtIndex:1];
	NSRect newsplitViewFrame = [splitView frame];
	NSRect coverFlowFrame = [coverFlow frame];
	NSRect listFrame = [rightView frame];
	CGFloat dividerThickness = [splitView dividerThickness];
	
	coverFlowFrame.size.width = newsplitViewFrame.size.width;
	listFrame.size.width = newsplitViewFrame.size.width;
	
	coverFlowFrame.size.height = newsplitViewFrame.size.height - listFrame.size.height - dividerThickness;
	
	if(listFrame.size.height < 0) {
		listFrame.size.height = 0;
		coverFlowFrame.size = newsplitViewFrame.size;
	}
	
	coverFlowFrame.origin.y = 0;
	listFrame.origin.y = NSMaxY(coverFlowFrame) + dividerThickness;
	
	[coverFlow setFrame:coverFlowFrame];
	[rightView setFrame:listFrame];
}

@end


@implementation XspfMXspfObject(XspfMIKImageBrowserItem)
/*! 
 @method imageUID
 @abstract Returns a unique string that identify this data source item (required).
 @discussion The image browser uses this identifier to keep the correspondance between its cache and the data source item  
 */
- (NSString *)  imageUID
{
	return self.urlString;
}

/*! 
 @method imageRepresentationType
 @abstract Returns the representation of the image to display (required).
 @discussion Keys for imageRepresentationType are defined below.
 */
- (NSString *) imageRepresentationType
{
	return IKImageBrowserQuickLookPathRepresentationType;
}

/*! 
 @method imageRepresentation
 @abstract Returns the image to display (required). Can return nil if the item has no image to display.
 @discussion This methods is called frequently, so the receiver should cache the returned instance.
 */
- (id) imageRepresentation
{
	return self.url;
}

/*! 
 @method imageVersion
 @abstract Returns a version of this item. The receiver can return a new version to let the image browser knows that it shouldn't use its cache for this item
 */
//- (NSUInteger) imageVersion;

/*! 
 @method imageTitle
 @abstract Returns the title to display as a NSString. Use setValue:forKey: with IKImageBrowserCellTitleAttribute to set text attributes.
 */
- (NSString *) imageTitle
{
	return self.title;
}

/*! 
 @method imageSubtitle
 @abstract Returns the subtitle to display as a NSString. Use setValue:forKey: with IKImageBrowserCellSubtitleAttribute to set text attributes.
 */
- (NSString *) imageSubtitle
{
	return [NSString stringWithFormat:
			NSLocalizedString(@"%@ Movies", @"%@ Movies"),
			self.movieNum];
}

/*! 
 @method isSelectable
 @abstract Returns whether this item is selectable. 
 @discussion The receiver can implement this methods to forbid selection of this item by returning NO.
 */
//- (BOOL) isSelectable;

@end
