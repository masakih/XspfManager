//
//  XspfManager.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
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

#import "XspfMMainWindowController.h"

#import "XspfMXspfObject.h"
#import "XspfMListController.h"

#import "XspfMViewController.h"
#import "XspfMLibraryViewController.h"
#import "XspfMCollectionViewController.h"
#import "XspfMListViewController.h"
#import "XspfMDetailViewController.h"
#import "XspfMCoverFlowViewController.h"

#import "XspfMPreferences.h"

#import "XspfQTMovieWindowController.h"
#import "XspfMPlayListViewController.h"

#import "NSControl_Validation.h"


@interface XspfMMainWindowController()
@property (retain) XspfMPlayListViewController *playListViewController;
@property (retain) XspfQTMovieViewController *movieViewController;
@end


@interface XspfMMainWindowController(HMPrivate)
- (void)setupXspfLists;
- (void)setupDetailView;
- (void)setupAccessorylView;
- (void)changeViewType:(XspfMViewType)newType;
- (void)setCurrentListViewType:(XspfMViewType)newType;
- (void)recalculateKeyViewLoop;

- (void)removeSelectedItem;

- (BOOL)isOpenDetailView;
- (BOOL)validateControl:(id)anItem;
- (void)autoControlValidate;

- (void)setOnDetailView;
- (BOOL)prepareWipeIn;

- (void)overlayView:(NSView *)view on:(NSView *)original offset:(NSPoint)offset extend:(NSSize)extend;
@end


@implementation XspfMMainWindowController
@synthesize movieViewController, playListViewController;
@synthesize spin;

