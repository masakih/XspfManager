//
//  HMQueue.m
//  OldMacViewer
//
//  Created by Hori,Masaki on Thu Sep 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "HMQueue.h"

NSString* HMQueueOverflow = @"HMQueueOverFlow";

enum {
    queueIsEmpty,
    queueHasData,
};


@interface HMQueue (HMPrivateMethod)
-(id)nonThreadSafeTake;
@end

@implementation HMQueue

+(id)queueWithCapacity:(NSUInteger)aCapacity
{
    return [[[self alloc] initWithCapacity:aCapacity] autorelease];
}

-(id)initWithCapacity:(NSUInteger)aCapacity
{
    self = [super init];
    
    if( self ) {
        _queue = NSZoneMalloc( [self zone], sizeof(id) * ( aCapacity + 1 ));
	_top = _bottom = 0;
	_capacity = aCapacity;
        _stat = queueIsEmpty;
        _lock = [[NSConditionLock alloc] initWithCondition:_stat];
    }
    
    return self;
}

-(void)dealloc
{
    NSAutoreleasePool*	pool;
    
    [_lock lock];
    
    // 全て取り出すことで,Autorelease させる。
    pool = [[NSAutoreleasePool alloc] init];
    while([self nonThreadSafeTake]) ;
    [pool release];
    
    NSZoneFree( [self zone], _queue );
    
    [_lock release];
    
    [super dealloc];
}

-(NSUInteger)next:(NSUInteger)current
{
    return ( current + 1 ) % ( _capacity + 1 );
}

-(void)put:(id)data
{
    if( [self next:_bottom] == _top ) {
	NSException*	exception;
	exception = [NSException exceptionWithName:HMQueueOverflow reason:@"HMQueue is over flow" userInfo:nil];
	[exception raise];
    }
    
    /*********/
    [_lock lock];
    
    ((id*)_queue)[_bottom] = [data retain];
    _bottom = [self next:_bottom];
    
    if( _stat == queueIsEmpty ) {
        _stat = queueHasData;
    }
    
    [_lock unlockWithCondition:_stat];
}

-(id)take
{
    id result;
    
    [_lock lockWhenCondition:queueHasData];
    
    result = [self nonThreadSafeTake];
    
    [_lock unlockWithCondition:_stat];
    
    return result;
}

@end

@implementation HMQueue (HMPrivateMethod)

-(id)nonThreadSafeTake
{
    id result;
    
    result = (id)((id*)_queue)[_top];
    _top = [self next:_top];
    
    if( _top == _bottom ) {
        _stat = queueIsEmpty;
    }
    
    return [result autorelease];
}

@end
