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