- (id)init
{
	self = [super initWithWindowNibName:@"MainWindow"];
	if(self) {
		listViewControllers = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}
- (void)awakeFromNib
{
	static BOOL didSetupOnMainMenu = NO;
	
	if(appDelegate && !didSetupOnMainMenu) {
		didSetupOnMainMenu = YES;
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(managerDidAddObjects:)
				   name:XspfManagerDidAddXspfObjectsNotification
				 object:appDelegate];
		
		[self window];
	}
}
- (void)windowDidLoad
{
	[[self window] setContentBorderThickness:27 forEdge:NSMinYEdge];
	[[self window] setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
	
	[splitView setDelegate:self];
	[self setupXspfLists];
	[self setupDetailView];
	[self setupAccessorylView];
	
	XspfMPreferences *pref = [XspfMPreferences sharedPreference];
	if(!pref.isOpenDetailView) {
		[self showHideDetail:self];
		if(pref.splitViewLeftWidth != 0) {
			[splitView setPosition:pref.splitViewLeftWidth ofDividerAtIndex:0];
		}
	}
	[self validateControl:detailViewButton];
	[self autoControlValidate];
	
	[self setCurrentListViewType:pref.viewType];
	
	[libraryController bind:NSManagedObjectContextBinding
				toObject:appDelegate
			 withKeyPath:@"managedObjectContext"
				 options:nil];
	
	[allXspfController bind:NSManagedObjectContextBinding
				   toObject:appDelegate
				withKeyPath:@"managedObjectContext"
					options:nil];
	
	[self recalculateKeyViewLoop];
	[[self window] update];
	
	[self showWindow:self];

//	[self performSelector:@selector(delayExcute:) withObject:self afterDelay:5.0];
}
- (void)delayExcute:(id)dummy
{
	// load時にこれを行うと循環的にRearrangeが実行されてしまう。
	[libraryController setAutomaticallyRearrangesObjects:YES];
}
#pragma mark#### KVC ####

- (XspfMViewType)currentListViewType
{
	return currentListViewType;
}
- (void)setCurrentListViewType:(XspfMViewType)newType
{
	if(currentListViewType == newType) return;
	
	[XspfMPreferences sharedPreference].viewType = newType;
	
	[self changeViewType:newType];
	[self autoControlValidate];
}

- (XspfMViwMode)mode
{
	return appDelegate.mode;
}
- (void)setMode:(XspfMViwMode)newMode
{
	appDelegate.mode = newMode;
	[self performSelector:@selector(autoControlValidate) withObject:nil afterDelay:0.0];
}
- (void)relocateSpin
{
	NSRect spinRect = spin.frame;
	NSRect contentViewFrame = listPlaceholderView.frame;
	spinRect.origin.x = (NSWidth(contentViewFrame) - NSWidth(spinRect)) / 2;
	spinRect.origin.y = (NSHeight(contentViewFrame) - NSHeight(spinRect)) / 2;
	spin.frame = spinRect;
}
- (NSProgressIndicator *)spin
{
	if(spin) {
		[self relocateSpin];
		return spin;
	}
	
	NSRect spinRect = { {0,0}, {200,200} };
	spin = [[[NSProgressIndicator alloc] initWithFrame:spinRect] autorelease];
	spin.usesThreadedAnimation = YES;
	spin.style = NSProgressIndicatorSpinningStyle;
	[spin setDisplayedWhenStopped:YES];
	[spin sizeToFit];
	[self relocateSpin];
	[listPlaceholderView addSubview:spin];
	return spin;
}

- (BOOL)isOpenDetailView
{
	NSView *view = [detailViewController view];
	if(![view superview]) return NO;
	NSRect visRect = [view visibleRect];
	return !(NSEqualRects(visRect, NSZeroRect));
}

#pragma mark#### Actions ####
- (IBAction)returnToList:(id)sender
{
	movieViewController.fullScreenMode = NO;
	
	NSView *playerView = movieViewController.view;
	[listPlaceholderView addSubview:listViewController.view positioned:NSWindowBelow relativeTo:playerView];
	
	[movieViewController pause];
	
	[self performSelector:@selector(wipeOut) withObject:nil afterDelay:0.0];
	self.mode = modeList;
}

- (IBAction)openXspf:(id)sender
{
	BOOL isSelected = controller.isSelected;
	if(!isSelected) return;
	
	if(![self prepareWipeIn]) {
		XspfMXspfObject *rep = controller.selectedItem;
		NSInteger result = NSRunCriticalAlertPanel(NSLocalizedString(@"Xspf is not found", @"Xspf is not found"),
												   NSLocalizedString(@"\"%@\" is not found.",  @"\"%@\" is not found."),
												   nil, nil/*@"Search Original"*/, nil, rep.title);
		if(result == NSAlertDefaultReturn) {
			return;
		} else if(result == NSAlertAlternateReturn) {
			//
#warning should implement.
		}
		
		return;
	}
	
	[self performSelector:@selector(wipeIn) withObject:nil afterDelay:0.0];
}
- (IBAction)switchListView:(id)sender
{
	[self setCurrentListViewType:typeTableView];
}
- (IBAction)switchRegularIconView:(id)sender
{
	[self setCurrentListViewType:typeCollectionView];
	[(XspfMCollectionViewController *)listViewController collectionViewItemViewRegular:sender];
}
- (IBAction)switchSmallIconView:(id)sender
{
	[self setCurrentListViewType:typeCollectionView];
	[(XspfMCollectionViewController *)listViewController collectionViewItemViewSmall:sender];
}
- (IBAction)switchCoverFlowView:(id)sender
{
	[self setCurrentListViewType:typeCoverFlowView];
}
- (IBAction)rotateViewType:(id)sender
{
	NSInteger newType = currentListViewType + 1;
	if(newType > 3) newType = 1;
	[self setCurrentListViewType:newType];
}
- (IBAction)switchActiveView:(id)sender
{
	id firstResponder = self.window.firstResponder;
	if(firstResponder == listViewController.initialFirstResponder) {
		[[self window] makeFirstResponder:[libraryViewController initialFirstResponder]];
	} else {
		[[self window] makeFirstResponder:[listViewController initialFirstResponder]];
	}
}

- (IBAction)add:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"xspf", @"com.masakih.xspf", nil]];
	[panel setAllowsMultipleSelection:YES];
	[panel setDelegate:self];
	
	BOOL hasBlocks = NSClassFromString(@"NSBlock") ? YES : NO;
	if(hasBlocks) {
		[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"xspf", @"com.masakih.xspf", nil]];
		[panel beginSheetModalForWindow:[self window]
					  completionHandler:^(NSInteger result) {
						  if(result == NSCancelButton) return;
						  NSArray *URLs = [panel URLs];
						  if([URLs count] == 0) return;
						  [appDelegate registerURLs:URLs];
					  }];
	} else {
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		[panel beginSheetForDirectory:nil
								 file:nil
								types:[NSArray arrayWithObjects:@"xspf", @"com.masakih.xspf", nil]
					   modalForWindow:[self window]
						modalDelegate:self
					   didEndSelector:@selector(endOpenPanel:::)
						  contextInfo:NULL];
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	}
}
- (void)endOpenPanel:(NSOpenPanel *)panel :(NSInteger)returnCode :(void *)context
{
	[panel orderOut:nil];
	
	if(returnCode == NSCancelButton) return;
	
	NSArray *URLs = [panel URLs];
	if([URLs count] == 0) return;
	
	[appDelegate registerURLs:URLs];
}
- (IBAction)delete:(id)sender
{
	[self remove:sender];
}
- (IBAction)remove:(id)sender
{
	[self removeSelectedItem];
}

