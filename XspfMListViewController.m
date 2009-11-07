//
//  XspfMListViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/07.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMListViewController.h"


@implementation XspfMListViewController

- (id)init
{
	[super initWithNibName:@"ListView" bundle:nil];
	
	return self;
}

- (void)awakeFromNib
{
	[tableView setDoubleAction:@selector(openXspf:)];
}

@end
