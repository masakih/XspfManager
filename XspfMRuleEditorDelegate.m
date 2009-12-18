//
//  XspfMRuleEditorDelegate.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/28.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorDelegate.h"

#import "XspfMRuleEditorRow.h"

@implementation XspfMRuleEditorDelegate

static NSString *XspfMREDRowsKey = @"rows";
static NSString *XspfMREDPredicateRowsKey = @"predicateRows";
static NSString *XspfMREDNameKey = @"name";


- (NSDictionary *)buildRows:(NSArray *)template
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for(id row in template) {
		id name = [row valueForKey:XspfMREDNameKey];
		id rule = [XspfMRule ruleWithPlist:row];
		[result setObject:rule forKey:name];
	}
	rowTemplate = [result retain];
	return result;
}
- (id)criteriaWithKeyPath:(NSString *)keypath
{
	NSString *key = nil;
	if([keypath isEqualToString:@"title"]) {
		key = @"String";
	} else if([keypath isEqualToString:@"rating"]) {
		key = @"Rate";
	} else if([[NSArray arrayWithObjects:@"lastPlayDate", @"modificationDate", @"creationDate", nil] containsObject:keypath]) {
		key = @"AbDate";
	}
	if(key) {
		id row = [rowTemplate valueForKey:key];
		id c = [[[row childAtIndex:0] copy] autorelease];
		[c setValue:keypath];
		return [NSArray arrayWithObject:c];
	}
	
	return nil;
}
- (void)awakeFromNib
{
	if(!compound) {
		compound = [[XspfMCompound alloc] init];
	}
		
	NSBundle *m = [NSBundle mainBundle];
	NSString *path = [m pathForResource:@"LibraryRowTemplate" ofType:@"plist"];
	NSArray *rowsTemplate = [NSArray arrayWithContentsOfFile:path];
	if(!rowsTemplate) {
		exit(12345);
	}
	
	[self buildRows:rowsTemplate];
		
	NSMutableArray *newRows = [NSMutableArray array];
	
	id c = [self criteriaWithKeyPath:@"title"];
	if(c) [newRows addObjectsFromArray:c];
	
	for(id keyPath in [NSArray arrayWithObjects:@"lastPlayDate", @"modificationDate", @"creationDate", nil]) {
		c = [self criteriaWithKeyPath:keyPath];
		if(c) [newRows addObjectsFromArray:c];
	}
	
	c = [self criteriaWithKeyPath:@"rating"];
	if(c) [newRows addObjectsFromArray:c];
	
	simples = [newRows retain];
		
	////
	predicateRows = [[NSMutableArray alloc] init];
	[ruleEditor bind:XspfMREDRowsKey toObject:self withKeyPath:XspfMREDPredicateRowsKey options:nil];
}

- (void)resolveExpression:(id)exp
{
	NSString *message = nil;
	
	switch([exp expressionType]) {
		case NSConstantValueExpressionType:
			message = [NSString stringWithFormat:@"constant -> %@", [exp constantValue]];
			break;
		case NSEvaluatedObjectExpressionType:
			message = [NSString stringWithFormat:@"constant -> %@", [exp constantValue]];
			break;
		case NSVariableExpressionType:
			message = [NSString stringWithFormat:@"variable -> %@", [exp variable]];
			break;
		case NSKeyPathExpressionType:
			message = [NSString stringWithFormat:@"keyPath -> %@", [exp keyPath]];
			break;
		case NSFunctionExpressionType:
			message = [NSString stringWithFormat:@"oprand -> %@(%@), function -> %@, arguments -> %@",
					   [exp operand], NSStringFromClass([[exp operand] class]),
					   [exp function], [exp arguments]];
			break;
		case NSAggregateExpressionType:
			message = [NSString stringWithFormat:@"collection -> %@", [exp collection]];
			break;
	}
	
	fprintf(stderr, "%s\n", [message UTF8String]);
}
- (void)resolvePredicate:(id)predicate
{
	if([predicate isKindOfClass:[NSCompoundPredicate class]]) {
		NSArray *sub = [predicate subpredicates];
		for(id p in sub) {
			[self resolvePredicate:p];
		}
	} else if([predicate isKindOfClass:[NSComparisonPredicate class]]) {
		id left = [predicate leftExpression];
		id right = [predicate rightExpression];
		SEL sel = Nil;
		if([predicate predicateOperatorType] == NSCustomSelectorPredicateOperatorType) {
			sel = [predicate customSelector];
		}
		fprintf(stderr, "left ->\t");
		[self resolveExpression:left];
		if(sel) {
			fprintf(stderr, "%s\n", [[NSString stringWithFormat:@"SEL -> %@", NSStringFromSelector(sel)] UTF8String]);
		} else {
			fprintf(stderr, "%s\n", [[NSString stringWithFormat:@"type -> %d, opt -> %d, mod -> %d", [predicate predicateOperatorType], [predicate options], [predicate comparisonPredicateModifier]] UTF8String]);
		}
		fprintf(stderr, "right ->\t");
		[self resolveExpression:right];
		fprintf(stderr, "end resolve.\n");
	}
}

