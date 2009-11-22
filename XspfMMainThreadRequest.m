//
//  XspfMMainThreadRequest.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/18.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMMainThreadRequest.h"


@implementation XspfMMainThreadRequest
- (void)fire
{
	[self doesNotRecognizeSelector:_cmd];
}
- (NSTimeInterval)sleepTime
{
	return 0.0;
}
- (void)fireInMainThread:(id)dummy
{
	[self fire];
}
- (void)operate
{
	[NSThread sleepForTimeInterval:[self sleepTime]];
	[self performSelectorOnMainThread:@selector(fireInMainThread:) withObject:nil waitUntilDone:YES];
}
-(void)terminate
{
	[self doesNotRecognizeSelector:_cmd];
}
@end
