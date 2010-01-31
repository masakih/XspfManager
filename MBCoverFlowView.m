/*
 
 The MIT License
 
 Copyright (c) 2009 Matthew Ball
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "MBCoverFlowView.h"

#import "MBCoverFlowScroller.h"
#import "NSImage+MBCoverFlowAdditions.h"

#import <QuartzCore/QuartzCore.h>


// Private class. add by masakih
/* This layer never hit by -[CALyer hitTest:].
 */
@interface MBNeverHitLayer : CALayer
@end
@implementation MBNeverHitLayer
- (BOOL)containsPoint:(CGPoint)p
{
	return FALSE;
}
@end

// Constants
#define MBCoverFlowViewCellSpacing ([self itemSize].width/10.0)

const float MBCoverFlowViewPlaceholderHeight = 600.0;

const float MBCoverFlowViewTopMargin = 30.0;
const float MBCoverFlowViewBottomMargin = 20.0;
const float MBCoverFlowViewHorizontalMargin = 12.0;
// change by masakih
// #define MBCoverFlowViewContainerMinY (self.accessoryController?NSMaxY([self.accessoryController.view frame]):0.0 - 3.0*[self itemSize].height/4.0)
static inline CGFloat _MBCoverFlowViewContainerMinY(MBCoverFlowView *view);
#define MBCoverFlowViewContainerMinY _MBCoverFlowViewContainerMinY(self)
const float MBCoverFlowAnchorPointY = 0.75;

const float MBCoverFlowScrollerHorizontalMargin = 80.0;
const float MBCoverFlowScrollerVerticalSpacing = 16.0;

const float MBCoverFlowViewDefaultItemWidth = 140.0;
const float MBCoverFlowViewDefaultItemHeight = 100.0;

const float MBCoverFlowScrollMinimumDeltaThreshold = 0.4;

// Perspective parameters
const float MBCoverFlowViewPerspectiveCenterPosition = 100.0;
const float MBCoverFlowViewPerspectiveSidePosition = 0.0;
const float MBCoverFlowViewPerspectiveSideSpacingFactor = 0.75;
const float MBCoverFlowViewPerspectiveRowScaleFactor = 0.85;
const float MBCoverFlowViewPerspectiveAngle = 0.79;

// KVO
static NSString *MBCoverFlowViewImagePathContext;

// Key Codes
#define MBLeftArrowKeyCode 123
#define MBRightArrowKeyCode 124
#define MBReturnKeyCode 36

// Class variable
static NSGradient *_shadowGradient = nil;


@interface MBCoverFlowView ()
- (float)_positionOfSelectedItem;
- (CALayer *)_insertLayerInScrollLayer;
- (void)_scrollerChange:(MBCoverFlowScroller *)scroller;
- (void)_refreshLayer:(CALayer *)layer;
- (void)_loadImageForLayer:(CALayer *)layer;
- (CALayer *)_layerForObject:(id)object;
- (void)_recachePlaceholder;
- (void)_setSelectionIndex:(NSInteger)index; // For two-way bindings

// add by masakih
- (void)recalcSubviewSize;
- (void)_updateMaskConstraint;
static inline void _removeActionFromLayer(NSString *action, CALayer *layer);
static inline CALayer *_imageLayerForItemLayer(CALayer *itemLayer);
static inline CALayer *_reflectionLayerForItemLayer(CALayer *itemLayer);

static BOOL drawBorderForDebug = NO;
@end


@implementation MBCoverFlowView

@synthesize accessoryController=_accessoryController, selectionIndex=_selectionIndex, 
            itemSize=_itemSize, content=_content, showsScrollbar=_showsScrollbar,
            autoresizesItems=_autoresizesItems, imageKeyPath=_imageKeyPath,
            placeholderIcon=_placeholderIcon, target=_target, action=_action,
			dragControl=_dragControl;	// add by masakih.

@dynamic selectedObject;

#pragma mark -
#pragma mark Life Cycle

+ (void)initialize
{
	[self exposeBinding:@"content"];
	[self exposeBinding:@"selectionIndex"];
}

- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		_bindingInfo = [[NSMutableDictionary alloc] init];
		
		_imageLoadQueue = [[NSOperationQueue alloc] init];
		[_imageLoadQueue setMaxConcurrentOperationCount:1];
		
		_placeholderIcon = [[NSImage imageNamed:NSImageNameQuickLookTemplate] retain];
		
		_autoresizesItems = YES;
		
		// Create the scroller
		_scroller = [[MBCoverFlowScroller alloc] initWithFrame:NSMakeRect(10, 10, 400, 16)];
		[_scroller setEnabled:YES];
		[_scroller setTarget:self];
		[_scroller setHidden:YES];
		[_scroller setKnobProportion:1.0];
		[_scroller setAction:@selector(_scrollerChange:)];
		
		// add by masakih
		[_scroller setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
		[self addSubview:_scroller];
		
		_leftTransform = CATransform3DMakeRotation(-MBCoverFlowViewPerspectiveAngle, 0, -1, 0);
		_rightTransform = CATransform3DMakeRotation(MBCoverFlowViewPerspectiveAngle, 0, -1, 0);
		
		_itemSize = NSMakeSize(MBCoverFlowViewDefaultItemWidth, MBCoverFlowViewDefaultItemHeight);
		
		CALayer *rootLayer = [CALayer layer];
		rootLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
		rootLayer.backgroundColor = CGColorGetConstantColor(kCGColorBlack);
		[self setLayer:rootLayer];
		
		_containerLayer = [CALayer layer];
		_containerLayer.name = @"body";
		[_containerLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:@"superlayer" attribute:kCAConstraintMidX]];
		[_containerLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:@"superlayer" attribute:kCAConstraintWidth offset:-20]];
		[_containerLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
		[_containerLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY offset:-10]];
		// add by masakih
		if(drawBorderForDebug) {
			_containerLayer.borderWidth = 2;
			_containerLayer.borderColor = CGColorGetConstantColor(kCGColorWhite);
		}
		[rootLayer addSublayer:_containerLayer];
		
		_scrollLayer = [CAScrollLayer layer];
		_scrollLayer.scrollMode = kCAScrollHorizontally;
		_scrollLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
		_scrollLayer.layoutManager = self;
		[_containerLayer addSublayer:_scrollLayer];
		
		// Create a gradient image to use for image shadows
		
		if(!_shadowGradient) {
			_shadowGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0 alpha:0.6]
															endingColor:[NSColor colorWithDeviceWhite:0 alpha:1.0]];
		}
		CGRect gradientRect;
		gradientRect.origin = CGPointZero;
		gradientRect.size = NSSizeToCGSize([self itemSize]);
		size_t bytesPerRow = 4*gradientRect.size.width;
		void* bitmapData = malloc(bytesPerRow * gradientRect.size.height);
		CGContextRef context = CGBitmapContextCreate(bitmapData, gradientRect.size.width,
													 gradientRect.size.height, 8,  bytesPerRow, 
													 CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaPremultipliedFirst);
		NSGraphicsContext *nsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES];
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:nsContext];
		[_shadowGradient drawInRect:NSMakeRect(0, 0, gradientRect.size.width, gradientRect.size.height) angle:90];
		[NSGraphicsContext restoreGraphicsState];
		_shadowImage = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		free(bitmapData);
		
		/* create a pleasant gradient mask around our central layer.
		 We don't have to worry about re-creating these when the window
		 size changes because the images will be automatically interpolated
		 to their new sizes; and as gradients, they are very well suited to
		 interpolation. */
		CALayer *maskLayer = [CALayer layer];
		_leftGradientLayer = [CALayer layer];
		_rightGradientLayer = [CALayer layer];
		
		// left
		gradientRect;
		gradientRect.origin = CGPointZero;
		gradientRect.size.width = [self frame].size.width;
		gradientRect.size.height = [self frame].size.height;
		bytesPerRow = 4*gradientRect.size.width;
		bitmapData = malloc(bytesPerRow * gradientRect.size.height);
		context = CGBitmapContextCreate(bitmapData, gradientRect.size.width,
										gradientRect.size.height, 8,  bytesPerRow, 
										CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaPremultipliedFirst);
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0. alpha:1.] endingColor:[NSColor colorWithDeviceWhite:0. alpha:0]];
		nsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES];
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:nsContext];
		[gradient drawInRect:NSMakeRect(0, 0, gradientRect.size.width, gradientRect.size.height) angle:0];
		[NSGraphicsContext restoreGraphicsState];
		CGImageRef gradientImage = CGBitmapContextCreateImage(context);
		_leftGradientLayer.contents = (id)gradientImage;
		CGContextRelease(context);
		CGImageRelease(gradientImage);
		free(bitmapData);
		
		// right
		bitmapData = malloc(bytesPerRow * gradientRect.size.height);
		context = CGBitmapContextCreate(bitmapData, gradientRect.size.width,
										gradientRect.size.height, 8,  bytesPerRow, 
										CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaPremultipliedFirst);
		nsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES];
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:nsContext];
		[gradient drawInRect:NSMakeRect(0, 0, gradientRect.size.width, gradientRect.size.height) angle:180];
		[NSGraphicsContext restoreGraphicsState];
		gradientImage = CGBitmapContextCreateImage(context);
		_rightGradientLayer.contents = (id)gradientImage;
		CGContextRelease(context);
		CGImageRelease(gradientImage);
		free(bitmapData);
		
		// the autoresizing mask allows it to change shape with the parent layer
		maskLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
		maskLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
		
		[self _updateMaskConstraint];
		
		if(drawBorderForDebug) {
			maskLayer.borderWidth = 1;
			maskLayer.borderColor = CGColorCreateGenericRGB(255, 255, 0, 1.0);
			_rightGradientLayer.borderWidth = 1;
			_rightGradientLayer.borderColor = CGColorCreateGenericRGB(0, 255, 255, 1.0);
			_leftGradientLayer.borderWidth = 1;
			_leftGradientLayer.borderColor = CGColorCreateGenericRGB(255, 0, 255, 1.0);
		}
		
		[maskLayer addSublayer:_rightGradientLayer];
		[maskLayer addSublayer:_leftGradientLayer];
		// we make it a sublayer rather than a mask so that the overlapping alpha will work correctly
		// without the use of a compositing filter
		[_containerLayer addSublayer:maskLayer];
	}
	return self;
}

