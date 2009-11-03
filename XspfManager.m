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
static XspfManager *sharedInstance = nil;

+ (XspfManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


- (id)init
{
	[super initWithWindowNibName:@"MainWindow"];
	channel = [[HMChannel alloc] initWithWorkerNum:1];
	
	return self;
}
- (void)awakeFromNib
{
	if(appDelegate && [self window]) {
		[self buildFamilyNameFromFile];
		[self showWindow:self];
	}
}
- (NSManagedObjectContext *)managedObjectContext
{
	return [appDelegate managedObjectContext];
}


- (NSInteger)registerWithURL:(NSURL *)url
{
	id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Xspf"
										   inManagedObjectContext:[appDelegate managedObjectContext]];
	if(!obj) return 1;
	
	id info = [NSEntityDescription insertNewObjectForEntityForName:@"Info"
											inManagedObjectContext:[appDelegate managedObjectContext]];
	if(!info) {
		[[appDelegate managedObjectContext] deleteObject:obj];
		return 2;
	}
	
	[obj setValue:info forKey:@"information"];
	[obj setValue:url forKey:@"url"];
	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"registerDate"];
	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"lastUpdateDate"];
		
	XspfMMovieLoadRequest *request = [XspfMMovieLoadRequest requestWithObject:obj url:url];
	[channel putRequest:request];
	
	[controller performSelector:@selector(setSelectedObjects:) withObject:[NSArray arrayWithObject:obj] afterDelay:0.0];
	
	return noErr;
} 
- (IBAction)openXspf:(id)sender
{
	id obj = [controller valueForKeyPath:@"selection.filePath"];
	if([obj isKindOfClass:[NSString class]]) {
		NSWorkspace *ws  = [NSWorkspace sharedWorkspace];
		[ws openFile:obj withApplication:@"XspfQT"];
	}
}
- (IBAction)add:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"xspf", @"com.masakih.xspf", nil]];
	[panel setAllowsMultipleSelection:YES];
	[panel setDelegate:self];
	
	[panel beginSheetForDirectory:nil
							 file:nil
							types:[NSArray arrayWithObjects:@"xspf", @"com.masakih.xspf", nil]
				   modalForWindow:[self window]
					modalDelegate:self
				   didEndSelector:@selector(endOpenPanel:::)
					  contextInfo:NULL];
}

- (void)endOpenPanel:(NSOpenPanel *)panel :(NSInteger)returnCode :(void *)context
{
	[panel orderOut:nil];
	
	if(returnCode == NSCancelButton) return;
	
	NSArray *URLs = [panel URLs];
	if([URLs count] == 0) return;
	
	[progressBar setUsesThreadedAnimation:YES];
	
	[NSApp beginSheet:progressPanel
	   modalForWindow:[self window]
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


#pragma mark#### load familynames ####
- (NSArray *)arrayFromLFSeparatedFile:(NSString *)name
{
	NSString *path;
	
//	path = [[appDelegate applicationSupportFolder] stringByAppendingPathComponent:name];
//	path = [path stringByAppendingPathExtension:@"txt"];
//	if(!path) {
		path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
//	}
	
	NSError *error = nil;
	NSString *content = [NSString stringWithContentsOfFile:path
												  encoding:NSUTF8StringEncoding
													 error:&error];
	if(error) {
		NSLog(@"path => %@", path);
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
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
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
- (void) buildFamilyNameFromFile
{
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
	
	NSString *entityName;
	NSArray *contents;
	entityName = @"FamilyName";
	if([self isEmptyEntityName:entityName]) {
		contents = [self arrayFromLFSeparatedFile:entityName];
				
		id attribute;
		for(attribute in contents) {
			NSArray *attr = [self arrayFromTabSeparatedString:attribute];
			if([attr count] < 2) continue;
			
			id obj = [NSEntityDescription insertNewObjectForEntityForName:entityName
												   inManagedObjectContext:moc];
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
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
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
#pragma mark#### NSWidnow Delegate ####
/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[appDelegate managedObjectContext] undoManager];
}

#pragma mark#### NSOpenPanel Delegate ####
- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSInteger num;
	NSURL *url = [NSURL fileURLWithPath:filename];
	
	fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"Xspf" inManagedObjectContext:moc]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlString LIKE %@", [url absoluteString]];
	[fetch setPredicate:predicate];
	num = [moc countForFetchRequest:fetch error:&error];
	if(error) {
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	return num == 0;
}

#pragma mark#### NSTokenField Delegate ####
#if 1
- (NSArray *)tokenField:(NSTokenField *)tokenField
completionsForSubstring:(NSString *)substring
		   indexOfToken:(NSInteger)tokenIndex
	indexOfSelectedItem:(NSInteger *)selectedIndex
{
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"roman BEGINSWITH[cd] %@"
							  @"OR japanese BEGINSWITH[cd] %@"
							  @"OR yomigana BEGINSWITH[cd] %@", substring,substring,substring];
	NSEntityDescription *entry = [NSEntityDescription entityForName:@"FamilyName"
											 inManagedObjectContext:moc];
	
	[fetch setEntity:entry];
	[fetch setPredicate:predicate];
	
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
		predicate = [NSPredicate predicateWithFormat:string argumentArray:names];
	} else {
		predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", substring];
	}
	entry = [NSEntityDescription entityForName:entryName inManagedObjectContext:moc];
	[fetch setEntity:entry];
	[fetch setPredicate:predicate];
	
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
	NSLog(@"Enter %@", NSStringFromSelector(_cmd));
	
	NSString *entryName = @"";
	switch([tokenField tag]) {
		case 2000:
			entryName = @"VoiceActor";
			break;
		case 2001:
			entryName = @"Product";
			break;
	}
	
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
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
	
	NSManagedObjectContext *moc = [appDelegate managedObjectContext];
	NSEntityDescription *entry = [NSEntityDescription entityForName:entryName
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
			id obj = [NSEntityDescription insertNewObjectForEntityForName:entryName inManagedObjectContext:moc];
			[obj setValue:token forKey:@"name"];
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

#pragma mark#### XspfMCollectionView Delegate ####
- (void)enterAction:(XspfMCollectionView *)view
{
	[self openXspf:view];
}

#pragma mark#### Test ####
- (IBAction)test01:(id)sender
{
	[self truncateFamilyName];
	[self buildFamilyNameFromFile];
}
- (IBAction)test02:(id)sender
{
	NSResponder *responder = [[self window] firstResponder];
	while(responder) {
		NSLog(@"Responder -> %@", responder);
		responder = [responder nextResponder];
	}
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
