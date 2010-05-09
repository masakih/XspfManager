//
//  XspfMRuleRowsBuilder.m
//
//  Created by Hori,Masaki on 10/04/22.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMRuleRowsBuilder.h"
#import "XspfMRuleRowsBuilder_private.h"


@implementation XspfMRuleRowsBuilder
@synthesize rowTemplate;

+ (id)builderWithPredicate:(NSPredicate *)aPredicate
{
	return [[[self alloc] initWithPredicate:aPredicate] autorelease];
}
- (id)initWithPredicate:(NSPredicate *)aPredicate
{
	[super init];
	[self release];
	
	Class subclasses[] = {
		[XspfMRuleCompoundPredicateRowsBuilder class],
		[XspfMRuleStringRowsBuilder class],
		[XspfMRuleNumberRowsBuilder class],
		[XspfMRuleDateRowsBuilder class],
		[XspfMRuleRatingRowsBuilder class],
		[XspfMRuleLabelRowsBuilder class],
		Nil,
	};
	
	NSInteger i = 0;
	while(subclasses[i]) {
		if([subclasses[i] canBuildPredicate:aPredicate]) {
			id obj = [[subclasses[i] alloc] initWithPredicate:aPredicate];
			return obj;
		}
		i++;
	}
	
	NSLog(@"Could not find corresponded concrete class.");
	return nil;
}
- (void)setPredicate:(id)aPredicate
{
	[predicate autorelease];
	predicate = [aPredicate retain];
}

- (void)dealloc
{
	self.rowTemplate = nil;
	[predicate release];
	
	[super dealloc];
}
- (void)build {}
- (NSDictionary *)rows
{
	NSDictionary *rows = [NSMutableDictionary dictionaryWithObjectsAndKeys:
						  [self rowType], @"rowType",
						  [self displayValues], @"displayValues",
						  [self criteria], @"criteria",
						  [self subrows], @"subrows",
						  nil];
	return rows;
}

- (NSNumber *)rowType { return nil; }
- (NSArray *)criteria { return nil; }
- (NSArray *)subrows { return nil; }
- (NSArray *)displayValues
{
	return [NSArray arrayWithObjects:
			[self value01], [self value02], [self value03], [self value04],
			[self value05], [self value06], [self value07],
			nil];
}
- (id)value01 { return nil; }
- (id)value02 { return nil; }
- (id)value03 { return nil; }
- (id)value04 { return nil; }
- (id)value05 { return nil; }
- (id)value06 { return nil; }
- (id)value07 { return nil; }
@end