- (void)dealloc
{	
	[_bindingInfo release];
	[_scroller release];
	[_scrollLayer release];
	[_containerLayer release];
	self.accessoryController = nil;
	self.content = nil;
	self.imageKeyPath = nil;
	self.placeholderIcon = nil;
	CGImageRelease(_placeholderRef);
	CGImageRelease(_shadowImage);
	[_imageLoadQueue release];
	_imageLoadQueue = nil;
	[super dealloc];
}

- (void)awakeFromNib
{
	[self setWantsLayer:YES];
	[self _recachePlaceholder];
	
	// Why do i need this?
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	NSRect frame = self.frame;
	self.frame = NSMakeRect(0, 0, 100, 100);
	self.frame = frame;
	[CATransaction commit];
}

#pragma mark -
#pragma mark Superclass Overrides

#pragma mark NSResponder

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{	
	switch ([theEvent keyCode]) {
		case MBLeftArrowKeyCode:
			[self _setSelectionIndex:(self.selectionIndex - 1)];
			break;
		case MBRightArrowKeyCode:
			[self _setSelectionIndex:(self.selectionIndex + 1)];
			break;
		case MBReturnKeyCode:
			if (self.action) {
				[NSApp sendAction:self.action to:self.target from:self];
				break;
			}
		default:
			[super keyDown:theEvent];
			break;
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if ([theEvent clickCount] == 2 && self.action) {
		[NSApp sendAction:self.action to:self.target from:self];
	}
	
	NSPoint mouseLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSInteger clickedIndex = [self indexOfItemAtPoint:mouseLocation];
	if (clickedIndex != NSNotFound) {
		[self _setSelectionIndex:clickedIndex];
	}
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	CGFloat deltaY = [theEvent deltaY];
	CGFloat deltaX = [theEvent deltaX];
	CGFloat absDeltaY = fabs(deltaY);
	CGFloat absDeltaX = fabs(deltaX);
	
	CGFloat targetDelta, targetAbsDelta;
	if(absDeltaY > absDeltaX) {
		targetDelta = deltaY;
		targetAbsDelta = absDeltaY;
	} else {
		targetDelta = deltaX;
		targetAbsDelta = absDeltaX;
	}
	
	if (targetAbsDelta > MBCoverFlowScrollMinimumDeltaThreshold) {
		if (targetDelta > 0) {
			[self _setSelectionIndex:(self.selectionIndex - 1)];
		} else {
			[self _setSelectionIndex:(self.selectionIndex + 1)];
		}
	}
}

#pragma mark NSView

- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
	[self recalcSubviewSize];
}

- (void)setFrame:(NSRect)newFrame
{
	[super setFrame:newFrame];
	[self _updateMaskConstraint];
//	[self recalcSubviewSize];
	self.selectionIndex = self.selectionIndex;
}
// change by masakih
- (void)recalcSubviewSize
{
	float accessoryY = MBCoverFlowScrollerVerticalSpacing;
		
	// Reposition the scroller
	if (self.showsScrollbar) {
		NSRect scrollerFrame = [_scroller frame];
		scrollerFrame.size.width = [self frame].size.width - 2*MBCoverFlowScrollerHorizontalMargin;
		scrollerFrame.origin.x = ([self frame].size.width - scrollerFrame.size.width)/2;
		scrollerFrame.origin.y = MBCoverFlowViewBottomMargin;
		[_scroller setFrame:scrollerFrame];
		accessoryY += NSMaxY([_scroller frame]);
	}
	
	if (self.accessoryController.view) {
		NSRect accessoryFrame = [self.accessoryController.view frame];
		accessoryFrame.origin.x = floor(([self frame].size.width - accessoryFrame.size.width)/2);
		accessoryFrame.origin.y = accessoryY;
		[self.accessoryController.view setFrame:accessoryFrame];
	}
	
	// add by masakih
	if (self.dragControl) {
		NSRect dragControlFrame;
		dragControlFrame.origin.x = 0;
		dragControlFrame.origin.y = 0;
		dragControlFrame.size.width = [self frame].size.width;
		dragControlFrame.size.height = MBCoverFlowScrollerVerticalSpacing;
		[self.dragControl setFrame:dragControlFrame];
	}
	
	self.selectionIndex = self.selectionIndex;
}

- (BOOL)mouseDownCanMoveWindow
{
	return NO;
}

#pragma mark -
#pragma mark Subclass Methods

#pragma mark Loading Data

