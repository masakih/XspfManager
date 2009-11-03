//
//  XspfMImageView.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/03.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMImageView.h"


@implementation XspfMImageView
- (void)mouseDown:(NSEvent *)theEvent
{
	if([theEvent clickCount] != 2) return [super mouseDown:theEvent];
	
	[NSApp sendAction:[self action] to:[self target] from:self];
}
@end
