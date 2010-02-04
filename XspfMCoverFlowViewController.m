//
//  XspfMCoverFlowViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/21.
//  Copyright 2010 masakih. All rights reserved.
//

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
		
	unsigned short code = [theEvent keyCode];
	switch(code) {
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
//	NSDictionary *attr = [NSDictionary dictionaryWithObject:[NSColor darkGrayColor]  forKey:NSForegroundColorAttributeName];
//	[coverFlow setValue:attr forKey:IKImageBrowserCellsSubtitleAttributesKey];
	
	listViewController = [[XspfMListViewController alloc] init];
	[listViewController view];
	[listViewController setRepresentedObject:rep];
	[listViewController recalculateKeyViewLoop];
	[listPlaceHolder addSubview:[listViewController view]];
	[[listViewController view] setFrame:[listPlaceHolder bounds]];
	[self recalculateKeyViewLoop];
	
	[splitView setDelegate:self];
}

- (void)setRepresentedObject:(id)representedObject
{
	id oldRep = [self representedObject];
	if([oldRep isEqual:representedObject]) return;
	
	[oldRep unbind:@"arrangedObjects"];
	[oldRep unbind:@"selectionIndex"];
	
	if(representedObject) {
		[representedObject addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
		[representedObject addObserver:self forKeyPath:@"selectionIndex" options:0 context:NULL];
		[coverFlow setSelectedIndex:[representedObject selectionIndex]];
	}
	
	[super setRepresentedObject:representedObject];
	[listViewController setRepresentedObject:representedObject];
	[coverFlow reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"arrangedObjects"]) {
		[coverFlow reloadData];
		return;
	}
	if([keyPath isEqualToString:@"selectionIndex"]) {
		[coverFlow setSelectedIndex:[[self representedObject] selectionIndex]];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (NSUInteger)numberOfItemsInImageFlow:(id)imageFlowView
{
	return [[[self representedObject] arrangedObjects] count];
}
- (id)imageFlow:(id)imageFlowView itemAtIndex:(NSUInteger)index
{
	return [[[self representedObject] arrangedObjects] objectAtIndex:index];
}

- (void)imageFlow:(id)imageFlowView didSelectItemAtIndex:(NSUInteger)index
{
	[[self representedObject] setSelectionIndex:index];
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
