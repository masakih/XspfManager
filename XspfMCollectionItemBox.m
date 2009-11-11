//
//  XspfMCollectionItemBox.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/11.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionItemBox.h"


@implementation XspfMCollectionItemBox
- (void)dealloc
{
	[self unbind:@"fillColor"];
	
	[super dealloc];
}
- (void)setCollectionViewItem:(NSCollectionViewItem *)item
{
	viewItem = item;
	if(!viewItem) {
		[self unbind:@"fillColor"];
		return;
	}
	
	[self bind:@"fillColor"
	  toObject:viewItem
   withKeyPath:@"backgroundColor"
	   options:nil];
}
@end
