//
//  XspfMListViewController.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/07.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMViewController.h"

@class XspfMLabelMenuItem;

@interface XspfMListViewController : XspfMViewController
{
	IBOutlet NSTableView *tableView;
	
	IBOutlet NSMenu *menu;
	IBOutlet XspfMLabelMenuItem *labelMenuItem;
}

- (IBAction)changeLabel:(id)sender;

@end
