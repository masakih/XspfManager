//
//  main.m
//  XspfSpotlighterHelper
//
//  Created by Hori,Masaki on 11/06/29.
//  Copyright 2011 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMSpotlighterHelper.h"

int main(int argc, char *argv[])
{
	id pool = [[NSAutoreleasePool alloc] init];
	
	XspfMSpotlighterHelper *server = [[XspfMSpotlighterHelper alloc] init];
	NSConnection *con = [NSConnection serviceConnectionWithName:@"XspfManagerSpotlightIndexer"
													 rootObject:server];
	if(!con) {
		NSLog(@"Can not create NSConnection instance.");
		exit(-1);
	}
	
	NSRunLoop *runloop = [NSRunLoop currentRunLoop];
	NSDate *date = nil;
	while(YES) {
		id pool02 = [[NSAutoreleasePool alloc] init];
		date = [NSDate dateWithTimeIntervalSinceNow:10];
		[runloop runUntilDate:date];
		[pool02 release];
	}
	
	[con release];
	[pool release];
	return 0;
}
