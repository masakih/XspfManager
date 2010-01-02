//
//  XspfMDetailViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMDetailViewController.h"

#import "XspfManager.h"

@interface XspfMDetailViewController(HMPrivate)
- (void)buildFamilyNameFromFile;
@end

@implementation XspfMDetailViewController

- (id)init
{
	[super initWithNibName:@"DetailView" bundle:nil];
	
	[self buildFamilyNameFromFile];
	
	return self;
}

#pragma mark#### NSTokenField Delegate ####
#if 0
- (NSURL *)dictionayStoreURL
{
	NSString *appSupport = [[NSApp delegate] applicationSupportFolder];
	NSString *storeString = [appSupport stringByAppendingPathComponent:@"Dictionay.qdb"];
	
	return [NSURL fileURLWithPath:storeString];
}
- (id)dictionayStore
{
	id store = [[[self managedObjectContext] persistentStoreCoordinator] persistentStoreForURL:[self dictionayStoreURL]];
	if(!store) {
		NSError *error = nil;
		store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSApp delegate] managedObjectModel]];
		if (![store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self dictionayStoreURL] options:nil error:&error]){
			[[NSApplication sharedApplication] presentError:error];
		}
	}
	return store;
}
#else
- (id)dictionayStore { return nil; }
#endif

#if 1
- (NSArray *)tokenField:(NSTokenField *)tokenField
completionsForSubstring:(NSString *)substring
		   indexOfToken:(NSInteger)tokenIndex
	indexOfSelectedItem:(NSInteger *)selectedIndex
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSPredicate *aPredicate = [NSPredicate predicateWithFormat:
							   @"roman BEGINSWITH[cd] %@"
							   @"OR japanese BEGINSWITH[cd] %@"
							   @"OR yomigana BEGINSWITH[cd] %@", substring,substring,substring];
	NSEntityDescription *entry = [NSEntityDescription entityForName:@"FamilyName"
											 inManagedObjectContext:moc];
	
	[fetch setEntity:entry];
	[fetch setPredicate:aPredicate];
	
	NSError *error = nil;
	NSArray *objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			NSLog(@"fail fetch reason -> %@", error);
		}
	}
	
	NSString *entryName = @"";
	switch([tokenField tag]) {
		case 2000:
			entryName = @"VoiceActor";
			break;
		case 2001:
			entryName = @"Product";
			break;
	}
	
	if([objects count] > 0) {
		NSMutableString *string = [NSMutableString string];
		NSMutableArray *names = [NSMutableArray array];
		for(id e in objects) {
			if([string length]) {
				[string appendString:@" OR "];
			}
			[string appendFormat:@"name BEGINSWITH[cd] %%@ "];
			[names addObject:[e valueForKey:@"japanese"]];
		}
		aPredicate = [NSPredicate predicateWithFormat:string argumentArray:names];
	} else {
		aPredicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", substring];
	}
	entry = [NSEntityDescription entityForName:entryName inManagedObjectContext:moc];
	[fetch setEntity:entry];
	[fetch setPredicate:aPredicate];
	
	error = nil;
	objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			NSLog(@"fail fetch reason -> %@", error);
		}
	}
	
	NSMutableArray *result = [NSMutableArray arrayWithObject:substring];
	for(id obj in objects) {
		[result addObject:[obj valueForKey:@"name"]];
	}
	
	return result;
}
#else
- (NSArray *)tokenField:(NSTokenField *)tokenField
completionsForSubstring:(NSString *)substring
		   indexOfToken:(NSInteger)tokenIndex
	indexOfSelectedItem:(NSInteger *)selectedIndex
{
	HMLog(HMLogLevelDebug, @"Enter %@", NSStringFromSelector(_cmd));
	
	NSString *entryName = @"";
	switch([tokenField tag]) {
		case 2000:
			entryName = @"VoiceActor";
			break;
		case 2001:
			entryName = @"Product";
			break;
	}
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", substring];
	NSEntityDescription *entry = [NSEntityDescription entityForName:entryName
											 inManagedObjectContext:moc];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:entry];
	[fetch setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			NSLog(@"fail fetch reason -> %@", error);
		}
	}
	
	NSMutableArray *result = [NSMutableArray array];
	for(id obj in objects) {
		[result addObject:[obj valueForKey:@"name"]];
	}
	
	return result;
}
#endif

