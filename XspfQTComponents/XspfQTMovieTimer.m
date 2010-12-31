//
//  XspfQTMovieTimer.m
//  XspfQT
//
//  Created by Hori, Masaki on 09/10/31.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2009, masakih
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
 Copyright (c) 2009, masakih
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

#import "XspfQTMovieTimer.h"

@interface NSObject(XspfQTMovieTimerSupport)
- (void)checkPreload:(id)timer;
- (void) updateTimeIfNeeded:(id)timer;
@end
@implementation XspfQTMovieTimer

- (id)init
{
	self = [super init];
	
	documents = [[NSMutableArray alloc] init];
	movieWindowControllers = [[NSMutableDictionary alloc] init];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(documentWillClose:)
			   name:XspfQTDocumentWillCloseNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(movieDidStart:)
			   name:XspfQTMovieDidStartNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(movieDidPause:)
			   name:XspfQTMovieDidPauseNotification
			 object:nil];
	
	return self;
}

+ (id)movieTimer
{
	return [[[self alloc] init] autorelease];
}
- (void)dealloc
{
	[documents release];
	[movieWindowControllers release];
	[timer invalidate]; timer = nil;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}

- (void)makeTimer
{
	@synchronized(self) {
		if(timer) return;
		timer = [NSTimer scheduledTimerWithTimeInterval:0.5
												 target:self
											   selector:@selector(fire:)
											   userInfo:NULL
												repeats:YES];
		[timer retain];
	}
}
- (void)dropTimer
{
	@synchronized(self) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
}

- (void)enableFireing:(XspfQTDocument *)doc
{
	@synchronized(documents) {
		if([documents containsObject:doc]) return;
		
		[documents addObject:doc];
		if([pausedDocuments containsObject:doc]) {
			[pausedDocuments removeObject:doc];
		}
	}
	
	[self makeTimer];
}
- (void)disableFireing:(XspfQTDocument *)doc
{
	@synchronized(documents) {
		if([pausedDocuments containsObject:doc]) return;
		
		[pausedDocuments addObject:doc];
		if([documents containsObject:doc]) {
			[documents removeObject:doc];
		}
		
		if([documents count] == 0) {
			[self dropTimer];
		}
	}
}
- (void)addDocument:(XspfQTDocument *)doc
{
	@synchronized(documents) {
		if([documents containsObject:doc]) return;
		if([pausedDocuments containsObject:doc]) return;
		
		[documents addObject:doc];
		
		NSArray *wControlers = [doc windowControllers];
		for(id w in wControlers) {
			if([w isKindOfClass:[XspfQTMovieWindowController class]]) {
				[movieWindowControllers setObject:w forKey:[NSValue valueWithPointer:doc]];
			}
		}
	}
	
	[self makeTimer];
}
- (void)removeDocument:(XspfQTDocument *)doc
{
	@synchronized(documents) {
		[movieWindowControllers removeObjectForKey:[NSValue valueWithPointer:doc]];
		
		if([documents containsObject:doc]) {
			[documents removeObject:doc];
		}
		if([pausedDocuments containsObject:doc]) {
			[documents removeObject:doc];
		}
		
		if([documents count] == 0) {
			[self dropTimer];
		}
	}
}

- (void)put:(XspfQTDocument *)doc
{
	[self addDocument:doc];
}

- (void)documentWillClose:(id)notification
{
	id doc = [notification object];
	[self removeDocument:doc];
}

- (void)movieDidStart:(id)notification
{
	id wc = [notification object];
	XspfQTDocument *doc = [wc document];
	[self enableFireing:doc];
}
- (void)movieDidPause:(id)notification
{
	id wc = [notification object];
	XspfQTDocument *doc = [wc document];
	[self disableFireing:doc];
}

- (void)fire:(id)t
{
	XspfQTDocument *doc;
	XspfQTMovieWindowController *wc;
	
	@synchronized(documents) {
		for(doc in documents) {
			wc = [movieWindowControllers objectForKey:[NSValue valueWithPointer:doc]];
			
			[doc checkPreload:t];
			[wc updateTimeIfNeeded:t];
		}
	}
}

@end
