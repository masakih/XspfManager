//
//  XspfMRuleEditorRow.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/29.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorRow.h"

@implementation XspfMCompound
- (NSInteger)numberOfChildrenForChild:(id)child
{
	if(!child) return 2;
	if([child isEqualToString:@"All"] || [child isEqualToString:@"Any"]) return 1;
	return 0;
}
- (id)childForChild:(id)child atIndex:(NSInteger)index
{
	if(!child) {
		if(index == 0) return @"All";
		if(index == 1) return @"Any";
	}
	return @"of the following are true";
}
- (id)displayValueForChild:(id)child
{
	return child;
}
- (NSDictionary *)predicateForChild:(id)child withDisplayValue:(id)value
{
	NSDictionary *result = nil;
	
	NSUInteger type = 9999;
	if([child isEqualToString:@"All"]) {
		type = NSAndPredicateType;
	} else if([child isEqualToString:@"Any"]) {
		type = NSOrPredicateType;
	}
	if(type <  10) {
		result = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:type]
											 forKey:NSRuleEditorPredicateCompoundType];
	}
	
	return result;
}
@end


@interface XspfMRule (XspfMAccessor)
- (void)setChildren:(NSArray *)newChildren;
- (void)addChild:(XspfMRule *)child;
- (void)setPredicateParts:(NSDictionary *)parts;
- (void)setExpression:(id)expression forKey:(id)key;
- (void)setValue:(NSString *)newValue;
@end

@interface XspfMRule (XspfMExpressionBuilder)
@end

@implementation XspfMRule (XspfMAccessor)
- (void)setChildren:(NSArray *)newChildren
{
	if(!newChildren) newChildren = [NSMutableArray array];
	
	[children autorelease];
	children = [[NSMutableArray alloc] initWithArray:newChildren copyItems:YES];
}
- (void)addChild:(XspfMRule *)child
{
	[children addObject:child];
}
- (void)setPredicateParts:(NSDictionary *)parts
{
	[predicateHints autorelease];
	predicateHints = [parts mutableCopy];
}
- (void)setExpression:(id)expression forKey:(id)key
{
	[predicateHints setObject:expression forKey:key];
}
- (void)setValue:(NSString *)newValue
{
	if([_value isEqualToString:newValue]) return;
	
	[_value autorelease];
	_value = [newValue copy];
}
- (NSString *)value { return _value; }
@end

@implementation XspfMRule
@dynamic value;