- (void)setPredicate:(id)predicate
{
	NSLog(@"predicate -> (%@) %@", NSStringFromClass([predicate class]), predicate);
	[self resolvePredicate:predicate];
	
	id new = [XspfMRule ruleEditorRowsFromPredicate:predicate withRowTemplate:rowTemplate];
	
	[self willChangeValueForKey:XspfMREDPredicateRowsKey];
	[predicateRows release];
	predicateRows = [new retain];
	[self didChangeValueForKey:XspfMREDPredicateRowsKey];
//	[ruleEditor reloadCriteria];
}
- (void)setPredicateRows:(id)p
{
//	NSLog(@"new -> %@", p);
	[predicateRows release];
	predicateRows = [p retain];
}

#pragma mark#### NSRleEditor Delegate ####

- (NSInteger)ruleEditor:(NSRuleEditor *)editor
numberOfChildrenForCriterion:(id)criterion
			withRowType:(NSRuleEditorRowType)rowType
{
	NSInteger result = 0;
	
	if(rowType == NSRuleEditorRowTypeCompound) {
		return [compound numberOfChildrenForChild:criterion];
	}
	
	if(!criterion) {
		result = [simples count];
	} else {
		result = [criterion numberOfChildren];
	}
	
	//	NSLog(@"numner\tcriterion -> %@, type -> %d, result -> %d", criterion, rowType, result);
	
	return result;
}

- (id)ruleEditor:(NSRuleEditor *)editor
		   child:(NSInteger)index
	forCriterion:(id)criterion
	 withRowType:(NSRuleEditorRowType)rowType
{
	id result = nil;
	
	if(rowType == NSRuleEditorRowTypeCompound) {
		return [compound childForChild:criterion atIndex:index];
	}
	
	if(!criterion) {
		result = [simples objectAtIndex:index];
	} else {
		result = [criterion childAtIndex:index];
	}
	
	//	NSLog(@"child\tindex -> %d, criterion -> %@, type -> %d, result -> %@", index, criterion, rowType, result);
	
	return result;
}
- (id)ruleEditor:(NSRuleEditor *)editor
displayValueForCriterion:(id)criterion
		   inRow:(NSInteger)row
{
	id result = nil;
	
	NSRuleEditorRowType rowType = [editor rowTypeForRow:row];
	if(rowType == NSRuleEditorRowTypeCompound) {
		return [compound displayValueForChild:criterion];
	}
	
	if(!criterion) {
		//
	} else {
		result = [criterion displayValueForRuleEditor:editor inRow:row];
	}
		
	//	NSLog(@"display\tcriterion -> %@, row -> %d, result -> %@", criterion, row, result);
	
	return result;
}
- (NSDictionary *)ruleEditor:(NSRuleEditor *)editor
  predicatePartsForCriterion:(id)criterion
			withDisplayValue:(id)displayValue
					   inRow:(NSInteger)row
{
	id result = nil;
	
	NSRuleEditorRowType rowType = [editor rowTypeForRow:row];
	if(rowType == NSRuleEditorRowTypeCompound) {
		return [compound predicateForChild:criterion withDisplayValue:displayValue];
	}
	
	result = [criterion predicatePartsWithDisplayValue:displayValue forRuleEditor:editor inRow:row];
//	NSLog(@"predicate\tresult -> %@", result);
	
	//	NSLog(@"predicate\tcriterion -> %@, value -> %@, row -> %d, result -> %@", criterion, displayValue, row, result);
	
	return result;
}
- (void)ruleEditorRowsDidChange:(NSNotification *)notification
{
	//
}
@end

@implementation NSString (XspfMTest)
- (NSArray *)rangeOfToday
{
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	id result = [NSArray arrayWithObjects:startOfToday, now, nil];
	return result;
}
- (NSArray *)rangeOfYesterday
{
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	[comp setDay:-1];
	NSDate *startOfYesterday = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
		
	id result = [NSArray arrayWithObjects:startOfYesterday, startOfToday, nil];
	return result;
}
- (NSArray *)rangeOfThisWeek
{
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	
	[comp setWeekday:-[nowComp weekday]+1];
	NSDate *startOfThisWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
		
	id result = [NSArray arrayWithObjects:startOfThisWeek, now, nil];
	return result;
}
- (NSArray *)rangeOfLastWeek
{
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	[comp setWeekday:-[nowComp weekday]+1];
	NSDate *startOfThisWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	[comp setWeekday:-[nowComp weekday]+1];
	[comp setWeek:-1];
	NSDate *startOfLastWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
		
	id result = [NSArray arrayWithObjects:startOfLastWeek, startOfThisWeek, nil];
	return result;
}