- (void)setContent:(NSArray *)newContents
{	
	if ([newContents isEqualToArray:self.content]) {
		return;
	}
	
	NSArray *oldContent = [self.content retain];

	if (_content) {
		[_content release];
		_content = nil;
	}
	
	if (newContents != nil) {
		_content = [newContents copy];
	}
	
	// Add any new items
	NSMutableArray *itemsToAdd = [self.content mutableCopy];
	[itemsToAdd removeObjectsInArray:oldContent];
	
	for (NSObject *object in itemsToAdd) {
		CALayer *layer = [self _insertLayerInScrollLayer];
		[layer setValue:object forKey:@"representedObject"];
		if (self.imageKeyPath) {
			[object addObserver:self forKeyPath:self.imageKeyPath options:0 context:&MBCoverFlowViewImagePathContext];
		}
		[self _refreshLayer:layer];
	}
	[itemsToAdd release];
	
	// Remove any items which are no longer present
	NSMutableArray *itemsToRemove = [oldContent mutableCopy];
	[itemsToRemove removeObjectsInArray:self.content];
	for (NSObject *object in itemsToRemove) {
		CALayer *layer = [self _layerForObject:object];
		if (self.imageKeyPath) {
			[[layer valueForKey:@"representedObject"] removeObserver:self forKeyPath:self.imageKeyPath];
		}
		[layer removeFromSuperlayer];
	}
	[itemsToRemove release];
	
	[oldContent release];
	
	// Update the layer indices
	for (CALayer *layer in [_scrollLayer sublayers]) {
		[layer setValue:[NSNumber numberWithInteger:[self.content indexOfObject:[layer valueForKey:@"representedObject"]]] forKey:@"index"];
	}
	
	[_scroller setNumberOfIncrements:fmax([self.content count]-1, 0)];
	self.selectionIndex = self.selectionIndex;
}

- (void)setImageKeyPath:(NSString *)keyPath
{	
	if (_imageKeyPath) {
		// Remove any observations for the existing key path
		for (NSObject *object in self.content) {
			[object removeObserver:self forKeyPath:self.imageKeyPath];
		}
		
		[_imageKeyPath release];
		_imageKeyPath = nil;
	}
	
	if (keyPath) {
		_imageKeyPath = [keyPath copy];
	}
	
	// Refresh all the layers with images at the new key path
	for (CALayer *layer in [_scrollLayer sublayers]) {
		if (self.imageKeyPath) {
			[[layer valueForKey:@"representedObject"] addObserver:self forKeyPath:self.imageKeyPath options:0 context:&MBCoverFlowViewImagePathContext];
		}
		[self _refreshLayer:layer];
	}
}

#pragma mark Setting Display Attributes

- (void)setAutoresizesItems:(BOOL)flag
{
	_autoresizesItems = flag;
	[self recalcSubviewSize];
}

- (NSSize)itemSize
{
	if (!self.autoresizesItems) {
		return _itemSize;
	}
	
	float origin = MBCoverFlowViewBottomMargin;
	
	if (self.showsScrollbar) {
		origin += [_scroller frame].size.height + MBCoverFlowScrollerVerticalSpacing;
	}
	
	if (self.accessoryController.view) {
		NSRect accessoryFrame = [self.accessoryController.view frame];
		origin += accessoryFrame.size.height;
	}
	
	NSSize size;
	size.height = fmax(([self frame].size.height - origin) - [self frame].size.height/3, 1.0f);
	size.width = size.height * _itemSize.width / _itemSize.height;
	
	// Make sure it's integral
	size.height = floor(size.height);
	size.width = floor(size.width);
	
	return size;
}

- (void)setItemSize:(NSSize)newSize
{
	if (newSize.width <= 0) {
		newSize.width = MBCoverFlowViewDefaultItemWidth;
	}
	
	if (newSize.height <= 0) {
		newSize.height = MBCoverFlowViewDefaultItemHeight;
	}
	
	_itemSize = newSize;
	
	// Update all the various constraints which depend on the item size
	[self _updateMaskConstraint];
	
	// Update the view
	[self _recachePlaceholder];
	[self.layer setNeedsLayout];
	
	CALayer *layer = [[_scrollLayer sublayers] objectAtIndex:self.selectionIndex];
	CGRect layerFrame = [layer frame];
	
	// Scroll so the selected item is centered
	[_scrollLayer scrollToPoint:CGPointMake([self _positionOfSelectedItem], layerFrame.origin.y)];
	
}

- (void)setShowsScrollbar:(BOOL)flag
{
	_showsScrollbar = flag;
	[_scroller setHidden:!flag];
	[self recalcSubviewSize];
}

