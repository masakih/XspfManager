//
//  XspfMCollectionItemBox.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/11.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCollectionItemBox.h"


@implementation XspfMCollectionItemBox
@synthesize thumbnail;
@synthesize titleField;
@synthesize ratingLabel;
@synthesize rating;

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	
	thumbnail = [self viewWithTag:1000];
	titleField = [self viewWithTag:1001];
	ratingLabel = [self viewWithTag:1002];
	rating = [self viewWithTag:1003];
	
	return self;
}

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

- (NSInteger)tag
{
	return 1100;
}

-(void)setMenu:(NSMenu *)menu
{
	[super setMenu:menu];
	
	[[self contentView] setMenu:menu];
	[thumbnail setMenu:menu];
	[titleField setMenu:menu];
	[ratingLabel setMenu:menu];
	[rating setMenu:menu];
}
@end
