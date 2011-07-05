//
//  XspfMSpotlighterHelper.m
//  XspfMSpotlighterHelper
//
//  Created by Hori,Masaki on 11/06/29.
//  Copyright 2011 masakih. All rights reserved.
//

#import "XspfMSpotlighterHelper.h"


#import "XspfMCoreDataConnector.h"



@implementation XspfMSpotlighterHelper

- (NSDictionary *)dataFromURL:(NSURL *)url
{
	id pool = [[NSAutoreleasePool alloc] init];
	
	NSDictionary *result = nil;
	@try {
		NSArray *voiceActors = (id)[NSNull null];
		NSArray *products = (id)[NSNull null];
		
		NSError *error = nil;
		XspfMCoreDataConnector *con = [[XspfMCoreDataConnector alloc] init];
		if(!con) {
			NSLog(@"Can not create XspfMCoreDataConnector.");
			goto fail;
		}
		NSManagedObjectContext *moc = [con managedObjectContext];
		if(!moc) {
			NSLog(@"Can not get managedObjectContext.");
			goto fail;
		}
		NSFetchRequest *req = [[NSFetchRequest alloc] init];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"xspf.urlString = %@", [url absoluteString]];
		[req setPredicate:predicate];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Info" inManagedObjectContext:moc];
		[req setEntity:entity];
		
		NSArray *infos = [moc executeFetchRequest:req error:&error];
		if(!infos) {
			NSString *errorString = @"";
			if(error) {
				errorString = [error localizedDescription];
			}
			NSLog(@"Can not excte request %@", errorString);
			goto fail;
		}
		
		if([infos count] == 0) {
			NSLog(@"Not found data.");
			goto fail;
		}
		
		id info = [infos objectAtIndex:0];
		voiceActors = [info valueForKey:@"voiceActors"];
		products = [info valueForKey:@"products"];
		
		result = [[NSDictionary alloc] initWithObjectsAndKeys:
				  voiceActors, @"com_masakih_xspf_voiceActor",
				  products, @"com_masakih_xspf_products",
				  nil];
		
	}
	@catch(id ex) {
		NSLog(@"Caught exception. %@", ex);
	}
	
	[pool release];
	
	return [result autorelease];
	
fail:
	[pool release];
	return [NSDictionary dictionary];
}

@end
