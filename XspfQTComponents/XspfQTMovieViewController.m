//
//  XspfQTMovieViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/12/23.
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

#import "XspfQTMovieViewController.h"
#import "XspfQTDocument.h"
#import "HMXSPFComponent.h"
#import "XspfQTFullScreenWindow.h"
#import "XspfQTMovieWindow.h"

#import <Carbon/Carbon.h>


#pragma mark #### Global Variables ####
/********* Global variables *******/
NSString *XspfQTMovieDidStartNotification = @"XspfQTMovieDidStartNotification";
NSString *XspfQTMovieDidPauseNotification = @"XspfQTMovieDidPauseNotification";


@interface XspfQTMovieViewController (Private)
- (void)play;
- (void)pause;
- (void)movieDidStart;
- (void)movieDidPause;

- (void)enterFullScreen;
- (void)exitFullScreen;
@end


@implementation XspfQTMovieViewController

@synthesize fullScreenMode;

#pragma mark ### Static variables ###
static const float sVolumeDelta = 0.1;
static const NSTimeInterval sUpdateTimeInterval = 0.5;
static NSString *const kQTMovieKeyPath = @"playingMovie";
static NSString *const kIsPlayedKeyPath = @"trackList.isPlayed";
static NSString *const kVolumeKeyPath = @"qtMovie.volume";


- (id)init
{
	self = [super initWithNibName:@"XspfQTMovieView" bundle:nil];
	
	return self;
}
- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[self setQtMovie:nil];
	
	id doc = [self representedObject];
	[doc removeObserver:self forKeyPath:kQTMovieKeyPath];
	[doc removeObserver:self forKeyPath:kIsPlayedKeyPath];
	
	[self movieDidPause];
	[prevMouseMovedDate release];
	
	[fullscreenWindow release];
	
	[super dealloc];
}
- (void)awakeFromNib
{
	prevMouseMovedDate = [[NSDate dateWithTimeIntervalSinceNow:0.0] retain];
	
	id doc = [self representedObject];
	
	[doc addObserver:self
		  forKeyPath:kQTMovieKeyPath
			 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			 context:NULL];
	[doc addObserver:self
		  forKeyPath:kIsPlayedKeyPath
			 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			 context:NULL];
	
//	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//	[nc addObserver:self
//		   selector:@selector(documentWillClose:)
//			   name:XspfQTDocumentWillCloseNotification
//			 object:doc];
	
	[[doc trackList] setSelectionIndex:0];
	[self pause];
}

#pragma mark ### KVO & KVC ###
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:kQTMovieKeyPath]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		[self setQtMovie:new];
		return;
	}
	if([keyPath isEqualToString:kIsPlayedKeyPath]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		if([new boolValue]) {
			[self movieDidStart];
		} else {
			[self movieDidPause];
		}
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setQtMovie:(QTMovie *)qt
{
	if(qtMovie == qt) return;
	if([qtMovie isEqual:qt]) return;
	if(qt == (id)[NSNull null]) qt = nil;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	if(qtMovie) {
		[nc removeObserver:self name:nil object:qtMovie];
	}
	if(qt) {
		[nc addObserver:self selector:@selector(movieDidEndNotification:) name:QTMovieDidEndNotification object:qt];
	}
	
	if(qtMovie) {
		[qt setVolume:[qtMovie volume]];
		[qt setMuted:[qtMovie muted]];
	}
	[qtMovie autorelease];
	qtMovie = [qt retain];
	
	if(!qtMovie) return;
	
	[self play];
}
- (QTMovie *)qtMovie
{
	return qtMovie;
}

- (NSRect)qtViewFrame
{
	return qtView.frame;
}

- (id)document
{
	return self.representedObject;
}

- (void)setFullScreenMode:(BOOL)mode
{
	if(mode && fullScreenMode) return;
	if(!mode && !fullScreenMode) return;
	
	fullScreenMode = mode;
	
	if(fullScreenMode) {
		[self enterFullScreen];
	} else {
		[self exitFullScreen];
	}
}
#pragma mark ### Other functions ###
- (void)movieDidStart
{
	[playButton setTitle:@"||"];
	isPlaying = YES;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:XspfQTMovieDidStartNotification object:self];
}

- (void)movieDidPause
{
	[playButton setTitle:@">"];
	isPlaying = NO;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:XspfQTMovieDidPauseNotification object:self];
}
- (void)play
{
	[qtView performSelectorOnMainThread:@selector(play:) withObject:self waitUntilDone:NO];
}
- (void)pause
{
	[qtView performSelectorOnMainThread:@selector(pause:) withObject:self waitUntilDone:NO];
}
- (void)stop
{
	[qtView performSelectorOnMainThread:@selector(pause:) withObject:self waitUntilDone:YES];
}

