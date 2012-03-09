//
//  XspfMLabelInspector.m
//  XspfMLabel
//
//  Created by Hori,Masaki on 10/06/09.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMLabelInspector.h"

#import <XspfMLabel/XspfMLabelField.h>

@implementation XspfMLabelInspector

- (void)awakeFromNib
{
	[labelField setDrawX:YES];
	[labelField bind:@"value"
			toObject:self
		 withKeyPath:@"inspectedObjectsController.selection.value"
			 options:nil];
}

- (NSString *)viewNibName {
	return @"XspfMLabelInspector";
}

- (void)refresh {
	// Synchronize your inspector's content view with the currently selected objects.
	[super refresh];
}

@end
