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
- (void)fireInMainThread:(id)dummy
{
	[self fire];
}
- (void)operate
{
	[self performSelectorOnMainThread:@selector(fireInMainThread:) withObject:nil waitUntilDone:YES];
	[NSThread sleepForTimeInterval:1];
}
-(void)terminate
{
	[self doesNotRecognizeSelector:_cmd];
}
@end
