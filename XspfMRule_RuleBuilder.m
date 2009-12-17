//
//  XspfMRule_RuleBuilder.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/17.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorRow.h"

#import "XspfMRule_private.h"

static NSString *XspfMREDCriteriaKey = @"criteria";
static NSString *XspfMREDDisplayValuesKey = @"displayValues";
static NSString *XspfMREDRowTypeKey = @"rowType";
static NSString *XspfMREDSubrowsKey = @"subrows";


@interface XspfMRule (XspfMRuleBuilder_private)
- (id)buildRowsFromPredicate:(id)predicate withRowTemplate:(id)rowTemplate;
@end

@implementation XspfMRule (XspfMRuleBuilder)
+ (NSArray *)ruleEditorRowsFromPredicate:(NSPredicate *)predicate withRowTemplate:(id)rowTemplate
{
	XspfMRule *obj = [[[self class] alloc] init];
	NSArray *result = [obj ruleEditorRowsFromPredicate:predicate withRowTemplate:rowTemplate];
	[obj release];
	
	return result;
}
- (NSArray *)ruleEditorRowsFromPredicate:(NSPredicate *)predicate withRowTemplate:(id)rowTemplate
{
	return [self buildRowsFromPredicate:predicate withRowTemplate:rowTemplate];
}

- (NSArray *)displayValuesWithPredicate:(NSComparisonPredicate *)predicate
{
	id value02 = nil; id value03 = nil;
	id leftKeyPath = [[predicate leftExpression] keyPath];
	
	switch([predicate predicateOperatorType]) {
		case NSEqualToPredicateOperatorType:
			value02 = @"is";
			break;
		case NSNotEqualToPredicateOperatorType:
			value02 = @"is not";
			break;
		case NSContainsPredicateOperatorType:
			value02 = @"contains";
			break;
		case NSBeginsWithPredicateOperatorType:
			value02 = @"begins with";
			break;
		case NSEndsWithPredicateOperatorType:
			value02 = @"ends with";
			break;
	}
	id rightConstant = [[predicate rightExpression] constantValue];
	value03 = [self textField];
	[value03 setObjectValue:rightConstant];
	
	id disp = [NSArray arrayWithObjects:leftKeyPath, value02, value03, nil];
	
	return disp;
}
- (NSArray *)ratingDisplayValuesWithPredicate:(NSComparisonPredicate *)predicate
{
	id value02 = nil; id value03 = nil;
	id leftKeyPath = [[predicate leftExpression] keyPath];
	
	switch([predicate predicateOperatorType]) {
		case NSEqualToPredicateOperatorType:
			value02 = @"is";
			break;
		case NSGreaterThanPredicateOperatorType:
			value02 = @"is greater than";
			break;
		case NSLessThanPredicateOperatorType:
			value02 = @"is less than";
			break;
	}
	id rightConstant = [[predicate rightExpression] constantValue];
	value03 = [self ratingIndicator];
	[value03 setObjectValue:rightConstant];
	
	id disp = [NSArray arrayWithObjects:leftKeyPath, value02, value03, nil];
	
	return disp;
}
- (void)resolveVariable:(NSString *)variable value02:(id *)value02 value03:(id *)value03 value04:(id *)value04 value05:(id *)value05 value06:(id *)value06 value07:(id *)value07
{
	NSArray *words = [variable componentsSeparatedByString:@"-"];
	
	switch([words count]) {
		case 2:
			*value02 = @"is in the last";
			*value03 = [self numberField];
			[*value03 setTag:2000];
			[*value03 setStringValue:[words objectAtIndex:0]];
			*value04 = [words objectAtIndex:1];
			break;
		case 3:
			if([[words objectAtIndex:0] isEqualToString:@"not"]) {
				*value02 = @"is not in the last";
				*value03 = [self numberField];
				[*value03 setTag:2000];
				[*value03 setStringValue:[words objectAtIndex:1]];
				*value04 = [words objectAtIndex:2];
			} else {
				*value02 = @"is exactly";
				*value03 = [self numberField];
				[*value03 setTag:2000];
				[*value03 setStringValue:[words objectAtIndex:0]];
				*value04 = [words objectAtIndex:1];
				*value05 = @"ago";
			}
			break;
		case 4:
			*value02 = @"is between";
			*value03 = [self numberField];
			[*value03 setTag:2000];
			[*value03 setStringValue:[words objectAtIndex:0]];
			*value04 = @"and";
			*value05 = [self numberField];
			[*value05 setTag:2100];
			[*value05 setStringValue:[words objectAtIndex:2]];
			*value06 = [words objectAtIndex:3];
			*value07 = @"ago";
			break;
	}
}
- (void)resolveFunctionExpression:(NSExpression *)rightExp value02:(id *)value02 value03:(id *)value03 value04:(id *)value04 value05:(id *)value05 value06:(id *)value06 value07:(id *)value07
{
	NSString *function = [rightExp function];
	
	if([function isEqualToString:@"rangeOfToday"]) {
		*value02 = @"is today";
	} else if([function isEqualToString:@"rangeOfYesterday"]) {
		*value02 = @"is yesterday";
	} else if([function isEqualToString:@"rangeOfThisWeek"]) {
		*value02 = @"is this week";
	} else if([function isEqualToString:@"rangeOfLastWeek"]) {
		*value02 = @"is last week";
	}
}

