//
//  XspfMDragControl.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/03.
//

/*
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューターも、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害について、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1, Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3, The names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "XspfMDragControl.h"


@interface XspfMDragControl (XspfMPrivate)
- (void)setup;
- (NSRect)draggingRect;
@end

@implementation XspfMDragControl

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self) {
		[self setup];
		[self resetCursorRects];
	}
	
	return self;
}
- (id)initWithCoder:(id)decoder
{
	self = [super initWithCoder:decoder];
	if(self) {
		[self setup];
		[self resetCursorRects];
	}
	
	return self;
}

- (void)setup
{
	NSButtonCell *cell = [[[NSButtonCell alloc] initTextCell:@""] autorelease];
	[cell setBordered:YES];
	[cell setBezelStyle:NSSmallSquareBezelStyle];
	[cell setControlSize:NSSmallControlSize];
	
	[self setCell:cell];
	
	[self setDrawsBackground:YES];
	[self setVertical:YES];
	[self setDragPosition:NSImageAlignRight];
}
- (void)resetCursorRects
{
	NSCursor *cursor = _vertical ? [NSCursor resizeLeftRightCursor] : [NSCursor resizeUpDownCursor];
	[self addCursorRect:[self draggingRect] cursor:cursor];
}
- (NSRect)draggingRect
{
	const CGFloat draggingWidth = 20;
	
	NSRect frame = [self frame];
	
	if(_position == NSImageAlignRight ) {
		frame.origin.x = frame.size.width - draggingWidth;
		frame.origin.y = 0;
		frame.size.width = draggingWidth;
	} else if(_position == NSImageAlignCenter) {
		frame.origin.x = 0;
		frame.origin.y = 0;
	}
	
	return frame;
}
- (void)drawRect:(NSRect)rect
{
	if(drawsBackground)
		[super drawRect:rect];
	
	NSRect drawRect = [self draggingRect];
	
//	[[NSColor redColor] set];
//	NSFrameRect(drawRect);
	
	if(drawsBackground) {
		[[NSColor darkGrayColor] set];
	} else {
		[[NSColor whiteColor] set];
	}
	
	if(_vertical) {
		drawRect.origin = NSMakePoint(drawRect.origin.x + 7, 6);
		drawRect.size.width = 1;
		drawRect.size.height = 10;
		NSRectFill(drawRect);
		drawRect.origin.x += 3;
		NSRectFill(drawRect);
		drawRect.origin.x += 3;
		NSRectFill(drawRect);
	} else {		
		drawRect.origin.x = NSMidX(drawRect) - 20 / 2;
		drawRect.origin.y = 5;//(drawRect.size.height - 7.5) / 2;
		drawRect.size.width = 20;
		drawRect.size.height = 0.5;
		NSRectFill(drawRect);
		drawRect.origin.y += 3;
		NSRectFill(drawRect);
		drawRect.origin.y += 3;
		NSRectFill(drawRect);
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSEvent *event;
	
	NSPoint prevMouse = [theEvent locationInWindow];
	
	NSPoint mouse = [self convertPoint:prevMouse fromView:nil];
	if(!NSPointInRect(mouse, [self draggingRect])) return;
	
	while(YES) {
		event = [NSApp nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask
								   untilDate:[NSDate distantFuture]
									  inMode:NSEventTrackingRunLoopMode
									 dequeue:YES];
		NSPoint newMouse = [event locationInWindow];
		NSSize delta = NSMakeSize(newMouse.x - prevMouse.x, newMouse.y - prevMouse.y);
		[delegate dragControl:self dragDelta:delta];
		
		if([event type] == NSLeftMouseUp) {
			break;
		}
		prevMouse = newMouse;
	}
}

- (void)setDelegate:(id)newDelegate
{
	if(!newDelegate) delegate = nil;
	
	if(![newDelegate respondsToSelector:@selector(dragControl:dragDelta:)]) {
		HMLog(HMLogLevelAlert, @"XspfMDragControl delegate must respond dragControl:dragDelta:.");
		return;
	}
	delegate = newDelegate;
}
- (id)delegate
{
	return delegate;
}

- (void)setDrawsBackground:(BOOL)flag
{
	drawsBackground = flag;
	[self setNeedsDisplay];
}
- (void)setVertical:(BOOL)flag
{
	_vertical = flag;
	[self setNeedsDisplay];
	[self resetCursorRects];
}
- (void)setDragPosition:(NSImageAlignment)position
{
	_position = position;
	[self setNeedsDisplay];
	[self resetCursorRects];
}
@end
