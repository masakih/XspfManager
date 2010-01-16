// 
//  XspfMXspfListObject.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMXspfListObject.h"


@implementation XspfMXspfListObject 

@dynamic name;
@dynamic predicateData;
@dynamic order;

- (NSString *)name
{
	NSString *value;
	[self willAccessValueForKey:@"name"];
	value = [self primitiveValueForKey:@"name"];
	[self didAccessValueForKey:@"name"];
	
	return NSLocalizedString(value, @"vaule");
}
- (NSPredicate *)predicate
{
	[self willAccessValueForKey:@"predicate"];
	NSPredicate *predicate = [self primitiveValueForKey:@"predicate"];
	[self didAccessValueForKey:@"predicate"];
	if(predicate == nil) {
		NSData *predicateData = [self valueForKey:@"predicateData"];
		if(predicateData != nil) {
			predicate = [NSKeyedUnarchiver unarchiveObjectWithData:predicateData];
			[self setPrimitiveValue:predicate forKey:@"predicate"];
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

- (short)primitiveOrder
{
	return order;
}
- (void)setPrimitiveOrder:(short)newOrder
{
	order = newOrder;
}
- (short)order
{
	short value;
	[self willAccessValueForKey:@"order"];
	value = order;
	[self didAccessValueForKey:@"order"];
	
	return value;
}
- (void)setOrder:(short)newOrder
{
	[self willChangeValueForKey:@"order"];
	order = newOrder;
	[self didChangeValueForKey:@"order"];
}
@end