- (IBAction)newPredicate:(id)sender
{
	[libraryViewController createPredicate:sender];
}

- (IBAction)showHideDetail:(id)sender
{
	XspfMPreferences *pref = [XspfMPreferences sharedPreference];
	
	NSPoint origin = [detailPlaceholderView frame].origin;
	NSSize size = NSZeroSize;
	
	CGFloat detailWidth = [detailPlaceholderView frame].size.width;
	if(![self isOpenDetailView]){ // show
		origin.x -= detailWidth;
		size = [splitView frame].size;
		size.width -= detailWidth;
		
		pref.openDetailView = YES;
		[self setOnDetailView];
	} else { // hide
		origin.x += detailWidth;
		size = [splitView frame].size;
		size.width += detailWidth;
		
		pref.openDetailView = NO;
	}
	[[detailPlaceholderView animator] setFrameOrigin:origin];
	[[splitView animator] setFrameSize:size];
	
	// アニメーションが終わってから確認する。
	NSAnimationContext *context = [NSAnimationContext currentContext];
	NSTimeInterval duration = [context duration];
	[self performSelector:@selector(validateControl:) withObject:detailViewButton afterDelay:duration + 0.1];
	[self performSelector:@selector(pullOutDetailView:) withObject:nil afterDelay:duration + 0.11];
}
- (BOOL)validateMenuItemForListMode:(NSMenuItem *)menuItem
{
	BOOL enabled = YES;
	SEL action = [menuItem action];
	
	if(action == @selector(switchListView:)) {
		if(currentListViewType == typeTableView) {
			[menuItem setState:NSOnState];
		} else {
			[menuItem setState:NSOffState];
		}
	} else if(action == @selector(switchRegularIconView:)) {
		if(currentListViewType == typeCollectionView 
		   && [(XspfMCollectionViewController*)listViewController collectionItemType] == typeXspfMRegularItem) {
			[menuItem setState:NSOnState];
		} else {
			[menuItem setState:NSOffState];
		}
	} else if(action == @selector(switchSmallIconView:)) {
		if(currentListViewType == typeCollectionView
			&& [(XspfMCollectionViewController*)listViewController collectionItemType] == typeXSpfMSmallItem) {
			[menuItem setState:NSOnState];
		} else {
			[menuItem setState:NSOffState];
		}
	} else if(action == @selector(switchCoverFlowView:)) {
		if(currentListViewType == typeCoverFlowView) {
			[menuItem setState:NSOnState];
		} else {
			[menuItem setState:NSOffState];
		}
	} else if(action == @selector(showHideDetail:)) {
		if([self isOpenDetailView]) {
			[menuItem setTitle:NSLocalizedString(@"Hide Detail", @"Hide Detail")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Show Detail", @"Show Detail")];
		}
	}
	
	if(action == @selector(remove:) || action == @selector(delete:)) {
		if(!controller.isSelected) return NO;
		
		NSView *listView_ = [listViewController view];
		id responder = [[self window] firstResponder];
		while(responder) {
			if(listView_ == responder) return YES;
			responder = [responder nextResponder];
		}
		enabled = NO;
	}
	
	if([controller respondsToSelector:[menuItem action]]) {
		return [controller validateMenuItem:menuItem];
	}
	
	return enabled;
}
- (BOOL)validateMenuItemForMovieMode:(NSMenuItem *)menuItem
{
	if([movieViewController respondsToSelector:[menuItem action]]) {
		return [movieViewController validateMenuItem:menuItem];
	}
	
	return YES;
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	switch(appDelegate.mode) {
		case modeList:
			return [self validateMenuItemForListMode:menuItem];
			break;
		case modeMovie:
			return [self validateMenuItemForMovieMode:menuItem];
			break;
	}
	
	return NO;
}

- (BOOL)validateControl:(NSControl *)anItem
{
	if([detailViewButton isEqual:anItem]) {
		if([self isOpenDetailView]) {
			[detailViewButton setImage:[NSImage imageNamed:@"NSRightFacingTriangleTemplate"]];
			[detailViewButton setToolTip:NSLocalizedString(@"Hide Detail", @"Hide Detail")];
		} else {
			[detailViewButton setImage:[NSImage imageNamed:@"NSLeftFacingTriangleTemplate"]];
			[detailViewButton setToolTip:NSLocalizedString(@"Show Detail", @"Show Detail")];
			
			id keyView = [[self window] firstResponder];
			if(![keyView respondsToSelector:@selector(visibleRect)]) return NO;
			if(NSEqualSizes([keyView visibleRect].size, NSZeroSize)) {
				[[self window] makeFirstResponder:[listViewController initialFirstResponder]];
			}
		}
		[self recalculateKeyViewLoop];
		return YES;
	}
	
	SEL action = [anItem action];
	if(action == @selector(newPredicate:)) {
		if(self.mode == modeMovie) {
			return NO;
		}
	}
	return YES;
}
#pragma mark#### Other methods ####
- (void)removeSelectedItem
{
	XspfMXspfObject *obj = controller.selectedItem;
	
	NSBeginInformationalAlertSheet(nil, nil, @"Cancel", nil, [self window],
								   self, @selector(didEndAskDelete:::), Nil, obj,
								   NSLocalizedString(@"Do you really delete item  \"%@\" from list?", @"Do you really delete item  \"%@\" from list?"),
								   obj.title);
}
- (void)didEndAskDelete:(NSWindow *)sheet :(NSInteger)returnCode :(void *)contextInfo
{
	if(returnCode == NSCancelButton) return;
	
	[appDelegate removeObject:contextInfo];
}

- (void)recalculateKeyViewLoop
{
	[searchField setNextKeyView:[libraryViewController firstKeyView]];
	[libraryViewController setNextKeyView:[listViewController firstKeyView]];
	if([self isOpenDetailView]) {
		[listViewController setNextKeyView:[detailViewController firstKeyView]];
		[detailViewController setNextKeyView:searchField];
		HMLog(HMLogLevelDebug, @"Recalc with detail.");
	} else {
		[listViewController setNextKeyView:searchField];
		HMLog(HMLogLevelDebug, @"Recalc without detail.");
	}
}
- (void)overlayView:(NSView *)view on:(NSView *)original offset:(NSPoint)offset extend:(NSSize)extend
{
	NSRect frame = original.frame;
	frame.origin = offset;
	frame.size.width += extend.width;
	frame.size.height += extend.height;
	view.frame = frame;
	[original addSubview:view];
}
- (void)changeViewType:(XspfMViewType)viewType
{
	if(currentListViewType == viewType) return;
	currentListViewType = viewType;
	
	NSString *className = nil;
	switch(currentListViewType) {
		case typeCollectionView:
			className = @"XspfMCollectionViewController";
			break;
		case typeTableView:
			className = @"XspfMListViewController";
			break;
		case typeCoverFlowView:
			className = @"XspfMCoverFlowViewController";
			break;
		case typeNotSelected:
		default:
			break;
	}
	if(!className) return;
	
	XspfMViewController *targetContorller = [listViewControllers objectForKey:className];
	if(!targetContorller) {
		targetContorller = [[[NSClassFromString(className) alloc] init] autorelease];
		if(!targetContorller) return;
		
		id selectionIndexes = [controller selectionIndexes];
		[listViewControllers setObject:targetContorller forKey:className];
		[targetContorller view];
		[targetContorller setRepresentedObject:controller];
		[targetContorller recalculateKeyViewLoop];
		[controller setSelectionIndexes:selectionIndexes];
	}
	
	[[listViewController view] removeFromSuperview];
	listViewController = targetContorller;
	[self overlayView:listViewController.view
				   on:listPlaceholderView
			   offset:NSMakePoint(0, -1)
			   extend:NSMakeSize(0, 1)];
//	[[self window] recalculateKeyViewLoop];
	[self recalculateKeyViewLoop];
	
	/* TODO 
	 環境設定で変更可能にする
	 */
	[listViewController performSelector:@selector(scrollToSelection:) withObject:self afterDelay:0.0];
}

- (void)selectAndScrollTo:(XspfMXspfObject *)object
{
	[controller setSelectedObjects:[NSArray arrayWithObject:object]];
	[listViewController scrollToSelection:nil];
	[libraryViewController selectLibrayItem:nil];
}
- (void)createPlayList:(id)sender
{
	NSDocumentController *dc = [NSDocumentController sharedDocumentController];
	NSError *error = nil;
	NSDocument *doc = [dc makeUntitledDocumentOfType:@"com.masakih.xspf"
											   error:&error];
	if(!doc) {
		NSString *errorString;
		if(error) {
			errorString = [NSString stringWithFormat:@"%@", [error localizedDescription]];
		} else {
			errorString = [NSString stringWithFormat:@"Could not create new documnet."];
		}
		NSLog(@"%@", errorString);
		NSBeep();
		return;
	}
	NSURL *newDocumentURL = [appDelegate availableFileURL];
	[doc setFileURL:newDocumentURL];
	[doc saveDocument:nil];
	
	XspfMXspfObject *object = [appDelegate registerWithURL:newDocumentURL];
	[self performSelector:@selector(selectAndScrollTo:)
			   withObject:object
			   afterDelay:0.0];
	[doc close];
}

- (void)setOnDetailView
{
	[self overlayView:detailViewController.view
				   on:detailPlaceholderView
			   offset:NSZeroPoint
			   extend:NSZeroSize];
}
- (void)pullOutDetailView:(id)dummy
{
	if([self isOpenDetailView]) return;
	[detailViewController.view removeFromSuperview];
	HMLog(HMLogLevelDebug, @"PullOut");
}

- (void)removePlayerView
{
	NSView *playerView = movieViewController.view;
	[playerView setHidden:YES];
	[playerView removeFromSuperview];
	
	// List view
	NSView *playListView = playListViewController.view;
	[playListView removeFromSuperview];
	self.playListViewController = nil;
	
	NSDocument *doc = [movieViewController representedObject];
	if([doc hasUnautosavedChanges]) {
		[doc saveDocument:nil];
	}
	[doc close];
	self.movieViewController = nil;
	
	[[self window] makeFirstResponder:[listViewController initialFirstResponder]];
}
- (void)hideListContentView
{
	[listViewController.view removeFromSuperview];
	[spin stopAnimation:self];
	
	[movieViewController play];
}


- (void)wipeOut
{
	NSTimeInterval duration = 0.3;
	[[NSAnimationContext currentContext] setDuration:duration];
	
	NSView *playerView = movieViewController.view;
	NSRect listViewFrame = listPlaceholderView.frame;
	NSView *listViewContentView = listViewController.view;
	NSRect listViewContentViewFrame = listViewContentView.frame;
	listViewContentViewFrame.origin.x = 0;
	listViewContentViewFrame.size = listViewFrame.size;
	[[listViewContentView animator] setFrame:listViewContentViewFrame];
	
	NSRect playerViewFrame = playerView.frame;
	playerViewFrame.origin.x = NSWidth(listViewFrame);
	[[playerView animator] setFrame:playerViewFrame];
	
	// List view
	NSView *playListView = playListViewController.view;
	NSRect playListViewFrame = playListView.frame;
	playListViewFrame.origin.y = -NSHeight(libraryPlaceholderView.frame);
	[[playListView animator] setFrame:playListViewFrame];
	
	[self performSelector:@selector(removePlayerView) withObject:nil afterDelay:duration + 0.01];
}
- (void)wipeIn
{
	NSTimeInterval duration = 0.3;
	[[NSAnimationContext currentContext] setDuration:duration];
	
	NSView *playerView = movieViewController.view;
	NSView *listViewContentView = listViewController.view;
	NSRect listViewContentViewFrame = listViewContentView.frame;
	listViewContentViewFrame.origin.x -= NSWidth(listPlaceholderView.frame);
	[[listViewContentView animator] setFrame:listViewContentViewFrame];
	
	NSRect playerViewFrame = playerView.frame;
	playerViewFrame.origin.x = 0;
	[[playerView animator] setFrame:playerViewFrame];
	
	
	// List view
	NSView *playListView = playListViewController.view;
	NSRect playListViewFrame = playListView.frame;
	playListViewFrame.origin.y = -1;
	[[playListView animator] setFrame:playListViewFrame];
	
	[self performSelector:@selector(hideListContentView) withObject:nil afterDelay:duration + 0.01];
}
- (BOOL)prepareWipeIn
{
	[self.spin startAnimation:self];
	XspfMXspfObject *rep = controller.selectedItem;
	
	NSError *error = nil;
	NSDocumentController *dc = [NSDocumentController sharedDocumentController];
	NSDocument *doc = [dc openDocumentWithContentsOfURL:rep.url
												display:NO
												  error:&error];
	if(doc) {
		rep.lastPlayDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
	} else {
		[spin stopAnimation:self];
		return NO;
	}
	self.mode = modeMovie;
	[doc makeWindowControllers];
	
	NSArray *windowControllers = [doc windowControllers];
	[windowControllers makeObjectsPerformSelector:@selector(window)];
	XspfQTMovieWindowController *windowController = [windowControllers objectAtIndex:0];
	self.movieViewController = windowController.contentViewController;
	[self overlayView:movieViewController.view
				   on:listPlaceholderView
			   offset:NSMakePoint(NSWidth(listPlaceholderView.frame), 0)
			   extend:NSZeroSize];
	
	self.playListViewController = [[[XspfMPlayListViewController alloc] init] autorelease];
	playListViewController.representedObject = doc;
	[self overlayView:playListViewController.view
				   on:libraryPlaceholderView
			   offset:NSMakePoint(-1, -NSHeight(libraryPlaceholderView.frame) - 1)
			   extend:NSMakeSize(1, 1)];
	
	return YES;
}

#pragma mark#### Set up views ####
- (void)setupXspfLists
{
	if(libraryViewController) return;
	
	libraryViewController = [[XspfMLibraryViewController alloc] init];
	[libraryViewController setRepresentedObject:libraryController];
	[self overlayView:libraryViewController.view
				   on:libraryPlaceholderView
			   offset:NSMakePoint(-1, -1)
			   extend:NSMakeSize(2, 1)];
	[libraryViewController recalculateKeyViewLoop];
}
- (void)setupDetailView
{
	if(detailViewController) return;
	
	detailViewController = [[XspfMDetailViewController alloc] init];
	[detailViewController setRepresentedObject:controller];
	[self overlayView:detailViewController.view
				   on:detailPlaceholderView
			   offset:NSZeroPoint
			   extend:NSZeroSize];
	[detailViewController recalculateKeyViewLoop];
}
- (void)setupAccessorylView
{
	if(accessoryViewController) return;
	
	accessoryViewController = [[NSViewController alloc] initWithNibName:@"AccessoryView" bundle:nil];
	[accessoryViewController setRepresentedObject:[appDelegate channel]];
	[self overlayView:accessoryViewController.view
				   on:accessoryPlaceholderView
			   offset:NSZeroPoint
			   extend:NSZeroSize];
//	[accessoryViewController recalculateKeyViewLoop];
}
#pragma mark#### NSWidnow Delegate ####
/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[appDelegate managedObjectContext] undoManager];
}

