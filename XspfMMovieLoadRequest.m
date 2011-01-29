//
//  XspfMMovieLoadRequest.m
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

#import "XspfMMovieLoadRequest.h"

#import <QTKit/QTKit.h>
#import "HMXSPFComponent.h"
#import "XspfQTValueTransformers.h"


@implementation XspfMMovieLoadRequest

@synthesize object;

+ (id)requestWithObject:(XspfMXspfObject *)anObject
{
	return [[[self alloc] initWithObject:anObject] autorelease];
}
- (id)initWithObject:(XspfMXspfObject *)anObject
{
	self = [super init];
	self.object = anObject;
	
	return self;
}
- (void)delloc
{
	self.object = nil;
	
	[super dealloc];
}
- (NSTimeInterval)sleepTime
{
	return 1.0;
}

static QTMovie *loadFromMovieURL(NSURL *url)
{
	NSError *error = nil;
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   url, QTMovieURLAttribute,
						   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
						   nil];
	QTMovie *result = [[QTMovie alloc] initWithAttributes:attrs error:&error];
	if (result == nil) {
		if (error != nil) {
			HMLog(HMLogLevelError, @"Couldn't load movie URL, error = %@", error);
		}
	}
	
	return result;
}

static HMXSPFComponent *componentForURL(NSURL *url)
{
	NSError *theErr = nil;
	
	NSXMLDocument *d = [[[NSXMLDocument alloc] initWithContentsOfURL:url
															 options:0
															   error:&theErr] autorelease];
	if(!d) {
		HMLog(HMLogLevelError, @"Could not load XML.");
		if(theErr) {
			HMLog(HMLogLevelError, @"%@", theErr);
		}
		return nil;
	}
	NSXMLElement *root = [d rootElement];
	HMXSPFComponent *pl = [HMXSPFComponent xspfComponentWithXMLElement:root];
	if(!pl) {
		HMLog(HMLogLevelError, @"Can not create XspfQTComponent.");
		return nil;
	}
	
	return pl;
}

static inline NSSize maxSizeForFrame(NSSize size, CGSize frame)
{
	NSSize result = size;
	CGFloat aspectRetio = size.width / size.height;
	CGFloat frameAspectRetio = frame.width / frame.height;
	
	if(aspectRetio > frameAspectRetio) {
		result.width = frame.width;
		result.height = result.width / aspectRetio;
	} else {
		result.height = frame.height;
		result.width = result.height * aspectRetio;
	}
	
	return result;
}

/** はじめのフレームは真っ黒、あるいは真っ白である場合が多い。そのため以下の秒数のフレームを使用する。
 ** ０、ポスターフレームがあればそれを使用。
 ** １、１５分以上なら秒数で１％のフレームを使用。
 ** ２、１分以上なら１秒目のフレームを使用。
 ** ３、それらよりも短いときは０秒目のフレームを使用。
 **/
static QTTime calcDefaultThumbnailQTTime(QTMovie *movie)
{
	XspfQTTimeTransformer *t = [[[XspfQTTimeTransformer alloc] init] autorelease];
	
	NSValue *pTimeValue = [movie attributeForKey:QTMoviePosterTimeAttribute];
	id pV = [t transformedValue:pTimeValue];
	if([pV longValue] == 0) {
		NSValue *duration = [movie attributeForKey:QTMovieDurationAttribute];
		id v = [t transformedValue:duration];
		
		double newPosterTime = 0;
		double dDur = [v doubleValue];
		if(dDur > 15 * 60) {
			newPosterTime = dDur / 100;
		} else if(dDur > 60) {
			newPosterTime = 1;
		}
		pTimeValue = [t reverseTransformedValue:[NSNumber numberWithDouble:newPosterTime]];
	}
	
	return [pTimeValue QTTimeValue];
}
static NSImage *thumbnailForTrackTime(HMXSPFComponent *track, NSTimeInterval time, CGSize size)
{
	NSError *theErr = nil;
	QTMovie *movie = loadFromMovieURL([track movieLocation]);
	
	NSValue *sizeValue = [movie attributeForKey:QTMovieNaturalSizeAttribute];
	NSSize newMaxSize = maxSizeForFrame([sizeValue sizeValue], size);
	
	QTTime t;
	if(time == DBL_MIN) {
		t = calcDefaultThumbnailQTTime(movie);
	} else {
		t = QTMakeTimeWithTimeInterval(time);
	}
	
	NSDictionary *imgProp = [NSDictionary dictionaryWithObjectsAndKeys:
							 QTMovieFrameImageTypeNSImage,QTMovieFrameImageType,
							 [NSValue valueWithSize:newMaxSize], QTMovieFrameImageSize,
							 nil];
	
	NSImage *theImage = (NSImage *)[movie frameImageAtTime:t
											withAttributes:imgProp
													 error:&theErr];
    if (theImage == nil) {
        if (theErr != nil) {
            HMLog(HMLogLevelError, @"Couldn't create CGImageRef, error = %@", theErr);
        }
        return NULL;
    }
	
	return theImage;
}

static NSImage *thumbnailWithComponent(HMXSPFComponent *component)
{
	HMXSPFComponent *track = [component thumbnailTrack];
	NSTimeInterval interval = [component thumbnailTimeInterval];
	CGSize size = { 200, 200 };
	
	if(!track) {
		HMXSPFComponent *trackList = [component childAtIndex:0];
		[trackList setSelectionIndex:0];
		track = [trackList currentTrack	];
	}
	
	NSImage *thumbnail = thumbnailForTrackTime(track, interval, size);
	
	if(!thumbnail) {
		thumbnail = [NSImage imageNamed:@"Icon-round-Question_mark"];
	}
	
	return thumbnail;
}


- (void)fire
{
	id item = componentForURL(self.object.url);
	if(!item) return;
	if([item childrenCount] == 0) return;
	
	id trackList = [item childAtIndex:0];
	self.object.movieNum = [NSNumber numberWithInt:[trackList childrenCount]];
	self.object.thumbnail = thumbnailWithComponent(item);
}
-(void)terminate
{
	[self doesNotRecognizeSelector:_cmd];
}
@end
