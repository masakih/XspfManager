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
static NSString *XspfMREDCriteriaKey = @"criteria";
static NSString *XspfMREDDisplayValuesKey = @"displayValues";
static NSString *XspfMREDRowTypeKey = @"rowType";
static NSString *XspfMREDSubrowsKey = @"subrows";
static NSString *XspfMREDValueKey = @"value";
static NSString *XspfMREDPredicateRowsKey = @"predicateRows";
static NSString *XspfMREDNameKey = @"name";

static NSString *XspfMStringPredicateIsEqualOperator = @"is";
static NSString *XspfMStringPredicateIsNotEqualOperator = @"is not";
static NSString *XspfMStringPredicateContainsOperator = @"contains";
static NSString *XspfMStringPredicateBeginsWithOperator = @"begins with";
static NSString *XspfMStringPredicateEndsWithOperator = @"ends with";

//static NSString *XspfMAbDatePredicatePicker01 = @"date";
//static NSString *XspfMAbDatePredicatePicker02 = @"beginDate";
//static NSString *XspfMAbDatePredicatePicker03 = @"endDate";
//static NSString *XspfMAbDatePredicateIsEqualOperator = @"is the date";
//static NSString *XspfMAbDatePredicateLessThanOperator = @"is after the date";
//static NSString *XspfMAbDatePredicateGreaterThanOperator = @"is before the date";
//static NSString *XspfMAbDatePredicateBetweenOperator = @"is in the range";
//static NSString *XspfMAbDatePredicateAndField = @"andField";


- (NSExpression *)rangeUnitFromDisplayValues:(NSArray *)displayValues option:(NSNumber *)optionValue
{
	NSInteger option = [optionValue integerValue];
	
	NSString *variable = nil;
	id value02 = [displayValues objectAtIndex:2];
	id value03 = [displayValues objectAtIndex:3];
	id value04 = nil, value05 = nil;
	 switch(option) {
		case 0:
			 variable = [NSString stringWithFormat:@"%d-%@-ago", [value02 intValue], value03];
			 break;
		 case 1:
			 variable = [NSString stringWithFormat:@"%d-%@", [value02 intValue], value03];
			 break;
		 case 2:
			 variable = [NSString stringWithFormat:@"not-%d-%@", [value02 intValue], value03];
			 break;
		 case 3:
			 value04 = [displayValues objectAtIndex:4];
			 value05 = [displayValues objectAtIndex:5];
			 variable = [NSString stringWithFormat:@"%d-%@-%d-%@", [value02 intValue], value03, [value04 intValue], value05];
			 break;
	 }
	
	return [NSExpression expressionForVariable:variable];
}
- (NSExpression *)rangeDateFromDisplayValues:(NSArray *)displayValues
{
	id field01 = nil;
	id field02 = nil;
	
	Class datepickerclass = [NSDatePicker class];
	for(id v in displayValues) {
		if([v isKindOfClass:datepickerclass]) {
			if([v tag] == 0) {
				field01 = v;
			} else {
				field02 = v;
			}
		}
	}
	
	if(!field01 || !field02) return nil;
	
	id value01, value02;
	value01 = [field01 dateValue]; value02 = [field02 dateValue];
	if([value01 compare:value02] == NSOrderedDescending) {
		id t = value02;
		value02 = value01;
		value01 = t;
	}
	
	id expression01, expression02;
	expression01 = [NSExpression expressionForConstantValue:value01];
	expression02 = [NSExpression expressionForConstantValue:value02];
	
	return [NSExpression expressionForAggregate:[NSArray arrayWithObjects:expression01, expression02, nil]];
}
- (NSExpression *)relatedDate:(NSNumber *)typeValue
{
	NSString *variable = nil;
	NSInteger type = [typeValue integerValue];
	switch(type) {
		case 0:
			variable = @"TODAY";
			break;
		case 1:
			variable = @"YESTERDAY";
			break;
		case 2:
			variable = @"THISWEEK";
			break;
		case 3:
			variable = @"LASTWEEK";
			break;
	}
	
	return [NSExpression expressionForVariable:variable];
}
	
