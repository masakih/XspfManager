//
//  XspfMRule_RuleBuilder.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/17.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorRow.h"

#import "XspfMRule_private.h"

static NSString *const XspfMREDCriteriaKey = @"criteria";
static NSString *const XspfMREDDisplayValuesKey = @"displayValues";
static NSString *const XspfMREDRowTypeKey = @"rowType";
static NSString *const XspfMREDSubrowsKey = @"subrows";


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
		default:
			[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
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
		default:
			[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
			break;
	}
	id rightConstant = [[predicate rightExpression] constantValue];
	value03 = [self ratingIndicator];
	[value03 setObjectValue:rightConstant];
	
	id disp = [NSArray arrayWithObjects:leftKeyPath, value02, value03, nil];
	
	return disp;
}
- (NSString *)displayValueForUnitType:(NSNumber *)unitValue
{
	NSString *result = nil;
	
	switch([unitValue intValue]) {
		case XspfMDaysUnitType:
			result = @"Days";
			break;
		case XpsfMWeeksUnitType:
			result = @"Weeks";
			break;
		case XspfMMonthsUnitType:
			result = @"Months";
			break;
		case XspfMYearsUnitType:
			result = @"Years";
			break;
		default:
			[NSException raise:@"XspfMUnknownUnitType" format:@"XpsfM: unknown unit type."];
			break;
	}
	
	return result;
}
	