- (void)setAccessoryController:(NSViewController *)aController
{
	if (aController == self.accessoryController)
		return;
	
	if (self.accessoryController != nil) {
		[self.accessoryController.view removeFromSuperview];
		[self.accessoryController unbind:@"representedObject"];
		[_accessoryController release];
		_accessoryController = nil;
		[self setNextResponder:nil];
	}
	
	_accessoryController = [aController retain];
	if (aController != nil) {
		[self.accessoryController.view setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
		[self addSubview:self.accessoryController.view];
		[self.accessoryController setNextResponder:[self nextResponder]];
		[self setNextResponder:self.accessoryController];
		[self.accessoryController bind:@"representedObject" toObject:self withKeyPath:@"selectedObject" options:nil];
	}
	
	[self recalcSubviewSize];
}

// add by masakih
- (void)setDragControl:(NSView *)aControl
{
	if (aControl == self.dragControl)
		return;
	
	if (self.dragControl != nil) {
		[self.dragControl removeFromSuperview];
		[_dragControl release];
		_dragControl = nil;
	}
	
	_dragControl = [aControl retain];
	if (aControl != nil) {
		[self addSubview:self.dragControl];
	}
	
//	[self resizeSubviewsWithOldSize:[self frame].size];
	[self recalcSubviewSize];
}

#pragma mark Managing the Selection

- (void)setSelectionIndex:(NSInteger)newIndex
{
	if (newIndex >= [[_scrollLayer sublayers] count] || newIndex < 0) {
		return;
	}
	
	if ([[NSApp currentEvent] modifierFlags] & (NSAlphaShiftKeyMask|NSShiftKeyMask))
		[CATransaction setValue:[NSNumber numberWithFloat:2.1f] forKey:@"animationDuration"];
	else
		[CATransaction setValue:[NSNumber numberWithFloat:0.7f] forKey:@"animationDuration"];
	
	_selectionIndex = newIndex;
	[_scrollLayer layoutIfNeeded];
	
	CALayer *layer = [[_scrollLayer sublayers] objectAtIndex:self.selectionIndex];
	CGRect layerFrame = [layer frame];
	
	// Scroll so the selected item is centered
	[_scrollLayer scrollToPoint:CGPointMake([self _positionOfSelectedItem], layerFrame.origin.y)];
	[_scroller setIntegerValue:self.selectionIndex];
	[_scrollLayer layoutSublayers];
}

- (id)selectedObject
{
	if ([self.content count] == 0 || self.selectionIndex >= [self.content count]) {
		return nil;
	}
	
	return [self.content objectAtIndex:self.selectionIndex];
}

- (void)setSelectedObject:(id)anObject
{
	if (![self.content containsObject:anObject]) {
		NSLog(@"[MBCoverFlowView setSelectedObject:] -- The view does not contain the specified object.");
		return;
	}
	
	[self _setSelectionIndex:[self.content indexOfObject:anObject]];
}

#pragma mark Layout Support

- (NSInteger)indexOfItemAtPoint:(NSPoint)aPoint
{
	CGPoint scrollerPoint = [_scrollLayer.superlayer convertPoint:NSPointToCGPoint(aPoint) fromLayer:self.layer];
	CALayer *hit = [_scrollLayer hitTest:scrollerPoint];
	if(hit) {
		NSString *name = hit.name;
		CALayer *itemLayer = nil;
		if([name isEqualToString:@"image"]) {
			itemLayer = hit.superlayer;
		}
		if(itemLayer) {
			id object = [itemLayer valueForKey:@"representedObject"];
			return [self.content indexOfObject:object];
		}
	}
	
	return NSNotFound;
}

// FIXME: The frame returned is not quite wide enough. Don't know why -- probably due to the transforms
- (NSRect)rectForItemAtIndex:(NSInteger)index
{
	if (index < 0 || index >= [self.content count]) {
		return NSZeroRect;
	}
	
	CALayer *layer = [self _layerForObject:[self.content objectAtIndex:index]];
	CALayer *imageLayer = _imageLayerForItemLayer(layer);
	
	CGRect frame = [imageLayer convertRect:[imageLayer frame] toLayer:self.layer];
	return NSRectFromCGRect(frame);
}

#pragma mark -
#pragma mark Private Methods
// add by masakih
static inline CGFloat _MBCoverFlowViewContainerMinY(MBCoverFlowView *aView)
{
	// hummm. what is this?
	CGFloat result = -[aView itemSize].height * MBCoverFlowAnchorPointY + MBCoverFlowViewBottomMargin;
	if(aView.accessoryController) {
		result += [aView.accessoryController.view frame].size.height;
	}
	if(aView.showsScrollbar) {
		result += [aView->_scroller frame].size.height;
		result += MBCoverFlowScrollerVerticalSpacing;
	}
	return result;
}
static inline CALayer *_imageLayerForItemLayer(CALayer *itemLayer)
{
	return [[itemLayer sublayers] objectAtIndex:0];
}
static inline CALayer *_reflectionLayerForItemLayer(CALayer *itemLayer)
{
	return [[itemLayer sublayers] objectAtIndex:1];
}
static BOOL _setContentImageAdjustedSizeToItemLayer(NSImage *image, NSSize size, CALayer *layer)
{
	NSUInteger canvasWidth, canvasHeight;
	CGFloat imageWidth, imageHeight;
	CGFloat imageAspect, canvasAspect;
	CGFloat targetLeft;
	
	if(!image || !layer) return NO;
	
	imageWidth = [image size].width;
	imageHeight = [image size].height;
	if(imageWidth <= 0 || imageHeight <= 0 || size.width <= 0 || size.height <= 0) return NO;
	
	CGFloat maxHeight = size.height * 3;
	if(imageWidth > maxHeight) {
		imageWidth *= maxHeight / imageHeight;
		imageHeight = maxHeight;
	}
	
	imageAspect = imageWidth / imageHeight;
	canvasAspect = size.width / size.height;
	if(imageAspect > canvasAspect) {
		canvasWidth = imageWidth;
		canvasHeight = imageWidth / canvasAspect;
		targetLeft = 0;
	} else {
		canvasHeight = imageHeight;
		canvasWidth = canvasHeight * canvasAspect;
		targetLeft = (canvasWidth - imageWidth) / 2.0;
	}
	
	size_t bytesPerRow = 4*canvasWidth;
	void* bitmapData = malloc(bytesPerRow * canvasHeight);
	if(!bitmapData) return NO;
	CGContextRef context = CGBitmapContextCreate(bitmapData, 
												 canvasWidth,  
												 canvasHeight, 
												 8,
												 bytesPerRow, 
												 [[NSColorSpace genericRGBColorSpace] CGColorSpace], 
												 kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
	if(!context) return NO;
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];
	
	// create CGImageRef
	[[NSColor clearColor] set];
	NSRectFill(NSMakeRect(0, 0, canvasWidth, canvasHeight));
	[image drawInRect:NSMakeRect(targetLeft,0, imageWidth, imageHeight) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	CGImageRef cgImage = CGBitmapContextCreateImage(context);
	[NSGraphicsContext restoreGraphicsState];
	
	CALayer *imageLayer = _imageLayerForItemLayer(layer);
	imageLayer.contents = (id)cgImage;
	
	CALayer *reflectionLayer = _reflectionLayerForItemLayer(layer);
	reflectionLayer.contents = (id)cgImage;
	
	CGImageRelease(cgImage);
	CGContextRelease(context);
	free(bitmapData);
	
	return YES;
}
static inline void _removeActionFromLayer(NSString *action, CALayer *layer)
{
	NSMutableDictionary *actions = [NSMutableDictionary dictionaryWithDictionary:[layer actions]];
	[actions setObject:[NSNull null] forKey:action];
	layer.actions = actions;
}
	
- (void)_updateMaskConstraint
{
	_leftGradientLayer.constraints = nil;
	[_leftGradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX]];
	[_leftGradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
	[_leftGradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY]];
	[_leftGradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX scale:.5 offset:-[self itemSize].width / 2]];
	_rightGradientLayer.constraints = nil;
	[_rightGradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX]];
	[_rightGradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
	[_rightGradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY]];
	[_rightGradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMaxX scale:.5 offset:[self itemSize].width / 2]];
	
	[_containerLayer layoutSublayers];
}
- (CALayer *)_insertLayerInScrollLayer
{
	/* this enables a perspective transform.  The value of zDistance
	 affects the sharpness of the transform */
	float zDistance = 420;
	CATransform3D sublayerTransform = CATransform3DIdentity; 
	sublayerTransform.m34 = 1. / -zDistance;
	
	CALayer *layer = [MBNeverHitLayer layer];
	CGRect frame;
	frame.origin = CGPointZero;
	frame.size = NSSizeToCGSize([self itemSize]);
	frame.size.height *= 2.0;
	[layer setBounds:frame];
	[layer setValue:[NSNumber numberWithInteger:[[_scrollLayer sublayers] count]] forKey:@"index"];
	[layer setSublayerTransform:sublayerTransform];
	[layer setValue:[NSNumber numberWithBool:NO] forKey:@"hasImage"];
	layer.layoutManager = [CAConstraintLayoutManager layoutManager];
	
	CALayer *imageLayer = [CALayer layer];
	[imageLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMidY]];
	[imageLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY]];
	[imageLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX]];
	[imageLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX]];
	imageLayer.contents = (id)_placeholderRef;
	imageLayer.name = @"image";
	[layer addSublayer:imageLayer];
	
	CALayer *reflectionLayer = [CALayer layer];
	[reflectionLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"image" attribute:kCAConstraintMinY]];
	[reflectionLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
	[reflectionLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX]];
	[reflectionLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX]];
	reflectionLayer.name = @"reflection";
	reflectionLayer.transform = CATransform3DMakeScale(1, -1, 1);
	reflectionLayer.contents = (id)_placeholderRef;
	reflectionLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
	[layer addSublayer:reflectionLayer];
	
	CALayer *gradientLayer = [CALayer layer];
	[gradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
	[gradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY]];
	[gradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX]];
	[gradientLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX]];
	[gradientLayer setContents:(id)_shadowImage];
	[reflectionLayer addSublayer:gradientLayer];
	
	[_scrollLayer addSublayer:layer];
	
	if(drawBorderForDebug) {
		imageLayer.borderWidth = 1;
		imageLayer.borderColor = CGColorCreateGenericRGB(0, 255, 0, 1);
		layer.borderWidth = 1;
		layer.borderColor = CGColorCreateGenericRGB(255, 0, 0, 1);
		reflectionLayer.borderWidth = 1;
		reflectionLayer.borderColor = CGColorCreateGenericRGB(0, 0, 255, 1);
		gradientLayer.borderWidth = 1.5;
		gradientLayer.borderColor = CGColorCreateGenericRGB(255, 0, 255, 1);
	}
	
	return layer;
}

