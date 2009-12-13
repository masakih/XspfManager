//
//  XspfMRuleEditorRow.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/29.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorRow.h"

@interface XspfMRule (XspfMAccessor)
- (void)setChildren:(NSArray *)newChildren;
- (void)addChild:(XspfMRule *)child;
- (void)setPredicateParts:(NSDictionary *)parts;
- (void)setExpression:(id)expression forKey:(id)key;
- (void)setValue:(NSString *)newValue;
@end

@implementation XspfMRule (XspfMAccessor)
- (void)setChildren:(NSArray *)newChildren
{
	if(!newChildren) newChildren = [NSArray array];
	
	[children autorelease];
	children = [newChildren mutableCopy];
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
	if([value isEqualToString:newValue]) return;
	
	[value autorelease];
	value = [newValue copy];
}
- (NSString *)value { return value; }
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
	return value;
}
- (NSDictionary *)predicatePartsWithDisplayValue:(id)value forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
#warning MUST IMPLEMENT
	return predicateHints;
}

- (BOOL)isEqual:(id)other
{
	if([super isEqual:other]) return YES;
	if(![other isKindOfClass:[XspfMRule class]]) return NO;
	
	XspfMRule *o = other;
	if(![value isEqualToString:o->value]) return NO;
//	if(![children isEqual:o->children]) return NO;
//	if(![predicateHints isEqual:o->predicateHints]) return NO;
	
	return YES;
}

- (id)description
{
	return [NSString stringWithFormat:@"%@ {\n%@ = %@,\n%@ = %@,\n%@ = %@,}",
			NSStringFromClass([self class]),
			@"value", value,
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
	
	NSInteger tag = 0;
	XspfMFieldType type = XspfMUnknownType;
	if([newValue hasPrefix:@"textField"]) {
		type = XspfMTextFieldType;
	} else if([newValue hasPrefix:@"dateField"]) {
		type = XspfMDateFieldType;
		if([newValue isEqualToString:@"dateField"]) {
			tag = 0;
		} else {
			tag = 1000;
		}
	} else if([newValue hasPrefix:@"rateField"]) {
		type = XspfMRateFieldType;
	} else if([newValue hasPrefix:@"numberField"]) {
		if([newValue isEqualToString:@"numberField"]) {
			tag = 2000;
		} else {
			tag = 2100;
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
	id comp = [self ruleWithValue:@"of the following are true" children:nil predicateHints:nil];
	[comp setPredicateParts:[NSDictionary dictionary]];
	
	id allExp = [NSNumber numberWithUnsignedInt:NSAndPredicateType];
	id all = [self ruleWithValue:@"All"
						children:[NSArray arrayWithObject:comp]
				  predicateHints:[NSDictionary dictionaryWithObject:allExp forKey:NSRuleEditorPredicateCompoundType]];
	
	id anyExp = [NSNumber numberWithUnsignedInt:NSOrPredicateType];
	id any = [self ruleWithValue:@"All"
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
	[value release];
	
	[super dealloc];
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
	return [[[self alloc] initWithFieldType:aType tag:0] autorelease];
}
- (id)initWithFieldType:(XspfMFieldType)aType
{
	return [self initWithFieldType:aType tag:0];
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

- (id)displayValueForRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
	if(field) return field;
	
	id displayValues = [ruleEditor displayValuesForRow:row];
	Class fieldCalss = [self fieldClass];
	for(id v in displayValues) {
		if([v isKindOfClass:fieldCalss] && [v tag] == tag) {
			field = v;
		}
	}
	if(!field) field = [[self performSelector:[self fieldCreateSelector]] retain];
	[field setTag:tag];
	
	return field;
}
- (NSDictionary *)predicatePartsWithDisplayValue:(id)value forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row
{
#warning MUST IMPLEMENT
	return nil;
}
@end


