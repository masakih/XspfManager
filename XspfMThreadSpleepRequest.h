//
//  XspfMThreadSpleepRequest.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/20.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMMainThreadRequest.h"

@interface XspfMThreadSpleepRequest : XspfMMainThreadRequest
{
	NSTimeInterval sleepTime;
}
+ (id)requestWithSleepTime:(NSTimeInterval)time;
- (id)initWithSleepTime:(NSTimeInterval)time;

@end