- (float)_positionOfSelectedItem
{
	// this is the same math used in layoutSublayersOfLayer:, before tweaking
	return floor(MBCoverFlowViewHorizontalMargin + .5*([_scrollLayer bounds].size.width - [self itemSize].width * [[_scrollLayer sublayers] count] - MBCoverFlowViewCellSpacing * ([[_scrollLayer sublayers] count] - 1))) + self.selectionIndex * ([self itemSize].width + MBCoverFlowViewCellSpacing) - .5 * [_scrollLayer bounds].size.width + .5 * [self itemSize].width;
}

- (void)_scrollerChange:(MBCoverFlowScroller *)sender
{
	NSScrollerPart clickedPart = [sender hitPart];
	if (clickedPart == NSScrollerIncrementLine) {
		[self _setSelectionIndex:(self.selectionIndex + 1)];
	} else if (clickedPart == NSScrollerDecrementLine) {
		[self _setSelectionIndex:(self.selectionIndex - 1)];
	} else if (clickedPart == NSScrollerKnob) {
		[self _setSelectionIndex:[sender integerValue]];
	}
}

- (void)_refreshLayer:(CALayer *)layer
{
	NSObject *object = [layer valueForKey:@"representedObject"];
	NSInteger index = [self.content indexOfObject:object];
	
	[layer setValue:[NSNumber numberWithInteger:index] forKey:@"index"];
	[layer setValue:[NSNumber numberWithBool:NO] forKey:@"hasImage"];
	
	// Create the operation
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(_loadImageForLayer:) object:layer];
	[_imageLoadQueue addOperation:operation];
	[operation release];
}

