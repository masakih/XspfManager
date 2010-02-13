//
//  XspfMPreviewPanelController.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/02/13.
//  Copyright 2010 masakih. All rights reserved.
//

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
			NSLog(@"Quick Look for 10.5 loaded!");
			osVersion = 105;
		}
		if([[NSBundle bundleWithPath:@"/System/Library/Frameworks/Quartz.framework/Frameworks/QuickLookUI.framework"] load]) {
			NSLog(@"Quick Look for 10.6 loaded!");
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
//			[qlPanel setURLs:[[controller selectedObjects] mutableArrayValueForKey:@"url"]];
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
//		[qlPanel setURLs:[[controller selectedObjects] mutableArrayValueForKey:@"url"]];
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
