//
//  XspfMCollectionView.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/03.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionView.h"


@implementation XspfMCollectionView

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

#pragma mark#### NSDoragging ####
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
- (void)mouseDown:(NSEvent *)theEvent
{
	if([theEvent clickCount] != 2) return [super mouseDown:theEvent];
	
	if(delegate) {
		[delegate enterAction:self];
	}
}
- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent isARepeat]) return [super keyDown:theEvent];
	
#define kRETURN_KEY	36
#define kENTER_KEY	52
#define kTAB_KEY	48
	
	unsigned short code = [theEvent keyCode];
//	HMLog(HMLogLevelDebug, @"code -> %d", code);
	switch(code) {
		case kRETURN_KEY:
		case kENTER_KEY:
			if(delegate) {
				[delegate enterAction:self];
				return;
			}
			break;
		case kTAB_KEY:
			if(([theEvent modifierFlags] | NSShiftKeyMask) == NSShiftKeyMask) {
				[[self window] selectPreviousKeyView:nil];
			} else {
				[[self window] selectNextKeyView:nil];
			}
			return;
			break;
	}
	
	HMLog(HMLogLevelDebug, @"enter %@", theEvent);
	[super keyDown:theEvent];
}

@end