- (void)_loadImageForLayer:(CALayer *)layer
{
	@try {
		NSImage *image;
		NSObject *object = [layer valueForKey:@"representedObject"];
		
		if (self.imageKeyPath != nil) {
			image = [object valueForKeyPath:self.imageKeyPath];
		} else if ([object isKindOfClass:[NSImage class]]) {
			image = (NSImage *)object;
		}
		
		if ([image isKindOfClass:[NSData class]]) {
			image = [[[NSImage alloc] initWithData:(NSData *)image] autorelease];
		}
		
		if(_setContentImageAdjustedSizeToItemLayer(image, [self itemSize], layer)) {
			[layer setValue:[NSNumber numberWithBool:YES] forKey:@"hasImage"];
		} else {
			CALayer *imageLayer = _imageLayerForItemLayer(layer);
			CALayer *reflectionLayer = _reflectionLayerForItemLayer(layer);
			imageLayer.contents = (id)_placeholderRef;
			reflectionLayer.contents = (id)_placeholderRef;
			[layer setValue:[NSNumber numberWithBool:NO] forKey:@"hasImage"];
		}
	} @catch (NSException *e) {
		// If the key path isn't valid, do nothing
	}
}

- (CALayer *)_layerForObject:(id)object
{
	for (CALayer *layer in [_scrollLayer sublayers]) {
		if ([object isEqual:[layer valueForKey:@"representedObject"]]) {
			return layer;
		}
	}
	return nil;
}

- (void)_recachePlaceholder
{	
	CGImageRelease(_placeholderRef);
	
	NSSize itemSize = self.itemSize;
	NSSize placeholderSize;
	placeholderSize.height = MBCoverFlowViewPlaceholderHeight;
	placeholderSize.width = itemSize.width * placeholderSize.height/itemSize.height;
	
	NSImage *placeholder = [[NSImage alloc] initWithSize:placeholderSize];
	[placeholder lockFocus];
	NSColor *topColor = [NSColor colorWithCalibratedWhite:0.15 alpha:1.0];
	NSColor *bottomColor = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:topColor endingColor:bottomColor];
	[gradient drawInRect:NSMakeRect(0, 0, placeholderSize.width, placeholderSize.height) relativeCenterPosition:NSMakePoint(0, 1)];
	[gradient release];
	
	// Draw the top bevel line
	NSColor *bevelColor = [NSColor colorWithCalibratedWhite:0.3 alpha:1.0];
	[bevelColor set];
	NSRectFill(NSMakeRect(0, placeholderSize.height-5.0, placeholderSize.width, 5.0));
	
	NSColor *bottomBevelColor = [NSColor colorWithCalibratedWhite:0.1 alpha:1.0];
	[bottomBevelColor set];
	NSRectFill(NSMakeRect(0, 0, placeholderSize.width, 5.0));
	
	// Draw the placeholder icon
	if (self.placeholderIcon) {
		NSRect iconRect;
		iconRect.size.height = placeholderSize.height/2;
		iconRect.size.width = iconRect.size.height * [self placeholderIcon].size.width/[self placeholderIcon].size.height;
		
		if (iconRect.size.width > placeholderSize.width * 0.666) {
			iconRect.size.width = placeholderSize.width/2;
			iconRect.size.height = iconRect.size.width * [self placeholderIcon].size.height/[self placeholderIcon].size.width;
		}
		
		iconRect.origin.x = (placeholderSize.width - iconRect.size.width)/2;
		iconRect.origin.y = (placeholderSize.height - iconRect.size.height)/2;
		
		NSImage *icon = [[NSImage alloc] initWithSize:iconRect.size];
		[icon lockFocus];
		NSColor *iconTopColor = [NSColor colorWithCalibratedRed:0.380 green:0.400 blue:0.427 alpha:1.0];
		NSColor *iconBottomColor = [NSColor colorWithCalibratedRed:0.224 green:0.255 blue:0.302 alpha:1.0];
		NSGradient *iconGradient = [[NSGradient alloc] initWithStartingColor:iconTopColor endingColor:iconBottomColor];
		[iconGradient drawInRect:NSMakeRect(0, 0, iconRect.size.width, iconRect.size.width) angle:-90.0];
		[iconGradient release];
		[self.placeholderIcon drawInRect:NSMakeRect(0, 0, iconRect.size.width, iconRect.size.height) fromRect:NSZeroRect operation:NSCompositeDestinationIn fraction:1.0];
		[icon unlockFocus];
		
		[icon drawInRect:iconRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		[icon release];		
	}
	
	[placeholder unlockFocus];
	
	_placeholderRef = [placeholder imageRefCopy];
	
	// Update the placeholder for all necessary items
	for (CALayer *layer in [_scrollLayer sublayers]) {
		if (![[layer valueForKey:@"hasImage"] boolValue]) {
			CALayer *imageLayer = _imageLayerForItemLayer(layer);
			CALayer *reflectionLayer = _reflectionLayerForItemLayer(layer);
			imageLayer.contents = (id)_placeholderRef;
			reflectionLayer.contents = (id)_placeholderRef;
		}
	}
	
	[placeholder release];
}

