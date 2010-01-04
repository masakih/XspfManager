//
//  XspfMListViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/07.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMListViewController.h"

#import "XspfManager.h"

#import "XspfMLabelMenuItem.h"


@implementation XspfMListViewController

- (id)init
{
	[super initWithNibName:@"ListView" bundle:nil];
	
	return self;
}

- (NSMenu *)contextMenu
{
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"title"] autorelease];
	
	NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:@"Label is Menu" action:Nil keyEquivalent:@""] autorelease];
	[menu addItem:item];
	
	item = [[[XspfMLabelMenuItem alloc] initWithTitle:@"Label:" action:Nil keyEquivalent:@""] autorelease];
	[menu addItem:item];
	[(XspfMLabelMenuItem *)item setIntegerValue:4];
	
	item = [[[NSMenuItem alloc] initWithTitle:@"This is MenuMMMMMMMMMMMMMMMMMMMMMM" action:Nil keyEquivalent:@""] autorelease];
	[menu addItem:item];
	
	return menu;
}

- (void)awakeFromNib
{
	[tableView setDoubleAction:@selector(openXspf:)];
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	
	[tableView setMenu:[self contextMenu]];
}


- (void)tableView:(NSTableView *)table sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
//	HMLog(HMLogLevelDebug, @"Enter %@, desc-> %@", NSStringFromSelector(_cmd), [table sortDescriptors]);
	id controller = [self representedObject];
	[controller willChangeValueForKey:@"selectionIndexes"];
	[controller didChangeValueForKey:@"selectionIndexes"];
}


- (NSDragOperation)tableView:(NSTableView*)table
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(NSInteger)row
	   proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	id pb = [info draggingPasteboard];
	id plist = [pb propertyListForType:NSFilenamesPboardType];
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSError *error = nil;
	for(NSString *filePath in plist) {
		NSString *type = [ws typeOfFile:filePath error:&error];
		if(![ws type:type conformsToType:@"com.masakih.xspf"]) {
			return NSDragOperationNone;
		}
	}
	[table setDropRow:row dropOperation:NSTableViewDropAbove];
	
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView*)table
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(NSInteger)row
	dropOperation:(NSTableViewDropOperation)dropOperation
{
	id pb = [info draggingPasteboard];
	id plist = [pb propertyListForType:NSFilenamesPboardType];
	
	[[NSApp delegate] registerFilePaths:plist];
	
	return YES;
}

@end