- (NSInteger)numberOfChildren
{
	return [children count];
}
- (id)childAtIndex:(NSInteger)index
{
	return [children objectAtIndex:index];
}
- (id)displayValueForRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	return _value;
}
- (NSDictionary *)predicatePartsWithDisplayValue:(id)displayValue forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	id result = [NSMutableDictionary dictionary];
	
	NSRuleEditorRowType rowType = [ruleEditor rowTypeForRow:row];
	if(rowType == NSRuleEditorRowTypeCompound) {
		return predicateHints;
	}
	
	if([predicateHints valueForKey:@"XspfMIgnoreExpression"])  return nil;	
	
	id operatorType = [predicateHints valueForKey:@"NSRuleEditorPredicateOperatorType"];
	id option = [predicateHints valueForKey:@"NSRuleEditorPredicateOptions"];
	id leftExp = [predicateHints valueForKey:@"NSRuleEditorPredicateLeftExpression"];
	id rightExp = [predicateHints valueForKey:@"NSRuleEditorPredicateRightExpression"];
	id customRightExp = [predicateHints valueForKey:@"XspfMPredicateRightExpression"];
	
	if(operatorType) {
		[result setValue:operatorType forKey:NSRuleEditorPredicateOperatorType];
	}
	if(option) {
		[result setValue:option forKey:NSRuleEditorPredicateOptions];
	}
	if(leftExp) {
		id exp = nil;
		if([leftExp isEqual:@"value"]) {
			exp = [NSExpression expressionForKeyPath:displayValue];
		} else {
			exp = [NSExpression expressionForKeyPath:leftExp];
		}
		if(exp) {
			[result setValue:exp forKey:NSRuleEditorPredicateLeftExpression];
		}
	}
	if(rightExp) {
		SEL selector = NSSelectorFromString(rightExp);
		id exp = nil;
		if(selector) {
			exp = [NSExpression expressionForConstantValue:[displayValue performSelector:selector]];
		} else {
			exp = [NSExpression expressionForConstantValue:rightExp];
		}
		if(exp) {
			[result setValue:exp forKey:NSRuleEditorPredicateRightExpression];
		}
	}
	if(customRightExp) {
		SEL selector = NSSelectorFromString(customRightExp);
		id arg01 = [predicateHints valueForKey:@"XspfMRightExpressionArg01"];
		id arg02 = [predicateHints valueForKey:@"XspfMRightExpressionArg02"];
		
		
		if(arg02 && arg01) {
			if([arg01 isEqual:@"displayValues"]) {
				arg01 = [ruleEditor displayValuesForRow:row];
			}
			if([arg02 isEqual:@"displayValues"]) {
				arg02 = [ruleEditor displayValuesForRow:row];
			}
			id r = [self performSelector:selector withObject:arg01 withObject:arg02];
			[result setValue:r forKey:NSRuleEditorPredicateRightExpression];
		} else if(arg01) {
			if([arg01 isEqual:@"displayValues"]) {
				arg01 = [ruleEditor displayValuesForRow:row];
			}
			id r = [self performSelector:selector withObject:arg01];
			[result setValue:r forKey:NSRuleEditorPredicateRightExpression];
		} else {
			id r = [self performSelector:selector];
			[result setValue:r forKey:NSRuleEditorPredicateRightExpression];
		}
	}
	
	if([predicateHints valueForKey:@"XspfMCustomSelector"]) {
		NSString *selName = [predicateHints valueForKey:@"XspfMCustomSelector"];
		id args = nil;
		NSString *argSelName = [predicateHints valueForKey:@"XspfMCustomSelectorArgumentsCteator"];
		if(argSelName) {
			SEL argSel = NSSelectorFromString(argSelName);
			id argSelArg01 = [predicateHints valueForKey:@"XspfMCustomSelectorArgumentsCteatorArg01"];
			if([argSelArg01 isEqual:@"displayValues"]) {
				argSelArg01 = [ruleEditor displayValuesForRow:row];
			}
			id argSelArg02 = [predicateHints valueForKey:@"XspfMCustomSelectorArgumentsCteatorArg02"];
			if([argSelArg02 isEqual:@"displayValues"]) {
				argSelArg02 = [ruleEditor displayValuesForRow:row];
			}
			if(argSelArg02) {
				args = [self performSelector:argSel withObject:argSelArg01 withObject:argSelArg02];
			} else if(argSelArg01) {
				args = [self performSelector:argSel withObject:argSelArg01];
			} else {
				args = [self performSelector:argSel];
			}
		} else {
			id arg01 = [predicateHints valueForKey:@"XspfMCustomSelectorArg01"];
			args = [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:arg01], nil];
		}
		
		id exp03 = [NSExpression expressionForConstantValue:@"DATE_RANGE_CREATOR"];
		id exp02 = [NSExpression expressionForFunction:exp03 selectorName:selName arguments:args];
		[result setValue:exp02 forKey:@"NSRuleEditorPredicateRightExpression"];
	}
	
	//	NSLog(@"predicate\tcriterion -> %@, value -> %@, row -> %d, result -> %@", predicateHints, displayValue, row, result);
	
	return result;
}

- (id)displayValue { return _value; }

- (id)copyWithZone:(NSZone *)zone
{
	XspfMRule *result = [[[self class] allocWithZone:zone] init];
	[result setChildren:children];
	[result setPredicateParts:predicateHints];
	[result setValue:_value];
	
	return result;
}

- (BOOL)isEqual:(id)other
{
	if([super isEqual:other]) return YES;
	if(![other isKindOfClass:[XspfMRule class]]) return NO;
	
	XspfMRule *o = other;
	if(![_value isEqualToString:o->_value]) return NO;
	//	if(![children isEqual:o->children]) return NO;
	//	if(![predicateHints isEqual:o->predicateHints]) return NO;
	
	return YES;
}
- (NSUInteger)hash
{
	return _value ? [_value hash] : [super hash];
}

- (id)description
{
	return [NSString stringWithFormat:@"%@ {\n\t%@ = %@;\n\t%@ = %@;\n\t%@ = %@;}",
			NSStringFromClass([self class]),
			@"value", _value,
			@"hints", predicateHints,
			@"children", children,
			nil];
}
@end

@implementation XspfMRule (XspfMCreation)

- (id)init
{
	[super init];
	
	children = [[NSMutableArray array] retain];
	predicateHints = [[NSMutableDictionary dictionary] retain];
	
	return self;
}

