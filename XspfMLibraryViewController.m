//
//  XspfMLibraryViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMLibraryViewController.h"

#import "XspfMXspfListObject.h"


@interface XspfMLibraryViewController (HMPrivate)
- (NSArray *)sortDescriptors;
- (void)setupXspfList;
@end

enum {
	kLibraryOrder = 0,
	kFavoritesOrder,
	kSmartLibraryOrder,
};

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

- (void)addSmartLibrary:(NSString *)name predicate:(NSPredicate *)predicate order:(NSInteger)order
{
	id obj = [NSEntityDescription insertNewObjectForEntityForName:@"XspfList"
										   inManagedObjectContext:[self managedObjectContext]];
	[obj setValue:predicate forKey:@"predicate"];
	[obj setValue:name forKey:@"name"];
	[obj setValue:[NSNumber numberWithInt:order] forKey:@"order"];
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
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlString <> %@", @""];
	[self addSmartLibrary:NSLocalizedString(@"Library", @"Library")
				predicate:predicate
					order:kLibraryOrder];
	
	predicate = [NSPredicate predicateWithFormat:@"favorites = %@", [NSNumber numberWithBool:YES]];
	[self addSmartLibrary:NSLocalizedString(@"Favorites", @"Favorites")
				predicate:predicate
					order:kFavoritesOrder];
}

- (XspfMXspfListObject *)targetObject
{
	id array = [[self representedObject] arrangedObjects];
	
	NSInteger row = [tableView clickedRow];
	if(row >= 0 && [array count] > row) {
		return [array objectAtIndex:row];
	}
	return nil;
}
- (BOOL)canUseNewSmartLibraryName:(NSString *)newName
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSPredicate *predicate;
	NSInteger num;
	
	fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"XspfList"
								 inManagedObjectContext:moc]];
	predicate = [NSPredicate predicateWithFormat:@"name = %@", newName];
	[fetch setPredicate:predicate];
	num = [moc countForFetchRequest:fetch
							  error:&error];
	
	return num == 0;
}
- (NSString *)newSmartLibraryName
{
	NSString *template = NSLocalizedString(@"Untitled Library", @"Untitled Library");
	
	if([self canUseNewSmartLibraryName:template]) return template;
	
	NSInteger i = 1;
	do {
		NSString *name = [NSString stringWithFormat:@"%@ %d", template, i];
		if([self canUseNewSmartLibraryName:name]) return name;
	} while (i++ < INT_MAX);
	
	return @"hoge";
}
- (IBAction)newPredicate:(id)sender
{
	if([editor numberOfRows] == 0) {
		[editor addRow:self];
	}
		
	[nameField setStringValue:[self newSmartLibraryName]];
	[nameField selectText:self];
	
	[NSApp beginSheet:predicatePanel
	   modalForWindow:[tableView window]
		modalDelegate:self
	   didEndSelector:@selector(didEndEditPredicate:returnCode:contextInfo:)
		  contextInfo:@"Createion"];
}
- (IBAction)editPredicate:(id)sender
{
	XspfMXspfListObject *obj = [self targetObject];
	[nameField setStringValue:obj.name];
	[nameField selectText:self];
	
	[ruleEditorDelegate setPredicate:obj.predicate];
	
	[NSApp beginSheet:predicatePanel
	   modalForWindow:[tableView window]
		modalDelegate:self
	   didEndSelector:@selector(didEndEditPredicate:returnCode:contextInfo:)
		  contextInfo:obj];
}
- (IBAction)deletePredicate:(id)sender
{
	XspfMXspfListObject *obj = [self targetObject];
	NSBeginInformationalAlertSheet(nil, nil, @"Cancel", nil, [[self view] window],
								   self, @selector(didEndAskDelete:::), Nil, obj,
								   NSLocalizedString(@"Do you really delete smart library \"%@\"?", @"Do you really delete smart library \"%@\"?"),
								   obj.name);
}
- (IBAction)didEndEditPredicate:(id)sender
{
	[predicatePanel orderOut:self];
	[NSApp endSheet:predicatePanel returnCode:[sender tag]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	if(action == @selector(editPredicate:)
	   || action == @selector(deletePredicate:)) {
		XspfMXspfListObject *obj = [self targetObject];
		if(!obj) return NO;
		if(obj.order == kLibraryOrder || obj.order == kFavoritesOrder) return NO;
	}
	
	return YES;
}
		
- (void)didEndEditPredicate:(id)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSCancelButton) return;
	
	[editor reloadPredicate];
	NSPredicate *predicate = [editor predicate];
	
	if(!predicate || ![predicate isKindOfClass:[NSPredicate class]]) {
		HMLog(HMLogLevelError, @"Could not create NSPredicate.");
		NSBeep();
		return;
	}
	if(![predicate isKindOfClass:[NSCompoundPredicate class]]) {
		predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObject:predicate]];
	}
		
	NSString *name = [nameField stringValue];
	if([name length] == 0) {
		NSBeep();
		NSBeginAlertSheet(nil, nil, nil, nil, [[self view] window],
						  self, @selector(retryEditPredicate:::), Nil, contextInfo,
						  NSLocalizedString(@"Name must not be empty.", @"Name must not be empty."));
		return;
	}
	
	if([(id)contextInfo isKindOfClass:[NSString class]]) {
		[self addSmartLibrary:name predicate:predicate order:kSmartLibraryOrder];
	} else {
		XspfMXspfListObject *obj = contextInfo;
		obj.name = name;
		obj.predicate = predicate;
	}
}
- (void)retryEditPredicate:(NSWindow *)sheet :(NSInteger)returnCode :(void *)contextInfo
{
	if([(id)contextInfo isKindOfClass:[NSString class]]) {
		[self performSelector:@selector(newPredicate:) withObject:nil afterDelay:0.0];
	} else {
		[self performSelector:@selector(editPredicate:) withObject:nil afterDelay:0.0];
	}
}
- (void)didEndAskDelete:(NSWindow *)sheet :(NSInteger)returnCode :(void *)contextInfo
{
	if(returnCode == NSCancelButton) return;
	
	[[self managedObjectContext] deleteObject:contextInfo];
}

- (IBAction)test01:(id)sender
{
//	NSArray *array = [editor rowTemplates];
	
//	for(id templ in array) {
//		HMLog(HMLogLevelDebug @"Views -> %@", [templ templateViews]);
//		for(id v in [templ templateViews]) {
//			if([v respondsToSelector:@selector(tag)]) {
//				HMLog(HMLogLevelDebug, @"tag -> %d", [v tag]);
//			}
//		}
//	}
//	for(id templ in array) {
//		HMLog(HMLogLevelDebug, @"template -> %@", templ);
//	}
}

@end