- (NSArray *)dateRangeByNumber:(NSNumber *)numberValue unit:(NSNumber *)unitValue
{
	NSInteger number = [numberValue integerValue];
	NSInteger unit = [unitValue integerValue];
	
	NSDateComponents *comp01 = [[NSDateComponents alloc] init];
	NSDateComponents *comp02 = [[NSDateComponents alloc] init];
	NSUInteger unitFlag = 0;
	switch(unit) {
		case 0:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
			[comp01 setDay:-number];
			[comp02 setDay:-number+1];
			break;
		case 1:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit;
			[comp01 setWeek:-number];
			[comp02 setDay:-1];
			break;
		case 2:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit;
			[comp01 setMonth:-number];
			[comp02 setDay:-1];
			break;
		case 3:
			unitFlag = NSYearCalendarUnit;
			[comp01 setYear:-number];
			[comp02 setDay:-1];
			break;
	}
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:unitFlag fromDate:now];
	NSDate *aDay = [aCalendar dateFromComponents:nowComp];
	
	NSDate *pastDay01 = [aCalendar dateByAddingComponents:comp01 toDate:aDay options:0];
	NSDate *pastDay02 = [aCalendar dateByAddingComponents:comp02 toDate:aDay options:0];
	
	id result = [NSArray arrayWithObjects:pastDay01, pastDay02, nil];
	return result;
}
- (NSDate *)dateByNumber:(NSNumber *)numberValue unit:(NSNumber *)unitValue
{
	NSInteger number = [numberValue integerValue];
	NSInteger unit = [unitValue integerValue];
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	NSUInteger unitFlag = 0;
	switch(unit) {
		case 0:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
			[comp setDay:-number];
			break;
		case 1:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit;
			[comp setWeek:-number];
			break;
		case 2:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit;
			[comp setMonth:-number];
			break;
		case 3:
			unitFlag = NSYearCalendarUnit;
			[comp setYear:-number];
			break;
	}
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:unitFlag fromDate:now];
	NSDate *aDay = [aCalendar dateFromComponents:nowComp];
	
	NSDate *pastDay = [aCalendar dateByAddingComponents:comp toDate:aDay options:0];
	
	return pastDay;
}
- (NSArray *)rangeDateByNumber:(NSNumber *)numberValue toNumber:(NSNumber *)number02Value unit:(NSNumber *)unitValue
{
	NSInteger number = [numberValue integerValue];
	NSInteger number02 = [number02Value integerValue];
	NSInteger unit = [unitValue integerValue];
	
	NSDateComponents *comp01 = [[NSDateComponents alloc] init];
	NSDateComponents *comp02 = [[NSDateComponents alloc] init];
	NSUInteger unitFlag = 0;
	switch(unit) {
		case 0:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
			[comp01 setDay:-number];
			[comp02 setDay:-number02];
			break;
		case 1:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit;
			[comp01 setWeek:-number+1];
			[comp01 setDay:-1];
			[comp02 setWeek:-number02];
			break;
		case 2:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit;
			[comp01 setMonth:-number+1];
			[comp01 setDay:-1];
			[comp02 setMonth:-number02];
			break;
		case 3:
			unitFlag = NSYearCalendarUnit;
			[comp01 setYear:-number+1];
			[comp01 setDay:-1];
			[comp02 setYear:-number02];
			break;
	}
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:unitFlag fromDate:now];
	NSDate *aDay = [aCalendar dateFromComponents:nowComp];
	
	NSDate *pastDay01 = [aCalendar dateByAddingComponents:comp01 toDate:aDay options:0];
	NSDate *pastDay02 = [aCalendar dateByAddingComponents:comp02 toDate:aDay options:0];
	
	id result = [NSArray arrayWithObjects:pastDay01, pastDay02, nil];
	NSLog(@"2 days -> %@", result);
	return result;
}
- (NSArray *)dateRangeFromVariable:(NSString *)date
{
	NSLog(@"In function argument is %@", date);
	
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
											fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	[comp setDay:-1];
	NSDate *startOfYesterday = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	[comp setDay:0];
	[comp setWeekday:-[nowComp weekday]+1];
	NSDate *startOfThisWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	[comp setWeekday:-[nowComp weekday]+1];
	[comp setWeek:-1];
	NSDate *startOfLastWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	NSLog(@"now -> %@\ntoday -> %@\nyesterday -> %@\nthisweek -> %@\nlastweek -> %@",
		  now, startOfToday, startOfYesterday, startOfThisWeek, startOfLastWeek);
	
	id result = [NSArray arrayWithObjects:now, startOfToday, nil];
	return result;
}
@end
