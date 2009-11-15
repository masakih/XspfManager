//
//  XspfManager.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/01.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfManager.h"

#import "XspfMMovieLoadRequest.h"
#import "XspfMCheckFileModifiedRequest.h"

#import "XspfMLibraryViewController.h"
#import "XspfMCollectionViewController.h"
#import "XspfMListViewController.h"
#import "XspfMDetailViewController.h"


@interface XspfManager(HMPrivate)
- (void)setupXspfLists;
- (void)setupDetailView;
- (void)changeViewType:(XspfMViewType)newType;
- (void)setCurrentListViewType:(XspfMViewType)newType;
@end

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
	
	viewControllers = [[NSMutableDictionary alloc] init];
		
	return self;
}
- (void)awakeFromNib
{
	static BOOL didSetupOnMainMenu = NO;
	
	if(appDelegate && !didSetupOnMainMenu) {
		didSetupOnMainMenu = YES;
		[self window];
	}
}
- (void)windowDidLoad
{
	[self setupXspfLists];
	[self setupDetailView];
	if(currentListViewType == typeNotSelected) {
		[self setCurrentListViewType:typeCollectionView];
	}
	
	[self showWindow:nil];
}
#pragma mark#### KVC ####
- (NSManagedObjectContext *)managedObjectContext
{
	return [appDelegate managedObjectContext];
}
- (NSArrayController *)arrayController
{
	return controller;
}

- (XspfMViewType)currentListViewType
{
	return currentListViewType;
}
- (void)setCurrentListViewType:(XspfMViewType)newType
{
	if(currentListViewType == newType) return;
	
	[self changeViewType:newType];
}

#pragma mark#### Actions ####
- (IBAction)openXspf:(id)sender
{
	XSPFMXspfObject *rep = [controller valueForKeyPath:@"selection.self"];
	[[NSWorkspace sharedWorkspace] openFile:rep.filePath withApplication:@"XspfQT"];
	rep.lastPlayDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
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


- (NSInteger)registerWithURL:(NSURL *)url
{
	XSPFMXspfObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Xspf"
														 inManagedObjectContext:[appDelegate managedObjectContext]];
	if(!obj) return 1;
	
	obj.url = url;
	obj.registerDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
	
	// will set in XspfMCheckFileModifiedRequest.
//	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"modificationDate"];
//	[obj setValue:[NSDate dateWithTimeIntervalSinceNow:0.0] forKey:@"creationDate"];
	
	id<HMChannel> channel = [appDelegate channel];
	id<HMRequest> request = [XspfMCheckFileModifiedRequest requestWithObject:obj url:url];
	[channel putRequest:request];
	request = [XspfMMovieLoadRequest requestWithObject:obj url:url];
	[channel putRequest:request];
	
	return noErr;
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
	
#pragma mark#### Other methods ####
- (void)changeViewType:(XspfMViewType)viewType
{
	if(currentListViewType == viewType) return;
	currentListViewType = viewType;
	
	NSString *className = nil;
	switch(currentListViewType) {
		case typeCollectionView:
			className = @"XspfMCollectionViewController";
			break;
		case typeTableView:
			className = @"XspfMListViewController";
			break;
	}
	if(!className) return;
	
	NSViewController *targetContorller = [viewControllers objectForKey:className];
	if(!targetContorller) {
		targetContorller = [[[NSClassFromString(className) alloc] init] autorelease];
		if(!targetContorller) return;
		[viewControllers setObject:targetContorller forKey:className];
		[targetContorller setRepresentedObject:controller];
	}
		
	[[listViewController view] removeFromSuperview];
	listViewController = targetContorller;
	[listView addSubview:[listViewController view]];
	[[listViewController view] setFrame:[listView bounds]];
}


- (void)setupXspfLists
{
	if(libraryViewController) return;
	
	libraryViewController = [[XspfMLibraryViewController alloc] init];
	[libraryViewController setRepresentedObject:listController];
	[libraryView addSubview:[libraryViewController view]];
	[[libraryViewController view] setFrame:[libraryView bounds]];
}
- (void)setupDetailView
{
	if(detailViewController) return;
	
	detailViewController = [[XspfMDetailViewController alloc] init];
	[detailViewController setRepresentedObject:controller];
	[detailView addSubview:[detailViewController view]];
	[[detailViewController view] setFrame:[detailView bounds]];
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
	NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"urlString LIKE %@", [url absoluteString]];
	[fetch setPredicate:aPredicate];
	num = [moc countForFetchRequest:fetch error:&error];
	if(error) {
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	return num == 0;
}

#pragma mark#### Test ####
- (IBAction)test01:(id)sender
{
	//
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
	
	id moc = [appDelegate managedObjectContext];
	
	NSLog(@"Updated count -> %d", [[moc updatedObjects] count]);
}
@end