- (id)initWithValue:(NSString *)newValue children:(NSArray *)newChildren predicateHints:(NSDictionary *)parts
{
	[self init];
	
	if([newValue isEqualToString:@"separator"]) {
		[self release];
		return [[XspfMSeparatorRule alloc] initSparetorRule];
	}
	
	NSInteger tag = XspfMDefaultTag;
	XspfMFieldType type = XspfMUnknownType;
	if([newValue hasPrefix:@"textField"]) {
		type = XspfMTextFieldType;
	} else if([newValue hasPrefix:@"dateField"]) {
		type = XspfMDateFieldType;
		if([newValue isEqualToString:@"dateField"]) {
			tag = XspfMPrimaryDateFieldTag;
		} else {
			tag = XspfMSeconraryDateFieldTag;
		}
	} else if([newValue hasPrefix:@"rateField"]) {
		type = XspfMRateFieldType;
	} else if([newValue hasPrefix:@"numberField"]) {
		type = XspfMNumberFieldType;
		if([newValue isEqualToString:@"numberField"]) {
			tag = XspfMPrimaryNumberFieldTag;
		} else {
			tag = XspfMSecondaryNumberFieldTag;
		}
	}
	if(type != XspfMUnknownType) {
		[self release];
		self = [[XspfMFieldRule alloc] initWithFieldType:type tag:tag];
	}
	
	[self setValue:newValue];
	[self setChildren:newChildren];
	[self setPredicateParts:parts];
	
	return self;
}
+ (id)ruleWithValue:(NSString *)newValue children:(NSArray *)newChildren predicateHints:(NSDictionary *)parts
{
	return [[[self alloc] initWithValue:newValue children:newChildren predicateHints:parts] autorelease];
}

+ (NSArray *)compoundRule
{
	id comp = [self ruleWithValue:@"of the following are true" children:nil predicateHints:[NSDictionary dictionary]];
	
	id allExp = [NSNumber numberWithUnsignedInt:NSAndPredicateType];
	id all = [self ruleWithValue:@"All"
						children:[NSArray arrayWithObject:comp]
				  predicateHints:[NSDictionary dictionaryWithObject:allExp forKey:NSRuleEditorPredicateCompoundType]];
	
	id anyExp = [NSNumber numberWithUnsignedInt:NSOrPredicateType];
	id any = [self ruleWithValue:@"Any"
						children:[NSArray arrayWithObject:comp]
				  predicateHints:[NSDictionary dictionaryWithObject:anyExp forKey:NSRuleEditorPredicateCompoundType]];
	
	return [NSArray arrayWithObjects:all, any, nil];
}

- (NSDictionary *)predicateHintsWithPlist:(NSDictionary *)plist
{
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:plist];
	[result removeObjectForKey:@"criteria"];
	[result removeObjectForKey:@"value"];
	
	return result;
}

+ (id)ruleWithPlist:(id)plist
{
	return [[[self alloc] initWithPlist:plist] autorelease];
}
- (id)initWithPlist:(id)plist
{
	if(![plist isKindOfClass:[NSDictionary class]]) {
		[self init];
		[self release];
		return nil;
	}
	
	id pValue = [plist valueForKey:@"value"];
	id criteria = [plist valueForKey:@"criteria"];
	id pChildren = [NSMutableArray array];
	for(id criterion in criteria) {
		id c = [[self class] ruleWithPlist:criterion];
		if(c) [pChildren addObject:c];
	}
	id hints = [self predicateHintsWithPlist:plist];
	
	return [self initWithValue:pValue children:pChildren predicateHints:hints];
}

- (void)dealloc
{
	[children release];
	[predicateHints release];
	[_value release];
	
	[super dealloc];
}

@end

@implementation XspfMRule (XspfMPrivate)

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
@end

@implementation XspfMSeparatorRule
+ (id)separatorRule
{
	return [[[self alloc] initSparetorRule] autorelease];
}
- (id)initSparetorRule
{
	[super init];
	
	return self;
}
- (id)displayValue
{
	return [NSMenuItem separatorItem];
}
- (id)displayValueForRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	return [NSMenuItem separatorItem];
}
- (NSDictionary *)predicatePartsWithDisplayValue:(id)value forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	return nil;
}
@end