- (void)windowWillClose:(NSNotification *)notification
{
	XspfMPreferences *pref = [XspfMPreferences sharedPreference];
	pref.splitViewLeftWidth = [libraryPlaceholderView frame].size.width;
}

- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
{
	return proposedOptions | NSApplicationPresentationAutoHideToolbar;
}

#pragma mark#### NSOpenPanel Delegate ####
- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
	return ![appDelegate didRegisteredURL:[NSURL fileURLWithPath:filename]];
}
#pragma mark#### NSSplitView Delegate ####
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return 130;
}
- (void)splitView:(NSSplitView *)aSplitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
	NSView *rightView = [[splitView subviews] objectAtIndex:1];
	NSRect newFrame = [splitView frame];
	NSRect libFrame = [libraryPlaceholderView frame];
	NSRect listFrame = [rightView frame];
	CGFloat dividerThickness = [splitView dividerThickness];
	
	libFrame.size.height = newFrame.size.height;
	listFrame.size.height = newFrame.size.height;
	
	listFrame.size.width = newFrame.size.width - libFrame.size.width - dividerThickness;
	
	if(listFrame.size.width < 0) listFrame.size.width = 0;
	
	[libraryPlaceholderView setFrame:libFrame];
	[rightView setFrame:listFrame];
}

