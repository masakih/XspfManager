//
//  XspfMViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/06.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMViewController.h"


@implementation XspfMViewController

- (void)dealloc
{
	[[self view] removeObserver:self forKeyPath:@"nextResponder"];
	
	[super dealloc];
}

- (void)loadView
{
	[super loadView];
	
	[[self view] addObserver:self
				  forKeyPath:@"nextResponder"
					 options:0
					 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(![keyPath isEqualToString:@"nextResponder"]) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}
	
	id nextResponder = [object nextResponder];
	if([self isEqual:nextResponder]) return;
	
	[self setNextResponder:nextResponder];
	[object setNextResponder:self];
}

@end
