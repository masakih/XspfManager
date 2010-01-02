//
//  XspfMTableView.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/15.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMTableView.h"


@implementation XspfMTableView
- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent isARepeat]) return [super keyDown:theEvent];
	
#define kRETURN_KEY	36
#define kENTER_KEY	52
	
	unsigned short code = [theEvent keyCode];
	//	HMLog(HMLogLevelDebug, @"code -> %d", code);
	switch(code) {
		case kRETURN_KEY:
		case kENTER_KEY:
			if([self doubleAction]) {
				[self sendAction:[self doubleAction] to:[self target]];
				return;
			}
			break;
	}
	
	[super keyDown:theEvent];
}
@end
