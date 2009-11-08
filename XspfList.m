// 
//  XspfList.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfList.h"


@implementation XspfList 

@dynamic name;
@dynamic predicateData;

- (NSPredicate *)predicate
{
	[self willAccessValueForKey:@"predicate"];
	NSPredicate *predicate = [self primitiveValueForKey:@"predicate"];
	[self didAccessValueForKey:@"predicate"];
	if(predicate == nil) {
		NSData *predicateData = [self valueForKey:@"predicateData"];
		if(predicateData != nil) {
			predicate = [NSKeyedUnarchiver unarchiveObjectWithData:predicateData];
			[self setValue:predicate forKey:@"predicate"];
		}
	}
	return predicate;
}
- (void)setPredicate:(NSPredicate *)aPredicate
{
	[self willChangeValueForKey:@"predicate"];
	[self setPrimitiveValue:aPredicate forKey:@"predicate"];
	[self didChangeValueForKey:@"predicate"];
	[self setValue:[NSKeyedArchiver archivedDataWithRootObject:aPredicate] forKey:@"predicateData"];
}

- (id)xspfs
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSPredicate *predicate = [self predicate];
	NSError *error = nil;
	NSFetchRequest *fetch;
	
	fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:@"Xspf" inManagedObjectContext:moc]];
	[fetch setPredicate:predicate];
	
	id objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			NSLog(@"fail fetch reason -> %@", error);
		}
	}
	
	return objects;
}

@end
