//
//  XspfMCollectionView.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/03.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionView.h"


@implementation XspfMCollectionView
- (void)mouseDown:(NSEvent *)theEvent
{
	if([theEvent clickCount] != 2) return [super mouseDown:theEvent];
	
	if(delegate) {
		[delegate enterAction:self];
	}
}
- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent isARepeat]) return;
	
#define kRETURN_KEY	36
#define kENTER_KEY	52
	
	unsigned short code = [theEvent keyCode];
//	NSLog(@"code -> %d", code);
	switch(code) {
		case kRETURN_KEY:
		case kENTER_KEY:
			if(delegate) {
				[delegate enterAction:self];
				return;
			}
			break;
	}
	
	[super keyDown:theEvent];
}

@end