- (void)_setSelectionIndex:(NSInteger)index
{
	if (index < 0) {
		index = 0;
	} else if (index >= [self.content count]) {
		index = [self.content count] - 1;
	}
	
	if ([self infoForBinding:@"selectionIndex"]) {
		id container = [[self infoForBinding:@"selectionIndex"] objectForKey:NSObservedObjectKey];
		NSString *keyPath = [[self infoForBinding:@"selectionIndex"] objectForKey:NSObservedKeyPathKey];
		[container setValue:[NSNumber numberWithInteger:index] forKey:keyPath];
		return;
	}
	
	self.selectionIndex = index;
}

#pragma mark -
#pragma mark Protocol Methods

#pragma mark CALayoutManager

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	NSArray *sublayers = [layer sublayers];
	NSSize currentItemSize = [self itemSize];
	float margin = floor(MBCoverFlowViewHorizontalMargin + 
						 ([layer bounds].size.width - 
						  currentItemSize.width * [sublayers count] - 
						  MBCoverFlowViewCellSpacing * ([sublayers count]-1)
						  ) * 0.5
						 );
	
	for (CALayer *sublayer in sublayers) {
		CALayer *imageLayer = _imageLayerForItemLayer(sublayer);
		CALayer *reflectionLayer = _reflectionLayerForItemLayer(sublayer);
		
		NSUInteger index = [[sublayer valueForKey:@"index"] integerValue];
		CGRect frame;
		frame.size = NSSizeToCGSize(currentItemSize);
		frame.origin.x = margin + index * (currentItemSize.width + MBCoverFlowViewCellSpacing);
		frame.origin.y =  _MBCoverFlowViewContainerMinY(self);
		frame.size.height = currentItemSize.height * 2;
		
		// Create the perspective effect
		if (index < self.selectionIndex) {
			// Left
			sublayer.anchorPoint = CGPointMake(0, MBCoverFlowAnchorPointY);
			sublayer.zPosition = MBCoverFlowViewPerspectiveSidePosition - 0.1 * (self.selectionIndex - index);
			frame.origin.x += currentItemSize.width * MBCoverFlowViewPerspectiveSideSpacingFactor * (float)(self.selectionIndex - index - MBCoverFlowViewPerspectiveRowScaleFactor);
			imageLayer.transform = _leftTransform;
			imageLayer.zPosition = MBCoverFlowViewPerspectiveSidePosition;
			reflectionLayer.transform = CATransform3DConcat(_leftTransform, CATransform3DMakeScale(1, -1, 1));
			reflectionLayer.zPosition = MBCoverFlowViewPerspectiveSidePosition;
		} else if (index > self.selectionIndex) {
			// Right
			sublayer.anchorPoint = CGPointMake(1, MBCoverFlowAnchorPointY);
			sublayer.zPosition = MBCoverFlowViewPerspectiveSidePosition - 0.1 * (index - self.selectionIndex);
			frame.origin.x -= currentItemSize.width * MBCoverFlowViewPerspectiveSideSpacingFactor * (float)(index - self.selectionIndex - MBCoverFlowViewPerspectiveRowScaleFactor);
			imageLayer.transform = _rightTransform;
			imageLayer.zPosition = MBCoverFlowViewPerspectiveSidePosition;
			reflectionLayer.transform = CATransform3DConcat(_rightTransform, CATransform3DMakeScale(1, -1, 1));
			reflectionLayer.zPosition = MBCoverFlowViewPerspectiveSidePosition;
		} else {
			// Center
			sublayer.anchorPoint = CGPointMake(0.5, MBCoverFlowAnchorPointY);
			sublayer.zPosition = MBCoverFlowViewPerspectiveSidePosition;
			imageLayer.transform = CATransform3DIdentity;
			imageLayer.zPosition = MBCoverFlowViewPerspectiveCenterPosition;
			reflectionLayer.transform = CATransform3DMakeScale(1, -1, 1);
			reflectionLayer.zPosition = MBCoverFlowViewPerspectiveCenterPosition;
		}
		
		[sublayer setFrame:frame];
		[sublayer layoutSublayers];
		[reflectionLayer layoutSublayers];
	}
}

#pragma mark NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingSelectedObject
{
	return [NSSet setWithObjects:@"selectionIndex", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == &MBCoverFlowViewImagePathContext) {
		[self _refreshLayer:[self _layerForObject:object]];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
