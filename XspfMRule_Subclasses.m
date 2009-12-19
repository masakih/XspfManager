//
//  XspfMRule_Subclasses.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/19.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorRow.h"
#import "XspfMRule_private.h"


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

