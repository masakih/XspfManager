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
	[tableView setSortDescriptors:[self sortDescriptors]];
	[[self representedObject] setSortDescriptors:[self sortDescriptors]];
}
- (NSArray *)sortDescriptors
{
		id desc = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
		return [NSArray arrayWithObject:[desc autorelease]];
}


- (void)setupXspfList
{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
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


- (void)test01:(id)sender
{
	id selection = [[self representedObject] valueForKey:@"selection"];
	NSLog(@"Selection -> %@(%@)", [selection valueForKey:@"name"], [selection valueForKey:@"predicate"]);
}
- (void)test02:(id)sender
{
	[tableView reloadData];
}
- (void)test03:(id)sender
{

}
@end
