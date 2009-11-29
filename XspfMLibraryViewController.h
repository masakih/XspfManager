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
	IBOutlet NSPredicateEditor *editor;
	IBOutlet NSTextField *nameField;
	
	IBOutlet NSRuleEditor *editor02;
	
	NSPredicate *selectedPredicate;
}
@property (retain) NSPredicate *selectedPredicate;

- (IBAction)newPredicate:(id)sender;
- (IBAction)editPredicate:(id)sender;
- (IBAction)deletePredicate:(id)sender;
- (IBAction)didEndEditPredicate:(id)sender;

@end
