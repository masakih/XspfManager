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



- (id)uniqueObject
{
	id object = nil;
	unsigned i = 0;
	do {
		object = [NSNumber numberWithUnsignedInt:i++];
	} while([rowIDs containsObject:object]);
	
	return object;
}
- (NSView *)fieldForName:(NSString *)name inRow:(NSInteger)row
{
	// throw exception.
	id rowID = [rowIDs objectAtIndex:row];
	
	id fields= [rowFields objectForKey:rowID];
	if(!fields) return nil;
	
	return [fields objectForKey:name];
}
- (void)setField:(NSView *)field forName:(NSString *)name inRow:(NSInteger)row
{
	id rowID = nil;
	if([rowID count] < row) {
		rowID = [self uniqueObject];
	} else {
		rowID = [rowIDs objectAtIndex:row];
	}
	id fields = [rowFields objectForKey:rowID];
	if(!fields) {
		fields = [NSMutableDictionary dictionary];
	}
	[fields setObject:field forKey:name];
}

- (NSInteger)tagAForType:(UInt16)type inRow:(UInt16)row
{
	return type + row << 16;
}
- (UInt16) typeForTag:(NSInteger)tag
{
	return 0x00FF & tag;
}
- (UInt16)rowForTag:(NSInteger)tag
{
	return tag >> 16;
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
	expression01 = [NSExpression expressionForConstantValue:[field01 dateValue]];
	expression02 = [NSExpression expressionForConstantValue:[field02 dateValue]];
	
	return [NSExpression expressionForAggregate:[NSArray arrayWithObjects:expression01, expression02, nil]];
}
		
- (NSView *)textField
{
	id text = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[text cell] setControlSize:NSSmallControlSize];
	[text setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[text setStringValue:@"0123456"];
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
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSArray *)buildRowsFromTemplate:(NSArray *)template
{
	NSMutableArray *result = [NSMutableArray array];
//	for(id row in template) {
//		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//				
//		id criteria = [row valueForKey:@"criteria"];
//		if(criteria && ![criteria isEqual:[NSNull null]]) {
//			criteria = [self buildRowsFromTemplate:criteria];
//		}
//		[dict setValue:criteria forKey:@"criteria"];
//		
//		id value = [row valueForKey:XspfMREDValueKey];
//		if(value) {
//			[dict setValue:value forKey:XspfMREDValueKey];
//		}
//		
//		[result addObject:dict];
//	}
	return template;
	
	return result;
}
- (NSDictionary *)buildRows:(NSArray *)template
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for(id row in template) {
		id criteria = [row valueForKey:XspfMREDCriteriaKey];
//		if(criteria) {
//			criteria = [self buildRowsFromTemplate:criteria];
//		}
		id name = [row valueForKey:XspfMREDNameKey];
		[result setObject:criteria forKey:name];
	}
	
	return result;
}
- (void)awakeFromNib
{
	if(!compound) {
		compound = [[XspfMCompound alloc] init];
	}
//	if(!simples) {
//		simples = [NSMutableArray array];
//		[simples retain];
//		
//		XspfMStringPredicate *pre;
//		pre = [XspfMStringPredicate simpleWithKeyPath:@"title" rightType:0 operator:0];
//		[simples addObject:pre];
//		pre = [XspfMAbsoluteDatePredicate simpleWithKeyPath:@"lastPlayDate" rightType:0 operator:0];
//		[simples addObject:pre];
//		pre = [XspfMAbsoluteDatePredicate simpleWithKeyPath:@"modificationDate" rightType:0 operator:0];
//		[simples addObject:pre];
//		pre = [XspfMAbsoluteDatePredicate simpleWithKeyPath:@"creationDate" rightType:0 operator:0];
//		[simples addObject:pre];
//	}
	
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
	
	id row = [rowTemplate valueForKey:@"String"];
	row = [row mutableCopy];
	id c = [row objectAtIndex:0];
	[c setValue:@"title" forKey:XspfMREDValueKey];
	[newRows addObject:c];
	[row release];
	
	row = [rowTemplate valueForKey:@"AbDate"];
	row = [row mutableCopy];
	c = [row objectAtIndex:0];
	for(id keyPath in [NSArray arrayWithObjects:@"lastPlayDate", @"modificationDate", @"creationDate", nil]) {
		c = [c mutableCopy];
		[c setValue:keyPath forKey:XspfMREDValueKey];
		[newRows addObject:c];
		[c release];
	}
	[row release];
	
	row = [rowTemplate valueForKey:@"Rate"];
	row = [row mutableCopy];
	c = [row objectAtIndex:0];
	[c setValue:@"rating" forKey:XspfMREDValueKey];
	[newRows addObject:c];
	[row release];
	
	rows = [newRows retain];
	
	
	
	////
	predicateRows = [[NSMutableArray alloc] init];
	[ruleEditor bind:XspfMREDRowsKey toObject:self withKeyPath:XspfMREDPredicateRowsKey options:nil];
}