- (void)rangeDateDisplayValuesWithExpression:(NSExpression *)rightExp value02:(id *)value02 value03:(id *)value03 value04:(id *)value04 value05:(id *)value05
{
	NSExpression *firstExp = [[rightExp collection] objectAtIndex:0];
	NSExpression *secondExp = [[rightExp collection] objectAtIndex:1];
	
	*value02 = @"is in the range";
	*value03 = [self datePicker];
	[*value03 setObjectValue:[firstExp constantValue]];
	*value04 = @"to";
	*value05 = [self datePicker];
	[*value05 setObjectValue:[secondExp constantValue]];
	[*value05 setTag:1000];
}

- (NSArray *)dateRangeDisplayValuesWithPredicate:(NSComparisonPredicate *)predicate
{
	id leftKeyPath = [[predicate leftExpression] keyPath];
	
	id value02 = nil;
	id value03 = nil;
	id value04 = nil;
	id value05 = nil;
	id value06 = nil;
	id value07 = nil;
	
	NSExpressionType rightType = [[predicate rightExpression] expressionType];
	if(rightType == NSFunctionExpressionType) {
		[self resolveFunctionExpression:[predicate rightExpression] value02:&value02 value03:&value03 value04:&value04 value05:&value05 value06:&value06 value07:&value07];
	} else if(rightType == NSAggregateExpressionType) {
		[self rangeDateDisplayValuesWithExpression:[predicate rightExpression] value02:&value02 value03:&value03 value04:&value04 value05:&value05];
	} else if(rightType == NSVariableExpressionType) {
		id rightVar = [[predicate rightExpression] variable];
		[self resolveVariable:rightVar value02:&value02 value03:&value03 value04:&value04 value05:&value05 value06:&value06 value07:&value07];
	}
	
	return [NSArray arrayWithObjects:leftKeyPath, value02, value03, value04, value05, value06, value07, nil];
}

- (NSArray *)dateDisplayValuesWithPredicate:(NSComparisonPredicate *)predicate
{
	id value02 = nil; id value03 = nil;
	id leftKeyPath = [[predicate leftExpression] keyPath];
	
	switch([predicate predicateOperatorType]) {
		case NSEqualToPredicateOperatorType:
			value02 = @"is the date";
			break;
		case NSGreaterThanPredicateOperatorType:
			value02 = @"is after the date";
			break;
		case NSLessThanPredicateOperatorType:
			value02 = @"is before the date";
			break;
		case NSBetweenPredicateOperatorType:
			return [self dateRangeDisplayValuesWithPredicate:predicate];
			
	}
	id rightConstant = [[predicate rightExpression] constantValue];
	value03 = [self datePicker];
	[value03 setObjectValue:rightConstant];
	
	id disp = [NSArray arrayWithObjects:leftKeyPath, value02, value03, nil];
	
	return disp;
}