- (NSWindow *)fullscreenWindow
{
	if(fullscreenWindow) return fullscreenWindow;
	
	NSRect mainScreenRect = [[NSScreen mainScreen] frame];
	fullscreenWindow = [[XspfQTFullScreenWindow alloc] initWithContentRect:mainScreenRect
																 styleMask:NSBorderlessWindowMask
																   backing:NSBackingStoreBuffered
																	 defer:YES];
	[fullscreenWindow setReleasedWhenClosed:NO];
	[fullscreenWindow setBackgroundColor:[NSColor blackColor]];
	[fullscreenWindow setDelegate:self];
	
	[fullscreenWindow setNextResponder:self];
	
	return fullscreenWindow;
}
- (void)hideMenuBar
{
	if(![NSApp respondsToSelector:@selector(setPresentationOptions:)]) {
		SetSystemUIMode(kUIModeAllHidden, kUIOptionAutoShowMenuBar);
		return;
	}
	
	NSApplicationPresentationOptions currentPresentation = [NSApp presentationOptions];
	[NSApp setPresentationOptions:
	 currentPresentation | (NSApplicationPresentationAutoHideDock | NSApplicationPresentationAutoHideMenuBar)];
}
- (void)showMenuBar
{
	if(![NSApp respondsToSelector:@selector(setPresentationOptions:)]) {
		[NSMenu setMenuBarVisible:YES];
		return;
	}
	
	NSApplicationPresentationOptions currentPresentation = [NSApp presentationOptions];
	[NSApp setPresentationOptions:
	 currentPresentation & ~(NSApplicationPresentationAutoHideDock | NSApplicationPresentationAutoHideMenuBar)];
}
- (void)enterFullScreenWithFullscreenWindow
{
	NSWindow *fullscreen = [self fullscreenWindow];
		
	[self hideMenuBar];
	
	NSRect newWFrame = [[NSScreen mainScreen] frame];
	
	NSRect originalFrame = normalModeSavedFrame = qtView.frame;
	originalFrame.origin = [self.view.window convertBaseToScreen:[self.view convertPointToBase:originalFrame.origin]];
	[fullscreen setFrame:originalFrame display:NO];
	[fullscreen setContentView:qtView];
	[fullscreen makeKeyAndOrderFront:self];
	
	[fullscreen makeFirstResponder:qtView];
	
	NSTimeInterval duration = 0.3;
	[[NSAnimationContext currentContext] setDuration:duration];
	[[fullscreen animator] setFrame:newWFrame display:YES];
	
	[[[self view] window] orderOut:self];
}
- (void)exitFullScreenWithFullscreenWindow
{
	NSTimeInterval duration = 0.3;
	[[NSAnimationContext currentContext] setDuration:duration];
	
	NSRect originalFrame = normalModeSavedFrame;
	originalFrame.origin = [self.view.window convertBaseToScreen:[self.view convertPointToBase:originalFrame.origin]];
	
	[[fullscreenWindow animator] setFrame:originalFrame display:YES];
	
	[[[self view] window] orderWindow:NSWindowBelow relativeTo:[fullscreenWindow windowNumber]];
	
	[self performSelector:@selector(finishFullScreen) withObject:nil afterDelay:duration + 0.01];
}
- (void)finishFullScreen
{
	// move QTView.
	[qtView setFrame:normalModeSavedFrame];
	[self.view addSubview:qtView];
	[self.view.window makeFirstResponder:qtView];
	[fullscreenWindow orderOut:self];
	
	[self showMenuBar];
}

- (void)enterFullScreen
{
	if([[[self view] window] respondsToSelector:@selector(toggleFullScreen:)]) {
		
		NSApplicationPresentationOptions op = [NSApp currentSystemPresentationOptions];
		if((op & NSApplicationPresentationFullScreen) != NSApplicationPresentationFullScreen) {
			[[NSApp mainWindow] toggleFullScreen:self];	
		}
		
		NSRect movieFrame = [qtView frame];
		movieFrame.origin = [[self view] convertPoint:movieFrame.origin toView:nil];
		[qtView setFrame:movieFrame];
		[[[[self view] window] contentView] addSubview:qtView];
		movieFrame.size = [[[self view] window] frame].size;
		movieFrame.origin = NSZeroPoint;
		[[qtView animator] setFrame:movieFrame];
	} else {
		[self enterFullScreenWithFullscreenWindow];
	}
}
- (void)exitFullScreen
{
	if([[[self view] window] respondsToSelector:@selector(toggleFullScreen:)]) {
		NSRect movieFrame = [[self view] frame];
				
		movieFrame.origin.x = 0;
		movieFrame.origin.y = [controllerView frame].size.height;
		movieFrame.size.height -= [controllerView frame].size.height;
		movieFrame.origin = [[self view] convertPoint:movieFrame.origin toView:nil];
		
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			[[qtView animator] setFrame:movieFrame];
		} completionHandler:^(void) {
			NSRect movieFrame = [[self view] frame];
			movieFrame.origin.x = 0;
			movieFrame.origin.y = [controllerView frame].size.height;
			movieFrame.size.height -= [controllerView frame].size.height;
			[qtView setFrame:movieFrame];
			[[self view] addSubview:qtView];
		}];
	} else {
		[self exitFullScreenWithFullscreenWindow];
	}
}

