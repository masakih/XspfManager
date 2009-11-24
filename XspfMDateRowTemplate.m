//
//  XspfMDateRowTemplate.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/24.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMDateRowTemplate.h"

@implementation XspfMDateRowTemplate
- (NSArray *)templateViews
{
	
	NSArray *views = [super templateViews];
	
	for(id view in views) {
		if([view respondsToSelector:@selector(sizeToFit)]) [view sizeToFit];
	}
	
	return views;
}

@end
