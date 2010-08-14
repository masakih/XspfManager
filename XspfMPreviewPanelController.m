//
//  XspfMPreviewPanelController.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/02/13.
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

#import "XspfMPreviewPanelController.h"

#import "XspfMXspfObject.h"

#import "XspfMMainWindowController.h"
#import "XspfMViewController.h"


@interface NSPanel(XspfMPreviewPanelSupport)
+ (NSPanel *)sharedPreviewPanel;

- (BOOL)isOpen;
- (void)setCurrentPreviewItemIndex:(NSUInteger)index;
- (NSUInteger)currentPreviewItemIndex;

// for Leopard
- (void)setURLs:(NSArray *)URLs;
- (void)setURLs:(NSArray *)URLs currentIndex:(NSUInteger)index preservingDisplayState:(BOOL)flag;
- (void)makeKeyAndOrderFrontWithEffect:(NSInteger)mode;
- (void)closeWithEffect:(NSInteger)mode;
@end


@interface XspfMPreviewPanelController (XpsfMPrivate)
- (void)didChangeMainWindowNotification:(id)notification;
@end

static NSInteger osVersion = 0;
static id previewPanel = nil;

@implementation XspfMPreviewPanelController
@synthesize mainWController;
@synthesize controller;

+ (void)initialize
{
	static BOOL isFirst = YES;
	if(isFirst) {
		isFirst = NO;
		if([[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/QuickLookUI.framework"] load]) {
			HMLog(HMLogLevelNotice, @"Quick Look for 10.5 loaded!");
			osVersion = 105;
		}
		if([[NSBundle bundleWithPath:@"/System/Library/Frameworks/Quartz.framework/Frameworks/QuickLookUI.framework"] load]) {
			HMLog(HMLogLevelNotice, @"Quick Look for 10.6 loaded!");
			osVersion = 106;
		}
	}
}

- (id)init
{
	self = [super init];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(didChangeMainWindowNotification:)
			   name:NSWindowDidBecomeMainNotification
			 object:nil];
	[self didChangeMainWindowNotification:nil];
	return self;
}

- (NSPanel *)previewPanel
{
	Class aClass = NSClassFromString(@"QLPreviewPanel");
	if(!aClass) {
		NSBeep();
		return nil;
	}
	return [aClass sharedPreviewPanel];
}
- (XspfMMainWindowController *)mainWindowController
{
	NSWindowController *wController = [[NSApp mainWindow] windowController];
	
	if([wController isKindOfClass:[XspfMMainWindowController class]]) {
		return (XspfMMainWindowController *)wController;
	}
	return nil;
}
- (void)didChangeMainWindowNotification:(id)notification
{
	XspfMMainWindowController *wController = [self mainWindowController];
	if(!wController) return;
	
	self.mainWController = wController;
}
- (void)setMainWController:(id)newController
{
	if(mainWController == newController) return;
	
	mainWController = newController;
	
	[self setNextResponder:[mainWController nextResponder]];
	[mainWController setNextResponder:self];
	
	self.controller = [mainWController valueForKey:@"controller"];
}
- (void)setController:(id)newController
{
	if(controller == newController) return;
	
	[controller removeObserver:self forKeyPath:@"selectionIndex"];
	
	controller = newController;
	[controller addObserver:self forKeyPath:@"selectionIndex" options:0 context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selectionIndex"]) {
		if(osVersion == 105) {
			id qlPanel = [self previewPanel];
			[qlPanel setURLs:[[controller selectedObjects] valueForKey:@"url"]];
		} else {
			[previewPanel reloadData];
		}
		
		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
#pragma mark#### PreviewPanel Support ####
- (IBAction)togglePreviewPanel:(id)panel
{
	id qlPanel = [self previewPanel];
	
	if([qlPanel isOpen]) {
		if(osVersion == 105) {
			[qlPanel closeWithEffect:2];
		} else if(osVersion >= 106) {
			[qlPanel orderOut:nil];
		}
		
		return;
	}
	
	if(osVersion == 105) {
		[qlPanel setDelegate:self];
		[qlPanel setURLs:[[controller selectedObjects] valueForKey:@"url"]];
		[qlPanel makeKeyAndOrderFrontWithEffect:2];
	} else if(osVersion >= 106) {
		[qlPanel makeKeyAndOrderFront:nil];
	}
}

#pragma mark---- QLPreviewPanelController ----
- (BOOL)acceptsPreviewPanelControl:(id /*QLPreviewPanel* */)panel
{
	return YES;
}
- (void)beginPreviewPanelControl:(id /*QLPreviewPanel* */)panel
{
	previewPanel = [panel retain];
	[panel setDelegate:self];
	[panel setDataSource:self];
}
- (void)endPreviewPanelControl:(id /*QLPreviewPanel* */)panel
{
	[previewPanel release];
	previewPanel = nil;
}

#pragma mark---- QLPreviewPanelDataSource ----
- (NSInteger)numberOfPreviewItemsInPreviewPanel:(id /*QLPreviewPanel* */)panel
{
	return [[controller selectedObjects] count];
}
- (id /*<QLPreviewItem>*/)previewPanel:(id)panel previewItemAtIndex:(NSInteger)index
{
	return [[controller selectedObjects] objectAtIndex:index];
}
#pragma mark---- QLPreviewPanelDelegate ----
- (BOOL)previewPanel:(id /*QLPreviewPanel* */)panel handleEvent:(NSEvent *)event
{
	if ([event type] == NSKeyDown) {
		NSResponder *target = nil;
		id listViewController = [mainWController valueForKey:@"listViewController"];
		target = [listViewController initialFirstResponder];
		if(!target) {
			target = [listViewController firstKeyView];
		}
		if(!target) {
			target = [listViewController view];
		}
		if(!target) return NO;
		
		[target keyDown:event];
		return YES;
	}
	return NO;
}
- (NSRect)previewPanel:(id /*QLPreviewPanel* */)panel sourceFrameOnScreenForPreviewItem:(id /*<QLPreviewItem>*/)item
{
	return [[mainWController valueForKey:@"listViewController"] selectionItemRect];
}

- (id)previewPanel:(id /*QLPreviewPanel* */)panel transitionImageForPreviewItem:(id /*<QLPreviewItem>*/)item contentRect:(NSRect *)contentRect
{
	XspfMXspfObject *obj = item;
	return obj.thumbnail;
}

// for Leopard
- (BOOL)previewPanel:(id)panel shouldHandleEvent:(NSEvent *)theEvent
{
	return ![self previewPanel:panel handleEvent:theEvent];
}
- (NSRect)previewPanel:(id)panel frameForURL:(NSURL *)url
{
	return [self previewPanel:panel sourceFrameOnScreenForPreviewItem:url];
}
@end

@implementation XspfMXspfObject (XspfMPreviewPanelSupport)
- (NSString *)previewItemTitle
{
	return self.title;
}
- (NSURL *)previewItemURL
{
	return self.url;
}
@end
