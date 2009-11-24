//
//  XspfMLibraryViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMLibraryViewController.h"

@interface XspfMLibraryViewController (HMPrivate)
- (NSArray *)sortDescriptors;
- (void)setupXspfList;
@end

@implementation XspfMLibraryViewController
- (id)init
{
	[super initWithNibName:@"LibraryView" bundle:nil];
	
	[self setupXspfList];
	
	return self;
}

- (void)awakeFromNib
{
	[[self representedObject] setSortDescriptors:[self sortDescriptors]];
}
- (NSArray *)sortDescriptors
{
	id desc = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	return [NSArray arrayWithObject:[desc autorelease]];
}

- (void)setupXspfList
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSInteger num;
	
	fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"XspfList"
								 inManagedObjectContext:moc]];
	num = [moc countForFetchRequest:fetch
							  error:&error];
	if(num != 0) return;
	
	id obj = [NSEntityDescription insertNewObjectForEntityForName:@"XspfList"
										   inManagedObjectContext:moc];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlString <> %@", @""];
	[obj setValue:predicate forKey:@"predicate"];
	[obj setValue:NSLocalizedString(@"Library", @"Library") forKey:@"name"];
	[obj setValue:[NSNumber numberWithInt:0] forKey:@"order"];
	
	obj = [NSEntityDescription insertNewObjectForEntityForName:@"XspfList"
										inManagedObjectContext:moc];
	predicate = [NSPredicate predicateWithFormat:@"favorites = %@", [NSNumber numberWithBool:YES]];
	[obj setValue:predicate forKey:@"predicate"];
	[obj setValue:NSLocalizedString(@"Favorites", @"Favorites") forKey:@"name"];
	[obj setValue:[NSNumber numberWithInt:1] forKey:@"order"];
}

- (IBAction)newPredicate:(id)sender
{
	if([editor numberOfRows] == 0) {
		[editor addRow:self];
	}
	
	[NSApp beginSheet:predicatePanel
	   modalForWindow:[tableView window]
		modalDelegate:self
	   didEndSelector:@selector(didEndEditPredicate:returnCode:contextInfo:)
		  contextInfo:@"Createion"];
}
- (IBAction)didEndEditPredicate:(id)sender
{
	[predicatePanel orderOut:self];
	[NSApp endSheet:predicatePanel returnCode:[sender tag]];
}
- (void)didEndEditPredicate:(id)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSCancelButton) return;
	
	NSPredicate *predicate = [editor predicate];
	NSLog(@"predicate -> %@", predicate);
	
}
- (IBAction)test01:(id)sender
{
	NSArray *array = [editor rowTemplates];
	
//	for(id templ in array) {
//		NSLog(@"Views -> %@", [templ templateViews]);
//		for(id v in [templ templateViews]) {
//			if([v respondsToSelector:@selector(tag)]) {
//				NSLog(@"tag -> %d", [v tag]);
//			}
//		}
//	}
	for(id templ in array) {
		NSLog(@"template -> %@", templ);
	}
}

@end