- (void)showPredicate:(id)predicate
{
	if([predicate isKindOfClass:[NSCompoundPredicate class]]) {
		NSArray *sub = [predicate subpredicates];
		NSLog(@"-> %d(%d)\n|\n-->",[predicate compoundPredicateType], [sub count]);
		for(id p in sub) {
			[self showPredicate:p];
		}
	} else if([predicate isKindOfClass:[NSComparisonPredicate class]]) {
		NSLog(@"--> (Comparision) ope->%d, mod->%d, left->%@, right->%@, SEL->%s, opt->%u",
			  [predicate predicateOperatorType], [predicate comparisonPredicateModifier],
			  [predicate leftExpression], [predicate rightExpression],
			  [predicate customSelector], [predicate options]);
		
	} else if([predicate isKindOfClass:[NSPredicate class]]) {
		NSLog(@"--> %@", predicate);
	} else {
		NSLog(@"???predicate class is %@", NSStringFromClass([predicate class]));
	}
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
		
#warning MUST IMPLEMENT!!
		NSArray *sub = [predicate subpredicates];
		for(id p in sub) {
			[subrows addObject:[self buildRowsFromPredicate:p]];
		}
		
		id criteria = [NSArray arrayWithObjects:value, @"of the following are true", nil];
		id type = [NSNumber numberWithInt:1];
		
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
		if(![leftKeyPath isEqualToString:@"title"]) return [NSArray array];
		
		id value02 = nil; id value03 = nil; id criteria01;
		
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
		
		id disp = [NSArray arrayWithObjects:@"title", value02, value03, nil];
		id type = [NSNumber numberWithInt:0];
//		id subs = [NSArray array];
		id row = [rowTemplate valueForKey:@"String"];
		row = [[row mutableCopy] autorelease];
		id c = [row objectAtIndex:0];
		[c setValue:@"title" forKey:XspfMREDValueKey];
		
		criteria01 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					  row, XspfMREDCriteriaKey,
					  disp, XspfMREDDisplayValuesKey,
					  type, XspfMREDRowTypeKey,
//					  subs, XspfMREDSubrowsKey,
					  nil];
		
		return criteria01;
		
	} else if([predicate isKindOfClass:[NSPredicate class]]) {
		NSLog(@"--> %@", predicate);
	} else {
		NSLog(@"???predicate class is %@", NSStringFromClass([predicate class]));
	}
	
	return [NSArray array];
}
- (void)setPredicate:(id)predicate
{
	NSLog(@"predicate -> %@", predicate);
//	NSLog(@"Predicate class is %@", [predicate class]);
	
//	NSLog(@"old rows -> %@", predicateRows);
	id hoge = [self buildRowsFromPredicate:predicate];
	id new = [NSArray arrayWithObject:hoge];
//	NSLog(@"new rows -> %@", new);
	
	[self willChangeValueForKey:XspfMREDPredicateRowsKey];
	[predicateRows release];
	predicateRows = [new retain];
	[self didChangeValueForKey:XspfMREDPredicateRowsKey];
	[ruleEditor reloadCriteria];
	
//	[self showPredicate:predicate];
}
- (void)setPredicateRows:(id)p
{
	NSLog(@"new -> %@", p);
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
//		id arg02 = [criterion valueForKey:@"XspfMRightExpressionArg02"];
		
		if(arg01) {
			if([arg01 isEqualToString:XspfMREDDisplayValuesKey]) {
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