- (void)registerVoiceActor:(NSTokenField *)tokenField
{
	id array = [tokenField objectValue];
	if(![array isKindOfClass:[NSArray class]]) return;
	
	NSString *entryName = @"";
	switch([tokenField tag]) {
		case 2000:
			entryName = @"VoiceActor";
			break;
		case 2001:
			entryName = @"Product";
			break;
	}
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *entry = [NSEntityDescription entityForName:entryName
											 inManagedObjectContext:moc];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:entry];
	
	for(id token in array) {
		NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"name LIKE[cd] %@", token];
		[fetch setPredicate:aPredicate];
		
		NSError *error = nil;
		NSUInteger count = [moc countForFetchRequest:fetch error:&error];
		if(error) {
			NSLog(@"fail fetch reason -> %@", error);
			continue;
		}
		if(count == 0) {
			id obj = [NSEntityDescription insertNewObjectForEntityForName:entryName inManagedObjectContext:moc];
			[obj setValue:token forKey:@"name"];
			[moc assignObject:obj toPersistentStore:[self dictionayStore]];
		}
	}
}
- (BOOL)control:(id)control textShouldEndEditing:(NSText *)fieldEditor
{
	if([control tag] == 2000 || [control tag] == 2001) {
		[self registerVoiceActor:control];
	}
	
	return YES;
}

#pragma mark#### load familynames ####
- (NSArray *)arrayFromLFSeparatedFile:(NSString *)name
{
	NSString *path;
	
	path = [[[NSApp delegate] applicationSupportFolder] stringByAppendingPathComponent:name];
	path = [path stringByAppendingPathExtension:@"txt"];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir = NO;
	if(![fm fileExistsAtPath:path isDirectory:&isDir] || isDir) {
		path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
	}
	
	NSError *error = nil;
	NSString *content = [NSString stringWithContentsOfFile:path
												  encoding:NSUTF8StringEncoding
													 error:&error];
	if(error) {
		HMLog(HMLogLevelDebug, @"path => %@", path);
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	return [content componentsSeparatedByString:@"\x0a"];
}

- (NSArray *)arrayFromTabSeparatedString:(NSString *)string
{
	return [string componentsSeparatedByString:@"\t"];
}
- (BOOL)isEmptyEntityName:(NSString *)name
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSInteger num;
	
	fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:name
								 inManagedObjectContext:moc]];
	num = [moc countForFetchRequest:fetch
							  error:&error];
	[fetch release];
	fetch = nil;
	if(error) {
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	return num == 0;
}
- (void)buildFamilyNameFromFile
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	NSString *entityName;
	NSArray *contents;
	entityName = @"FamilyName";
	if([self isEmptyEntityName:entityName]) {
		contents = [self arrayFromLFSeparatedFile:entityName];
		
		id key;
		for(key in contents) {
			NSArray *attr = [self arrayFromTabSeparatedString:key];
			if([attr count] < 2) continue;
			
			id obj = [NSEntityDescription insertNewObjectForEntityForName:entityName
												   inManagedObjectContext:moc];
			[moc assignObject:obj toPersistentStore:[self dictionayStore]];
			[obj setValue:[attr objectAtIndex:0] forKey:@"roman"];
			[obj setValue:[attr objectAtIndex:1] forKey:@"japanese"];
			
			if([attr count] > 2) {
				[obj setValue:[attr objectAtIndex:2] forKey:@"yomigana"];
			}
		}
	}
	
}

- (void)truncateFamilyName
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entry = [NSEntityDescription entityForName:@"FamilyName"
											 inManagedObjectContext:moc];
	[fetch setEntity:entry];
	
	NSError *error = nil;
	NSArray *objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			NSLog(@"fail fetch reason -> %@", error);
		}
	}
	
	[moc lock];
	for(id obj in objects) {
		[moc deleteObject:obj];
	}
	[moc unlock];
}

#pragma mark#### Test ####
- (IBAction)test01:(id)sender
{
	[self truncateFamilyName];
	[self buildFamilyNameFromFile];
}

@end
