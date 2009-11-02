//
//  XspfManager.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfManager.h"

#import "XspfMMovieLoadRequest.h"


@implementation XspfManager

- (void)awakeFromNib
{
	channel = [[HMChannel alloc] initWithWorkerNum:1];
}

- (NSInteger)registerWithURL:(NSURL *)url
{
	id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Xspf"
										   inManagedObjectContext:[appDelegate managedObjectContext]];
	if(!obj) return 1;
	
	id info = [NSEntityDescription insertNewObjectForEntityForName:@"Info"
											inManagedObjectContext:[appDelegate managedObjectContext]];
	if(!obj) {
		[[appDelegate managedObjectContext] deleteObject:obj];
		return 2;
	}
	
	[obj setValue:info forKey:@"information"];
	[obj setValue:url forKey:@"url"];
	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"registerDate"];
	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"lastUpdateDate"];
		
	XspfMMovieLoadRequest *request = [XspfMMovieLoadRequest requestWithObject:obj url:url];
	[channel putRequest:request];
	
	return noErr;
} 

- (IBAction)add:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"xspf", @"com.masakih.xspf", nil]];
	[panel setAllowsMultipleSelection:YES];
	
	[panel beginSheetForDirectory:nil
							 file:nil
							types:[NSArray arrayWithObjects:@"xspf", @"com.masakih.xspf", nil]
				   modalForWindow:window
					modalDelegate:self
				   didEndSelector:@selector(endOpenPanel:::)
					  contextInfo:NULL];
}

- (void)endOpenPanel:(NSOpenPanel *)panel :(NSInteger)returnCode :(void *)context
{
	if(returnCode == NSCancelButton) return;
	
	[panel orderOut:nil];
	
	NSArray *URLs = [panel URLs];
	if([URLs count] == 0) return;
	
	[progressBar setUsesThreadedAnimation:YES];
	
	[NSApp beginSheet:progressPanel
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:Nil
		  contextInfo:NULL];
	[progressBar startAnimation:self];
	[progressMessage setStringValue:@"During register."];
	
	for(id URL in URLs) {
		[self registerWithURL:URL];
	}
	
	[progressBar stopAnimation:self];
	[progressPanel orderOut:self];
	[NSApp endSheet:progressPanel];
}
	

- (void)addItem:(id)item
{
	
}
	
	
- (void)removeItem:(id)item
{
	[self doesNotRecognizeSelector:_cmd];
}



#pragma mark#### NSTokenField Delegate ####
- (NSArray *)tokenField:(NSTokenField *)tokenField
completionsForSubstring:(NSString *)substring
		   indexOfToken:(NSInteger)tokenIndex
	indexOfSelectedItem:(NSInteger *)selectedIndex
{
	NSLog(@"Enter %@", NSStringFromSelector(_cmd));
	
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", substring];
	NSEntityDescription *entry = [NSEntityDescription entityForName:@"VoiceActor"
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

- (void)registerVoiceActor:(NSTokenField *)tokenField
{
	NSLog(@"Enter %@", NSStringFromSelector(_cmd));
	
	id array = [tokenField objectValue];
	if(![array isKindOfClass:[NSArray class]]) return;
	
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
	NSEntityDescription *entry = [NSEntityDescription entityForName:@"VoiceActor"
											 inManagedObjectContext:moc];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:entry];
	
	for(id token in array) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[cd] %@", token];
		[fetch setPredicate:predicate];
		
		NSError *error = nil;
		NSUInteger count = [moc countForFetchRequest:fetch error:&error];
		if(error) {
			NSLog(@"fail fetch reason -> %@", error);
			continue;
		}
		if(count == 0) {
			id obj = [NSEntityDescription insertNewObjectForEntityForName:@"VoiceActor" inManagedObjectContext:moc];
			[obj setValue:token forKey:@"name"];
		}
	}
}
- (BOOL)control:(id)control textShouldEndEditing:(NSText *)fieldEditor
{
	NSLog(@"Enter %@", NSStringFromSelector(_cmd));
	if([control tag] == 2000) {
		[self registerVoiceActor:control];
	}
	
	return YES;
}


#pragma mark#### Test ####
- (IBAction)test01:(id)sender
{
	NSLog(@"ManagedContext - >%@", [appDelegate managedObjectContext]);
}
- (IBAction)test02:(id)sender
{
	NSLog(@"Array controller -> %@", [controller arrangedObjects]);
}
- (IBAction)test03:(id)sender
{
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	id moc = [appDelegate managedObjectContext];
	
	[fetch setEntity:[NSEntityDescription entityForName:@"Xspf" inManagedObjectContext:moc]];
	
	id objs = [moc executeFetchRequest:fetch error:NULL];
	NSLog(@"Fetched -> %@", objs);
}
@end
