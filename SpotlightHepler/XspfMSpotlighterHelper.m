//
//  XspfMSpotlighterHelper.m
//  XspfMSpotlighterHelper
//
//  Created by Hori,Masaki on 11/06/29.
//  Copyright 2011 masakih. All rights reserved.
//

#import "XspfMSpotlighterHelper.h"


@implementation XspfMSpotlighterHelper

- (id)init
{
	self= [super init];
	if(self) {
		lock  = [[NSLock alloc] init];
		
		timer = [NSTimer scheduledTimerWithTimeInterval:30
												 target:self
											   selector:@selector(purge:)
											   userInfo:nil
												repeats:YES];
	}
	return self;
}
- (void)dealloc
{
	[timer invalidate];
	[lock lock];
	[connector release];
	connector = nil;
	[lock release];
	
	[super dealloc];
}
- (XspfMCoreDataConnector *)connector
{
	[lock lock];
	if(connector) return connector;
	
	connector = [[XspfMCoreDataConnector alloc] init];
	return connector;
}
- (void)purge:(NSTimer *)t
{
	if([lock tryLock]) {
		[connector release];
		connector = nil;
		[lock unlock];
	}
}

id valueOrNull(id value)
{
	return value ? value : (id)kCFNull;
}
- (NSDictionary *)dataFromURL:(NSURL *)url
{
	id pool = [[NSAutoreleasePool alloc] init];
	
	NSDictionary *result = nil;
	@try {
		NSError *error = nil;
		XspfMCoreDataConnector *con = [self connector];
		if(!con) {
			NSLog(@"Can not create XspfMCoreDataConnector.");
			@throw self;
		}
		NSManagedObjectContext *moc = [con managedObjectContext];
		if(!moc) {
			NSLog(@"Can not get managedObjectContext.");
			@throw self;
		}
		NSFetchRequest *req = [[NSFetchRequest alloc] init];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"xspf.urlString = %@", [url absoluteString]];
		[req setPredicate:predicate];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Info" inManagedObjectContext:moc];
		[req setEntity:entity];
		
		NSArray *infos = [moc executeFetchRequest:req error:&error];
		[req release];
		if(!infos) {
			NSString *errorString = @"";
			if(error) {
				errorString = [error localizedDescription];
			}
			NSLog(@"Can not excte request %@", errorString);
			@throw self;
		}
		
		if([infos count] == 0) {
			NSLog(@"Not found data.");
			@throw self;
		}
				
		id info = [infos objectAtIndex:0];
		NSArray *voiceActors = [info valueForKey:@"voiceActors"];
		NSArray *products = [info valueForKey:@"products"];
		NSNumber *label = [info valueForKeyPath:@"xspf.label"];
		NSNumber *rateing = [info valueForKeyPath:@"xspf.rating"];
		
		result = [[NSDictionary alloc] initWithObjectsAndKeys:
				  valueOrNull(voiceActors), @"com_masakih_xspf_voiceActor",
				  valueOrNull(products), @"com_masakih_xspf_products",
				  valueOrNull(label), @"com_masakih_xspf_label",
				  valueOrNull(rateing), kMDItemStarRating,
				  nil];
		
	}
	@catch(XspfMSpotlighterHelper *ex) {
		result = [[NSDictionary alloc] init];
	}
	@catch(id ex) {
		NSLog(@"Caught exception. %@", ex);
	}
	@finally {
		[pool release];
		[lock unlock];
	}
		
	return [result autorelease];
}

@end
