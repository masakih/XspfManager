//
//  XspfMRule_Subclasses.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/19.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRule.h"
#import "XspfMRule_private.h"

#import "XspfMLabelField.h"


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

+ (id)fieldRuleWithValue:(NSString *)value
{
	return [[[self alloc] initWithValue:value] autorelease];
}
- (id)initWithValue:(NSString *)value
{
	XspfMFieldType aType = XspfMUnknownType;
	NSInteger aTag = XspfMDefaultTag;
	
	if([value hasPrefix:@"textField"]) {
		aType = XspfMTextFieldType;
	} else if([value hasPrefix:@"dateField"]) {
		aType = XspfMDateFieldType;
		if([value isEqualToString:@"dateField"]) {
			aTag = XspfMPrimaryDateFieldTag;
		} else {
			aTag = XspfMSeconraryDateFieldTag;
		}
	} else if([value hasPrefix:@"rateField"]) {
		aType = XspfMRateFieldType;
	} else if([value hasPrefix:@"numberField"]) {
		aType = XspfMNumberFieldType;
		if([value isEqualToString:@"numberField"]) {
			aTag = XspfMPrimaryNumberFieldTag;
		} else {
			aTag = XspfMSecondaryNumberFieldTag;
		}
	} else if([value hasPrefix:@"labelField"]) {
		aType = XspfMLabelFieldType;
	}
	
	if(aType == XspfMUnknownType) {
		[super init];
		[self release];
		return nil;
	}
	
	self = [self initWithFieldType:aType tag:aTag];
	[self setValue:value];
	return self;
}

#pragma mark == NSCopying Protocol ==
- (id)copyWithZone:(NSZone *)zone
{
	XspfMFieldRule *result = [super copyWithZone:zone];
	result->type = type;
	result->tag = tag;
	
	return result;
}

#pragma mark == NSCoding Protocol ==
static NSString *const XspfMRuleTagKey = @"XspfMRuleTagKey";
static NSString *const XspfMRuleTypeKey = @"XspfMRuleTypeKey";
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	tag = [decoder decodeIntegerForKey:XspfMRuleTagKey];
	type = [decoder decodeIntegerForKey:XspfMRuleTypeKey];
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeInteger:tag forKey:XspfMRuleTagKey];
	[encoder encodeInteger:type forKey:XspfMRuleTypeKey];
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
		case XspfMLabelFieldType:
			result = [XspfMLabelField class];
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
		case XspfMLabelFieldType:
			result = @selector(labelField);
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
	
	// find same type field in row.
	id displayValues = [ruleEditor displayValuesForRow:row];
	Class fieldCalss = [self fieldClass];
	for(id field in displayValues) {
		if([field isKindOfClass:fieldCalss] && [field tag] == tag) {
			result = field;
			break;
		}
	}
	if(!result) result = [self displayValue];
	
	return result;
}
@end