@implementation XspfMFieldRule
+ (id)ruleWithFieldType:(XspfMFieldType)aType
{
	return [[[self alloc] initWithFieldType:aType tag:XspfMDefaultTag] autorelease];
}
- (id)initWithFieldType:(XspfMFieldType)aType
{
	return [self initWithFieldType:aType tag:XspfMDefaultTag];
}
+ (id)ruleWithFieldType:(XspfMFieldType)aType tag:(NSInteger)aTag
{
	return [[[self alloc] initWithFieldType:aType tag:aTag] autorelease];
}
- (id)initWithFieldType:(XspfMFieldType)aType tag:(NSInteger)aTag
{
	[super init];
	
	type = aType;
	tag = aTag;
	
	return self;
}
- (id)copyWithZone:(NSZone *)zone
{
	XspfMFieldRule *result = [super copyWithZone:zone];
	result->type = type;
	result->tag = tag;
	
	return result;
}
- (BOOL)isEqual:(id)other
{
	if(![super isEqual:other]) return NO;
	
	XspfMFieldRule *o = other;
	if(tag != o->tag) return NO;
	if(type != o->type) return NO;
	
	return YES;
}

- (Class)fieldClass
{
	Class result = Nil;
	switch(type) {
		case XspfMTextFieldType:
		case XspfMNumberFieldType:
			result = [NSTextField class];
			break;
		case XspfMDateFieldType:
			result = [NSDatePicker class];
			break;
		case XspfMRateFieldType:
			result = [NSLevelIndicator class];
			break;
	}
	return result;
}
- (SEL)fieldCreateSelector
{
	SEL result = Nil;
	switch(type) {
		case XspfMTextFieldType:
			result = @selector(textField);
			break;
		case XspfMNumberFieldType:
			result = @selector(numberField);
			break;
		case XspfMDateFieldType:
			result = @selector(datePicker);
			break;
		case XspfMRateFieldType:
			result = @selector(ratingIndicator);
			break;
	}
	return result;
}
- (id)displayValue
{
	id res = [self performSelector:[self fieldCreateSelector]];
	[res setTag:tag];
	
	return res;
}
- (id)displayValueForRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	id result = nil;
	
	id displayValues = [ruleEditor displayValuesForRow:row];
	Class fieldCalss = [self fieldClass];
	for(id v in displayValues) {
		if([v isKindOfClass:fieldCalss] && [v tag] == tag) {
			result = v;
			break;
		}
	}
	if(!result) result = [self displayValue];
	
	return result;
}
//- (NSDictionary *)predicatePartsWithDisplayValue:(id)value forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
//{
//#warning MUST IMPLEMENT
//	return nil;
//}
@end

@implementation XspfMRule (XspfMExpressionBuilder)
- (NSArray *)twoNumberAndUnitArgs:(NSArray *)displayValues
{
	id value03 = [displayValues objectAtIndex:2];
	id arg01 = [NSNumber numberWithInt:[[value03 objectValue] intValue]];
	
	id value05 = [displayValues objectAtIndex:4];
	id arg02 = [NSNumber numberWithInt:[[value05 objectValue] intValue]];
	
	id value06 = [displayValues objectAtIndex:5];
	id arg03 = nil;
	if([value06 isEqualToString:@"Days"]) {
		arg03 = [NSNumber numberWithInt:0];
	} else if([value06 isEqualToString:@"Weeks"]) {
		arg03 = [NSNumber numberWithInt:1];
	} else if([value06 isEqualToString:@"Months"]) {
		arg03 = [NSNumber numberWithInt:2];
	} else if([value06 isEqualToString:@"Years"]) {
		arg03 = [NSNumber numberWithInt:3];
	}
	
	if([arg01 compare:arg02] == NSOrderedDescending) {
		id t = arg01;
		arg01 = arg02;
		arg02 = t;
	}
	
	return [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:arg01],
			[NSExpression expressionForConstantValue:arg02],
			[NSExpression expressionForConstantValue:arg03],
			nil];
}
- (NSArray *)numberAndUnitArgs:(NSArray *)displayValues
{
	id value03 = [displayValues objectAtIndex:2];
	id arg01 = [NSNumber numberWithInt:[[value03 objectValue] intValue]];
	
	id value04 = [displayValues objectAtIndex:3];
	id arg02 = nil;
	if([value04 isEqualToString:@"Days"]) {
		arg02 = [NSNumber numberWithInt:0];
	} else if([value04 isEqualToString:@"Weeks"]) {
		arg02 = [NSNumber numberWithInt:1];
	} else if([value04 isEqualToString:@"Months"]) {
		arg02 = [NSNumber numberWithInt:2];
	} else if([value04 isEqualToString:@"Years"]) {
		arg02 = [NSNumber numberWithInt:3];
	}
	
	return [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:arg01],
			[NSExpression expressionForConstantValue:arg02], nil];
}
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
			if([v tag] == XspfMPrimaryDateFieldTag) {
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
@end