#pragma mark#### XspfManager Notifications ####
- (void)managerDidAddObjects:(NSNotification *)notification
{
	id addedObjects = [[notification userInfo] objectForKey:@"XspfManagerAddedXspfObjects"];
	if(!addedObjects || ![addedObjects isKindOfClass:[NSArray class]] || [addedObjects count] == 0) return;
	
	[controller performSelector:@selector(setSelectedObjects:)
					 withObject:addedObjects
					 afterDelay:0.01];
}

#pragma mark#### Test ####
- (IBAction)test01:(id)sender
{
	id firstKeyView = [[self window] firstResponder];
	NSView *view = firstKeyView;
	do {
		HMLog(HMLogLevelDebug, @"KeyView -> %@", view);
		view = [view nextValidKeyView];
	} while(view && view != firstKeyView);
}
- (IBAction)test02:(id)sender
{
	NSResponder *responder = [[self window] firstResponder];
	while(responder) {
		HMLog(HMLogLevelDebug, @"Responder -> %@", responder);
		responder = [responder nextResponder];
	}
}
//- (IBAction)test03:(id)sender
//{
//	[listController setAutomaticallyRearrangesObjects:YES];
//
//}
@end

@implementation XspfMMainWindowController (MessageForwarding)
- (BOOL)respondsToSelector:(SEL)aSelector
{
	if([super respondsToSelector:aSelector]) return YES;
	if([movieViewController respondsToSelector:aSelector]) return YES;
	if([controller respondsToSelector:aSelector]) return YES;
	
	return NO;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	if([movieViewController respondsToSelector:aSelector]) {
		return [movieViewController methodSignatureForSelector:aSelector];
	}
	if([controller respondsToSelector:aSelector]) {
		return [controller methodSignatureForSelector:aSelector];
	}
	return [super methodSignatureForSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	SEL selector = [anInvocation selector];
	if([movieViewController respondsToSelector:selector]) {
		[anInvocation invokeWithTarget:movieViewController];
		return;
	}
	if([controller respondsToSelector:selector]) {
		[anInvocation invokeWithTarget:controller];
		return;
	}
}

@end
