//
//  XspfMLibraryViewController.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMViewController.h"

@interface XspfMLibraryViewController : XspfMViewController
{
	IBOutlet NSTableView *tableView;
	
	IBOutlet NSWindow *predicatePanel;
	IBOutlet NSRuleEditor *editor;
	IBOutlet NSTextField *nameField;
	
	IBOutlet id ruleEditorDelegate;
}

- (IBAction)newPredicate:(id)sender;
- (IBAction)editPredicate:(id)sender;
- (IBAction)deletePredicate:(id)sender;
- (IBAction)didEndEditPredicate:(id)sender;

@end
