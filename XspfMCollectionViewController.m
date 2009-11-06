//
//  XspfMCollectionViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/05.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionViewController.h"


@implementation XspfMCollectionViewController

- (id)init
{
	[super initWithNibName:@"CollectionView" bundle:nil];
	
	return self;
}
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
					 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
					 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(![keyPath isEqualToString:@"nextResponder"]) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}
	id new = [change objectForKey:NSKeyValueChangeNewKey];
	id old = [change objectForKey:NSKeyValueChangeOldKey];
	if([new isEqual:old]) return;
	
	id nextResponder = [object nextResponder];
	if([self isEqual:nextResponder]) return;
	
	[self setNextResponder:nextResponder];
	[object setNextResponder:self];
}


#pragma mark#### XspfMCollectionView Delegate ####
- (void)enterAction:(XspfMCollectionView *)view
{
	[xspfManager openXspf:view];
}

#pragma mark#### Test ####
- (void)test01:(id)sender
{
	NSLog(@"hoge");
}
	

@end
