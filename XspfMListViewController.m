//
//  XspfMListViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/07.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMListViewController.h"

#import "XspfManager.h"

#import "XspfMTableView.h"

#import "XspfMXspfObject.h"


@implementation XspfMListViewController

- (id)init
{
	[super initWithNibName:@"ListView" bundle:nil];
	
	return self;
}
- (void)awakeFromNib
{
	[tableView setDoubleAction:@selector(openXspf:)];
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (NSMenu *)contextMenuForObject:(XspfMXspfObject *)object
{
	NSMenu *objMenu = [[NSApp delegate] menuForXspfObject:object];
	return objMenu;
}

- (NSMenu *)tableView:(XspfMTableView *)table menuForEvent:(NSEvent *)event
{
	NSPoint mouse = [table convertPoint:[event locationInWindow] fromView:nil];
	NSInteger row = [table rowAtPoint:mouse];
	if(row == NSNotFound || row == -1) return nil;
	
	XspfMXspfObject *object = [[[self representedObject] arrangedObjects] objectAtIndex:row];
	return [self contextMenuForObject:object];
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


// QLPreviewPanel support
- (NSRect)selectionItemRect
{
	NSInteger col = [tableView columnWithIdentifier:@"title"];
	NSInteger row = [tableView selectedRow];
	NSRect rect = [tableView frameOfCellAtColumn:col row:row];
	rect = [tableView convertRectToBase:rect];
	rect.origin = [[tableView window] convertBaseToScreen:rect.origin];
	rect.size.width = rect.size.height;
	return rect;
}
@end