- (id)criterionFromCriteria:(id)criteria withDisplayValues:(NSArray *)displayValues
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSInteger index = 0;
	
	do {
		id displayValue = [displayValues objectAtIndex:index];
		XspfMRule *hitCriterion = nil;
		for(XspfMRule *criterion in criteria) {
			id value = criterion.value;
			if([value isEqualToString:displayValue]) {
				hitCriterion = criterion;
				break;
			}
			
			if(![displayValue isKindOfClass:[NSControl class]]) continue;
			
			Class fieldClass = Nil;
			NSInteger tag = 0;
			if([value hasPrefix:@"textField"]) {
				fieldClass = [NSTextField class];
			} else if([value hasPrefix:@"dateField"]) {
				fieldClass = [NSDatePicker class];
				if(![value isEqualToString:@"dateField"]) { // result == dateField02
					tag = 1000;
				}
			} else if([value hasPrefix:@"rateField"]) {
				fieldClass = [NSLevelIndicator class];
			} else if([value hasPrefix:@"numberField"]) {
				fieldClass = [NSTextField class];
				if([value isEqualToString:@"numberField"]) {
					tag = 2000;
				} else { // result == numberField02
					tag = 2100;
				}
			}
			if(!fieldClass)  continue;
			
			if([displayValue isKindOfClass:fieldClass] && [displayValue tag] == tag) {
				hitCriterion = criterion;
				break;
			}
		}
		
		if(hitCriterion) {
			[result addObject:hitCriterion];
		}
		
		criteria = [hitCriterion valueForKey:@"children"];
		index++;
	} while(criteria && [criteria count] != 0);
	
	return result;
}
- (id)criteriaWithKeyPath:(NSString *)keypath withRowTemplate:(id)rowTemplate
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
- (id)buildRowsFromPredicate:(id)predicate withRowTemplate:(id)rowTemplate
{
	if([predicate isKindOfClass:[NSCompoundPredicate class]]) {
		id subrows = [NSMutableArray array];
		
		id value = nil;
		switch([predicate compoundPredicateType]) {
			case NSNotPredicateType:
				// ?
				break;
			case NSAndPredicateType:
				value = @"All";
				break;
			case NSOrPredicateType:
				value = @"Any";
				break;
		}
		
		NSArray *sub = [predicate subpredicates];
		for(id p in sub) {
			[subrows addObject:[self buildRowsFromPredicate:p withRowTemplate:rowTemplate]];
		}
		
		id criteria = [NSArray arrayWithObjects:value, @"of the following are true", nil];
		id type = [NSNumber numberWithInt:NSRuleEditorRowTypeCompound];
		
		id result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					 criteria, XspfMREDCriteriaKey,
					 criteria, XspfMREDDisplayValuesKey,
					 type, XspfMREDRowTypeKey,
					 subrows, XspfMREDSubrowsKey,
					 nil];
		
		return [NSArray arrayWithObject:result];
	} else if([predicate isKindOfClass:[NSComparisonPredicate class]]) {
		id leftKeyPath = [[predicate leftExpression] keyPath];
		if(!leftKeyPath) return [NSArray array];
		
		NSArray *disp = nil;
		if([leftKeyPath isEqualToString:@"title"]) {		
			disp = [self displayValuesWithPredicate:predicate];
		}
		if([leftKeyPath isEqualToString:@"rating"]) {		
			disp = [self ratingDisplayValuesWithPredicate:predicate];
		}
		if([[NSArray arrayWithObjects:@"lastPlayDate", @"modificationDate", @"creationDate", nil] containsObject:leftKeyPath]) {		
			disp = [self dateDisplayValuesWithPredicate:predicate];
		}
		
		if(disp) {
			NSArray *row = [self criteriaWithKeyPath:leftKeyPath withRowTemplate:rowTemplate];
			id c = [self criterionFromCriteria:row withDisplayValues:disp];
			NSMutableDictionary *criterion = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											  c, XspfMREDCriteriaKey,
											  disp, XspfMREDDisplayValuesKey,
											  [NSNumber numberWithInt:NSRuleEditorRowTypeSimple], XspfMREDRowTypeKey,
											  nil];
			return criterion;
		}
		
	} else if([predicate isKindOfClass:[NSPredicate class]]) {
		NSLog(@"--> %@", predicate);
	} else {
		NSLog(@"???predicate class is %@", NSStringFromClass([predicate class]));
	}
	
	return [NSArray array];
}
@end
