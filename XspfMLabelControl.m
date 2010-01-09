//
//  XspfMLabelControl.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/06.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMLabelControl.h"

#import "XspfMLabelCell.h"


@implementation XspfMLabelControl

+ (Class)cellClass
{
	return [XspfMLabelCell class];
}

- (void)setup
{
	id cell = [[[XspfMLabelCell alloc] initTextCell:@""] autorelease];
	[cell setLabelStyle:XspfMSquareStyle];
	[self setCell:cell];
}
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(id)decoder
{
	self = [super initWithCoder:decoder];
	if(self) {
		[self setup];
	}
	return self;
}

- (void)setLabelStyle:(NSInteger)style
{
	[[self cell] setLabelStyle:style];
}
- (NSInteger)labelStyle
{
	return [[self cell] labelStyle];
}
- (void)setDrawX:(BOOL)flag
{
	[[self cell] setDrawX:flag];
}
- (BOOL)isDrawX
{
	return [[self cell] isDrawX];
}

@end
