//
//  XspfMLibraryViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMLibraryViewController.h"


@implementation XspfMLibraryViewController
- (id)init
{
	[super initWithNibName:@"LibraryView" bundle:nil];
	
	return self;
}

- (NSArray *)sortDescriptors
{
	id desc = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	return [NSArray arrayWithObject:[desc autorelease]];
}
@end