- (void)cancelOperation:(id)sender
{
	self.fullScreenMode = NO;
}
#pragma mark ### Actions ###
- (IBAction)togglePlayAndPause:(id)sender
{
	if([[self valueForKeyPath:@"document.trackList.isPlayed"] boolValue]) {
		[self pause];
	} else {
		[self play];
	}
}
- (IBAction)gotoBeginning:(id)sender
{
	[qtView gotoBeginning:sender];
}

- (IBAction)turnUpVolume:(id)sender
{
	NSNumber *cv = [self valueForKeyPath:kVolumeKeyPath];
	cv = [NSNumber numberWithFloat:[cv floatValue] + sVolumeDelta];
	[self setValue:cv forKeyPath:kVolumeKeyPath];
}
- (IBAction)turnDownVolume:(id)sender
{
	NSNumber *cv = [self valueForKeyPath:kVolumeKeyPath];
	cv = [NSNumber numberWithFloat:[cv floatValue] - sVolumeDelta];
	[self setValue:cv forKeyPath:kVolumeKeyPath];
}

- (IBAction)forwardTagValueSecends:(id)sender
{
	if(![sender respondsToSelector:@selector(tag)]) return;
	
	int tag = [sender tag];
	if(tag == 0) return;
	
	QTTime current = [[self qtMovie] currentTime];
	NSTimeInterval cur;
	if(!QTGetTimeInterval(current, &cur)) return;
	
	QTTime new = QTMakeTimeWithTimeInterval(cur + tag);
	[[self qtMovie] setCurrentTime:new];
}
- (IBAction)backwardTagValueSecends:(id)sender
{
	if(![sender respondsToSelector:@selector(tag)]) return;
	
	int tag = [sender tag];
	if(tag == 0) return;
	
	QTTime current = [[self qtMovie] currentTime];
	NSTimeInterval cur;
	if(!QTGetTimeInterval(current, &cur)) return;
	
	QTTime new = QTMakeTimeWithTimeInterval(cur - tag);
	[[self qtMovie] setCurrentTime:new];
}
- (IBAction)nextTrack:(id)sender
{
	[qtView pause:sender];
	[[[self document] trackList] next];
}
- (IBAction)previousTrack:(id)sender
{
	[qtView pause:sender];
	[[[self document] trackList] previous];
}
- (IBAction)gotoBeginningOrPreviousTrack:(id)sender
{
	QTTime current = [[self qtMovie] currentTime];
	NSTimeInterval cur;
	if(!QTGetTimeInterval(current, &cur)) return;
	
	QTTime duration = [[self qtMovie] duration];
	NSTimeInterval dur;
	if(!QTGetTimeInterval(duration, &dur)) return;
	
	if(cur > (dur * 0.01)) {
		[self gotoBeginning:sender];
	} else {
		[self previousTrack:sender];
	}
}
	
- (IBAction)setThumbnailFrame:(id)sender
{
	[[self document] setThumbnailFrame:sender];
}
- (IBAction)removeThumbnail:(id)sender
{
	[[self document] removeThumbnail:sender];
}
- (IBAction)gotoThumbnailFrame:(id)sender
{
	HMXSPFComponent *trackList = [[self document] trackList];
	HMXSPFComponent *thumbnailTrack = [trackList thumbnailTrack];
	NSTimeInterval time = [trackList thumbnailTimeInterval];
	
	NSUInteger num = [trackList indexOfChild:thumbnailTrack];
	if(num == NSNotFound) return;
	
	[trackList setSelectionIndex:num];
	
	QTTime new = QTMakeTimeWithTimeInterval(time);
	[[self qtMovie] setCurrentTime:new];
}


- (IBAction)toggleFullScreenMode:(id)sender
{
	self.fullScreenMode = !fullScreenMode;
}

#pragma mark ### Notification & Timer ###
- (void)movieDidEndNotification:(id)notification
{
	[[[self document] trackList] next];
}

// call from XspfQTMovieTimer.
- (void)updateTimeIfNeeded:(id)timer
{
	QTMovie *qt = [self qtMovie];
	if(qt) {
		// force update time indicator.
		[qt willChangeValueForKey:@"currentTime"];
		[qt didChangeValueForKey:@"currentTime"];
	}
}

#pragma mark ### NSMenu valivation ###
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	
	if(action == @selector(gotoThumbnailFrame:)) {
		if(![[[self document] trackList] thumbnailTrack]) return NO;
	}
	
	if(action == @selector(togglePlayAndPause:)) {
		if(isPlaying) {
			[menuItem setTitle:NSLocalizedString(@"Pause", @"Pause menu title")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Play", @"Play menu title")];
		}
	}
	
	if(action == @selector(toggleFullScreenMode:)) {
		if(fullScreenMode) {
			[menuItem setTitle:NSLocalizedString(@"Exit Full Screen", @"Exit Full Screen menu title")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Enter Full Screen", @"Enter Full Screen menu title")];
		}
	}
	
	if(action == @selector(removeThumbnail:)) {
		return [[self document] validateMenuItem:menuItem];
	}
	
	return YES;
}

@end