- (NSView *)textField
{
	id text = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[text cell] setControlSize:NSSmallControlSize];
	[text setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[text setStringValue:@"1234567890"];
	[text sizeToFit];
	[text setStringValue:@""];
	[text setDelegate:self];
	
	return text;
}
- (NSView *)datePicker
{
	id date = [[[NSDatePicker alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[date cell] setControlSize:NSSmallControlSize];
	[date setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[date setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
	[date setDrawsBackground:YES];
	[date setDateValue:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	[date sizeToFit];
	[date setDelegate:self];
	
	return date;
}
- (NSView *)ratingIndicator
{
	id rate = [[[NSLevelIndicator alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	id cell = [rate cell];
	[cell setControlSize:NSSmallControlSize];
	[rate setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[rate setMinValue:0];
	[rate setMaxValue:5];
	[cell setLevelIndicatorStyle:NSRatingLevelIndicatorStyle];
	[cell setEditable:YES];
	[rate sizeToFit];
	
	return rate;
}
- (NSView *)numberField
{
	id text = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[text cell] setControlSize:NSSmallControlSize];
	[text setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[text setStringValue:@"123"];
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setMinimum:[NSNumber numberWithInt:0]];
	[text setFormatter:formatter];
	[text sizeToFit];
	[text setStringValue:@"1"];
	[text setDelegate:self];
	
	return text;
}


- (NSDictionary *)buildRows:(NSArray *)template
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for(id row in template) {
		id criteria = [row valueForKey:XspfMREDCriteriaKey];
		id name = [row valueForKey:XspfMREDNameKey];
		[result setObject:criteria forKey:name];
	}
	
	return result;
}
- (id)criteriaWithKeyPath:(NSString *)keypath
{
	NSString *key = nil;
	if([keypath isEqualToString:@"title"]) {
		key = @"String";
	} else if([keypath isEqualToString:@"rating"]) {
		key = @"Rate";
	}
	if(key) {
		id row = [rowTemplate valueForKey:key];
		id c = [[[row objectAtIndex:0] mutableCopy] autorelease];
		[c setValue:keypath forKey:XspfMREDValueKey];
		return [NSArray arrayWithObject:c];
	}
	
	if([[NSArray arrayWithObjects:@"lastPlayDate", @"modificationDate", @"creationDate", nil] containsObject:keypath]) {
		id keys = [NSArray arrayWithObjects:@"AbDate", /*@"RlDate",*/ nil];
		id result = [NSMutableArray array];
		for(key in keys) {
			id row = [rowTemplate valueForKey:key];
			id c = [[[row objectAtIndex:0] mutableCopy] autorelease];
			[c setValue:keypath forKey:XspfMREDValueKey];
			[result addObject:c];
		}
		
		return result;
	}
	
	return nil;
}
- (void)awakeFromNib
{
	if(!compound) {
		compound = [[XspfMCompound alloc] init];
	}
	
	rowIDs = [[NSMutableArray array] retain];
	rowFields = [[NSMutableDictionary dictionary] retain];
	
	NSBundle *m = [NSBundle mainBundle];
	NSString *path = [m pathForResource:@"LibraryRowTemplate" ofType:@"plist"];
	NSArray *rowsTemplate = [NSArray arrayWithContentsOfFile:path];
	if(!rowsTemplate) {
		exit(12345);
	}
	
	rowTemplate = [[self buildRows:rowsTemplate] retain];
	
//	NSLog(@"rowTemplate =>\n%@", rowTemplate);
	
	NSMutableArray *newRows = [NSMutableArray array];
	
	id c = [self criteriaWithKeyPath:@"title"];
	if(c) [newRows addObjectsFromArray:c];
	
	for(id keyPath in [NSArray arrayWithObjects:@"lastPlayDate", @"modificationDate", @"creationDate", nil]) {
		c = [self criteriaWithKeyPath:keyPath];
		if(c) [newRows addObjectsFromArray:c];
	}
	
	c = [self criteriaWithKeyPath:@"rating"];
	if(c) [newRows addObjectsFromArray:c];
	
	rows = [newRows retain];
	
	
	
	////
	predicateRows = [[NSMutableArray alloc] init];
	[ruleEditor bind:XspfMREDRowsKey toObject:self withKeyPath:XspfMREDPredicateRowsKey options:nil];
}

- (NSArray *)displayValuesWithPredicate:(NSComparisonPredicate *)predicate
{
	id value02 = nil; id value03 = nil;
	id leftKeyPath = [[predicate leftExpression] keyPath];
	
	switch([predicate predicateOperatorType]) {
		case NSEqualToPredicateOperatorType:
			value02 = XspfMStringPredicateIsEqualOperator;
			break;
		case NSNotEqualToPredicateOperatorType:
			value02 = XspfMStringPredicateIsNotEqualOperator;
			break;
		case NSContainsPredicateOperatorType:
			value02 = XspfMStringPredicateContainsOperator;
			break;
		case NSBeginsWithPredicateOperatorType:
			value02 = XspfMStringPredicateBeginsWithOperator;
			break;
		case NSEndsWithPredicateOperatorType:
			value02 = XspfMStringPredicateEndsWithOperator;
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
			value02 = XspfMStringPredicateIsEqualOperator;
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
	id rightVar = nil;
	if([[predicate rightExpression] expressionType] == NSVariableExpressionType) {
		rightVar = [[predicate rightExpression] variable];
	}
	
	id value02 = nil;
	id value03 = nil;
	id value04 = nil;
	id value05 = nil;
	id value06 = nil;
	id value07 = nil;
	
	if(!rightVar) {
		[self rangeDateDisplayValuesWithExpression:[predicate rightExpression] value02:&value02 value03:&value03 value04:&value04 value05:&value05];
	}
	
	if([rightVar isEqualToString:@"TODAY"]) {
		value02 = @"is today";
	} else if([rightVar isEqualToString:@"YESTERDAY"]) {
		value02 = @"is yesterday";
	} else if([rightVar isEqualToString:@"THISWEEK"]) {
		value02 = @"is this week";
	} else if([rightVar isEqualToString:@"LASTWEEK"]) {
		value02 = @"is last week";
	} else {
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
		id hitCriterion = nil;
		for(id criterion in criteria) {
			id value = [criterion valueForKey:@"value"];
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
		
		criteria = [hitCriterion valueForKey:@"criteria"];
		index++;
	} while(criteria);
	
	return result;
}
			
- (id)buildRowsFromPredicate:(id)predicate
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
			[subrows addObject:[self buildRowsFromPredicate:p]];
		}
		
		id criteria = [NSArray arrayWithObjects:value, @"of the following are true", nil];
		id type = [NSNumber numberWithInt:NSRuleEditorRowTypeCompound];
		
		id result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					 criteria, XspfMREDCriteriaKey,
					 criteria, XspfMREDDisplayValuesKey,
					 type, XspfMREDRowTypeKey,
					 subrows, XspfMREDSubrowsKey,
					 nil];
		
		return result;
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
//			NSLog(@"dispalyValues -> %@", disp);
		}
		
		if(disp) {
			NSArray *row = [self criteriaWithKeyPath:leftKeyPath];
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
- (void)setPredicate:(id)predicate
{
//	NSLog(@"predicate -> (%@) %@", NSStringFromClass([predicate class]), predicate);
	
	id hoge = [self buildRowsFromPredicate:predicate];
	id new = [NSArray arrayWithObject:hoge];
	
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
		result = [rows count];
	} else {
		result = [[criterion valueForKey:XspfMREDCriteriaKey] count];
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
		result = [rows objectAtIndex:index];
	} else {
		result = [[criterion valueForKey:XspfMREDCriteriaKey] objectAtIndex:index];
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
		result = [criterion valueForKey:XspfMREDValueKey];
	}
	
	if([result isEqualToString:@"separator"]) {
		return [NSMenuItem separatorItem];
	}
	
	// create or find field object.
	do {
		Class searchClass = Nil;
		SEL defaultSEL = Nil;
		NSInteger tag = 0;
		
		if([result hasPrefix:@"textField"]) {
			searchClass = [NSTextField class];
			defaultSEL = @selector(textField);
		} else if([result hasPrefix:@"dateField"]) {
			searchClass = [NSDatePicker class];
			defaultSEL = @selector(datePicker);
			if(![result isEqualToString:@"dateField"]) { // result == dateField02
				tag = 1000;
			}
		} else if([result hasPrefix:@"rateField"]) {
			searchClass = [NSLevelIndicator class];
			defaultSEL = @selector(ratingIndicator);
		} else if([result hasPrefix:@"numberField"]) {
			searchClass = [NSTextField class];
			defaultSEL = @selector(numberField);
			if([result isEqualToString:@"numberField"]) {
				tag = 2000;
			} else { // result == numberField02
				tag = 2100;
			}
		}
		if(!searchClass) break;
		
		id displayValues = [editor displayValuesForRow:row];
		id field = nil;
		for(id v in displayValues) {
			if([v isKindOfClass:searchClass] && [v tag] == tag) {
				field = v;
			}
		}
		result = field ? field :[self performSelector:defaultSEL];
		if(tag != 0) [result setTag:tag];
	} while(NO);
	
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
	
	if([criterion valueForKey:@"XspfMIgnoreExpression"])  return nil;
	
	result = [NSMutableDictionary dictionary];
	
	if([criterion valueForKey:@"NSRuleEditorPredicateOperatorType"]) {
		[result setValue:[criterion valueForKey:@"NSRuleEditorPredicateOperatorType"] forKey:@"NSRuleEditorPredicateOperatorType"];
	}
	if([criterion valueForKey:@"NSRuleEditorPredicateOptions"]) {
		[result setValue:[criterion valueForKey:@"NSRuleEditorPredicateOptions"] forKey:@"NSRuleEditorPredicateOptions"];
	}
	if([criterion valueForKey:@"NSRuleEditorPredicateLeftExpression"]) {
		id value = [criterion valueForKey:@"NSRuleEditorPredicateLeftExpression"];
		id exp = nil;
		if([value isEqual:XspfMREDValueKey]) {
			exp = [NSExpression expressionForKeyPath:displayValue];
		} else {
			exp = [NSExpression expressionForKeyPath:[criterion valueForKey:@"NSRuleEditorPredicateLeft"]];
		}
		if(exp) {
			[result setValue:exp forKey:@"NSRuleEditorPredicateLeftExpression"];
		}
	}
	if([criterion valueForKey:@"NSRuleEditorPredicateRightExpression"]) {
		id selector = [criterion valueForKey:@"NSRuleEditorPredicateRightExpression"];
		id exp = nil;
		if(NSSelectorFromString(selector)) {
			exp = [NSExpression expressionForConstantValue:[displayValue performSelector:NSSelectorFromString(selector)]];
		} else {
			exp = [NSExpression expressionForConstantValue:[criterion valueForKey:@"NSRuleEditorPredicateRightExpression"]];
		}
		if(exp) {
			[result setValue:exp forKey:@"NSRuleEditorPredicateRightExpression"];
		}
	}
	if([criterion valueForKey:@"XspfMPredicateRightExpression"]) {
		SEL selector = NSSelectorFromString([criterion valueForKey:@"XspfMPredicateRightExpression"]);
		id arg01 = [criterion valueForKey:@"XspfMRightExpressionArg01"];
		id arg02 = [criterion valueForKey:@"XspfMRightExpressionArg02"];
		
		
		if(arg02 && arg01) {
			if([arg01 isEqual:XspfMREDDisplayValuesKey]) {
				arg01 = [editor displayValuesForRow:row];
			}
			if([arg02 isEqual:XspfMREDDisplayValuesKey]) {
				arg02 = [editor displayValuesForRow:row];
			}
			id r = [self performSelector:selector withObject:arg01 withObject:arg02];
			[result setValue:r forKey:@"NSRuleEditorPredicateRightExpression"];
		} else if(arg01) {
			if([arg01 isEqual:XspfMREDDisplayValuesKey]) {
				arg01 = [editor displayValuesForRow:row];
			}
			id r = [self performSelector:selector withObject:arg01];
			[result setValue:r forKey:@"NSRuleEditorPredicateRightExpression"];
		} else {
			id r = [self performSelector:selector];
			[result setValue:r forKey:@"NSRuleEditorPredicateRightExpression"];
		}
	}
	
//	NSLog(@"predicate\tcriterion -> %@, value -> %@, row -> %d, result -> %@", criterion, displayValue, row, result);
	
	return result;
}
- (void)ruleEditorRowsDidChange:(NSNotification *)notification
{
	//
}

@end