- (void)resolveFunctionExpression:(NSComparisonPredicate *)predicate value02:(id *)value02 value03:(id *)value03 value04:(id *)value04 value05:(id *)value05 value06:(id *)value06 value07:(id *)value07
{
	NSExpression *rightExp = [predicate rightExpression];
	NSString *function = [rightExp function];
	
	if([function isEqualToString:@"rangeOfToday"]) {
		*value02 = @"is today";
	} else if([function isEqualToString:@"rangeOfYesterday"]) {
		*value02 = @"is yesterday";
	} else if([function isEqualToString:@"rangeOfThisWeek"]) {
		*value02 = @"is this week";
	} else if([function isEqualToString:@"rangeOfLastWeek"]) {
		*value02 = @"is last week";
	} else if([function isEqualToString:@"dateRangeByNumber:unit:"]) {
		*value02 = @"is exactly";
		*value03 = [self numberField];
		[*value03 setTag:XspfMPrimaryNumberFieldTag];
		[*value03 setObjectValue:[[[rightExp arguments] objectAtIndex:0] constantValue]];
		id unitValue = [[[rightExp arguments] objectAtIndex:1] constantValue];
		*value04 = [self displayValueForUnitType:unitValue];
		*value05 = @"ago";
	} else if([function isEqualToString:@"dateByNumber:unit:"]) {
		switch([predicate predicateOperatorType]) {
			case NSGreaterThanOrEqualToPredicateOperatorType:
				*value02 = @"is in the last";
				break;
			case NSLessThanPredicateOperatorType:
				*value02 = @"is not in the last";
				break;
			default:
				[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
				break;
		}
		*value03 = [self numberField];
		[*value03 setTag:XspfMPrimaryNumberFieldTag];
		[*value03 setObjectValue:[[[rightExp arguments] objectAtIndex:0] constantValue]];
		id unitValue = [[[rightExp arguments] objectAtIndex:1] constantValue];
		*value04 = [self displayValueForUnitType:unitValue];
	} else if([function isEqualToString:@"rangeDateByNumber:toNumber:unit:"]) {
		*value02 = @"is between";
		*value03 = [self numberField];
		[*value03 setTag:XspfMPrimaryNumberFieldTag];
		[*value03 setObjectValue:[[[rightExp arguments] objectAtIndex:0] constantValue]];
		*value04 = @"and";
		*value05 = [self numberField];
		[*value05 setTag:XspfMSecondaryNumberFieldTag];
		[*value05 setObjectValue:[[[rightExp arguments] objectAtIndex:1] constantValue]];
		id unitValue = [[[rightExp arguments] objectAtIndex:2] constantValue];
		*value06 = [self displayValueForUnitType:unitValue];
		*value07 = @"ago";
	}
}

- (void)rangeDateDisplayValuesWithExpression:(NSExpression *)rightExp value02:(id *)value02 value03:(id *)value03 value04:(id *)value04 value05:(id *)value05
{
	NSExpression *firstExp = [[rightExp collection] objectAtIndex:0];
	NSExpression *secondExp = [[rightExp collection] objectAtIndex:1];
	
	*value02 = @"is in the range";
	*value03 = [self datePicker];
	[*value03 setTag:XspfMPrimaryDateFieldTag];
	[*value03 setObjectValue:[firstExp constantValue]];
	*value04 = @"to";
	*value05 = [self datePicker];
	[*value05 setObjectValue:[secondExp constantValue]];
	[*value05 setTag:XspfMSeconraryDateFieldTag];
}

- (void)resolveConstant:(NSComparisonPredicate *)predicate value02:(id *)value02 value03:(id *)value03 value04:(id *)value04
{
	switch([predicate predicateOperatorType]) {
		case NSEqualToPredicateOperatorType:
			*value02 = @"is the date";
			break;
		case NSGreaterThanPredicateOperatorType:
			*value02 = @"is after the date";
			break;
		case NSLessThanPredicateOperatorType:
			*value02 = @"is before the date";
			break;
		default:
			[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
			break;
	}
	id rightConstant = [[predicate rightExpression] constantValue];
	*value03 = [self datePicker];
	[*value03 setObjectValue:rightConstant];
	[*value03 setTag:XspfMPrimaryDateFieldTag];
}

- (NSArray *)dateDisplayValuesWithPredicate:(NSComparisonPredicate *)predicate
{
	id value02 = nil;
	id value03 = nil;
	id value04 = nil;
	id value05 = nil;
	id value06 = nil;
	id value07 = nil;
	
	NSExpressionType rightType = [[predicate rightExpression] expressionType];
	if(rightType == NSFunctionExpressionType) {
		[self resolveFunctionExpression:predicate value02:&value02 value03:&value03 value04:&value04 value05:&value05 value06:&value06 value07:&value07];
	} else if(rightType == NSAggregateExpressionType) {
		[self rangeDateDisplayValuesWithExpression:[predicate rightExpression] value02:&value02 value03:&value03 value04:&value04 value05:&value05];
	} else if(rightType == NSConstantValueExpressionType) {
		[self resolveConstant:predicate value02:&value02 value03:&value03 value04:&value04];
	} else {
		[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
	}
	
	id leftKeyPath = [[predicate leftExpression] keyPath];
	
	return [NSArray arrayWithObjects:leftKeyPath, value02, value03, value04, value05, value06, value07, nil];
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
				if([value isEqualToString:@"dateField"]) {
					tag = XspfMPrimaryDateFieldTag;
				} else { // result == dateField02
					tag = XspfMSeconraryDateFieldTag;
				}
			} else if([value hasPrefix:@"rateField"]) {
				fieldClass = [NSLevelIndicator class];
			} else if([value hasPrefix:@"numberField"]) {
				fieldClass = [NSTextField class];
				if([value isEqualToString:@"numberField"]) {
					tag = XspfMPrimaryNumberFieldTag;
				} else { // result == numberField02
					tag = XspfMSecondaryNumberFieldTag;
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
- (BOOL)isDateKeyPath:(NSString *)keyPath
{
	return [[NSArray arrayWithObjects:@"lastPlayDate", @"modificationDate", @"creationDate", nil] containsObject:keyPath];
}
- (id)criteriaWithKeyPath:(NSString *)keypath withRowTemplate:(id)rowTemplate
{
	NSString *key = nil;
	if([keypath isEqualToString:@"title"]) {
		key = @"String";
	} else if([keypath isEqualToString:@"rating"]) {
		key = @"Rate";
	} else if([self isDateKeyPath:keypath]) {
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
		id value = nil;
		id compoundType = nil;
		switch([predicate compoundPredicateType]) {
			case NSAndPredicateType:
				value = @"All";
				compoundType = [NSNumber numberWithUnsignedInt:NSAndPredicateType];
				break;
			case NSOrPredicateType:
				value = @"Any";
				compoundType = [NSNumber numberWithUnsignedInt:NSOrPredicateType];
				break;
			case NSNotPredicateType:
			default:
				[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
				break;
		}
		
		id subrows = [NSMutableArray array];
		NSArray *sub = [predicate subpredicates];
		for(id p in sub) {
			[subrows addObject:[self buildRowsFromPredicate:p withRowTemplate:rowTemplate]];
		}
		
		id value02 = @"of the following are true";
		id criterion02 = [XspfMRule ruleWithValue:value02 children:nil predicateHints:[NSDictionary dictionary]];
		id criterion01 = [XspfMRule ruleWithValue:value
										 children:[NSArray arrayWithObject:criterion02]
								   predicateHints:[NSDictionary dictionaryWithObject:compoundType forKey:NSRuleEditorPredicateCompoundType]];
		NSArray *criteria = [NSArray arrayWithObjects:criterion01, criterion02, nil];
		id displayValues = [NSArray arrayWithObjects:value, value02, nil];
		
		id result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					 criteria, XspfMREDCriteriaKey,
					 displayValues, XspfMREDDisplayValuesKey,
					 [NSNumber numberWithInt:NSRuleEditorRowTypeCompound], XspfMREDRowTypeKey,
					 subrows, XspfMREDSubrowsKey,
					 nil];
		
		return [NSArray arrayWithObject:result];
	} else if([predicate isKindOfClass:[NSComparisonPredicate class]]) {
		id leftKeyPath = [[predicate leftExpression] keyPath];
		if(!leftKeyPath) return [NSArray array];
		
		NSArray *disp = nil;
		if([leftKeyPath isEqualToString:@"title"]) {		
			disp = [self displayValuesWithPredicate:predicate];
		} else if([leftKeyPath isEqualToString:@"rating"]) {		
			disp = [self ratingDisplayValuesWithPredicate:predicate];
		} else if([self isDateKeyPath:leftKeyPath]) {		
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
		
	} else {
		NSLog(@"???predicate class is %@", NSStringFromClass([predicate class]));
	}
	
	return [NSArray array];
}
@end
