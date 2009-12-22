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
	
	NSArray *views = [[self contentView] subviews];
	for(id view in views) {
		if(![view isKindOfClass:[NSControl class]]) continue;
		
		switch([view tag]) {
			case 1000:
				thumbnail = view;
				break;
			case 1001:
				titleField = view;
				break;
			case 1002:
				ratingLabel = view;
				break;
			case 1003:
				rating = view;
				break;
		}
	}
	
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
@end
