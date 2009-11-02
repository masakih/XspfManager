//
//  XspfMMovieLoadRequest.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMMovieLoadRequest.h"

#import <QTKit/QTKit.h>
#import "XspfQTComponent.h"
#import "XspfQTValueTransformers.h"

@interface XspfMMovieLoader : NSObject
{
	QTMovie *result;
}
- (QTMovie *)loadedMovie;
- (void)loadOnMainThread:(id)array;
@end

@implementation XspfMMovieLoader
- (void)loadOnMainThread:(id)url
{
	NSError *error = nil;
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   url, QTMovieURLAttribute,
						   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
						   nil];
	result = [[QTMovie alloc] initWithAttributes:attrs error:&error];
	if (result == nil) {
        if (error != nil) {
            NSLog(@"Couldn't load movie URL, error = %@", error);
        }
    }
}
- (QTMovie *)loadedMovie { return result; }
- (void)dealoc
{
	[result release];
	[super dealloc];
}
@end


@implementation XspfMMovieLoadRequest

@synthesize object;
@synthesize url;

+ (id)requestWithObject:(id)anObject url:(NSURL *)anUrl;
{
	return [[[self alloc] initWithObject:anObject url:anUrl] autorelease];
}
- (id)initWithObject:(id)anObject url:(NSURL *)anUrl
{
	self = [super init];
	self.object = anObject;
	self.url = anUrl;
	
	return self;
}

static QTMovie *loadFromMovieURL(NSURL *url)
{
	id loader = [[[XspfMMovieLoader alloc] init] autorelease];
	
	[loader performSelectorOnMainThread:@selector(loadOnMainThread:)
							 withObject:url
						  waitUntilDone:YES];
	
	return [loader loadedMovie];
}

static XspfQTComponent *componentForURL(NSURL *url)
{
	NSError *theErr = nil;
	
	NSXMLDocument *d = [[[NSXMLDocument alloc] initWithContentsOfURL:url
															 options:0
															   error:&theErr] autorelease];
	if(!d) {
		if(theErr) {
			NSLog(@"%@", theErr);
		}
		return nil;
	}
	NSXMLElement *root = [d rootElement];
	XspfQTComponent *pl = [XspfQTComponent xspfComponemtWithXMLElement:root];
	if(!pl) {
		NSLog(@"Can not create XspfQTComponent.");
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
static NSImage *thumbnailForTrackTime(XspfQTComponent *track, NSTimeInterval time, CGSize size)
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
            NSLog(@"Couldn't create CGImageRef, error = %@", theErr);
        }
        return NULL;
    }
	
	return theImage;
}

static NSImage *thumbnailWithComponent(XspfQTComponent *component)
{
	XspfQTComponent *track = [component thumbnailTrack];
	NSTimeInterval interval = [component thumbnailTimeInterval];
	CGSize size = { 200, 200 };
	
	if(!track) {
		XspfQTComponent *trackList = [component childAtIndex:0];
		[trackList setSelectionIndex:0];
		track = [trackList currentTrack	];
	}
	
	NSImage *thumbnail = thumbnailForTrackTime(track, interval, size);
	
	return thumbnail;
}


- (void)operate
{
	id item = componentForURL(self.url);
	if(!item) return;
	
	[self.object setValue:thumbnailWithComponent(item) forKey:@"thumbnail"];
}
-(void)terminate
{
	[self doesNotRecognizeSelector:_cmd];
}
@end
