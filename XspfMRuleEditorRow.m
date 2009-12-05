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

@interface XspfMKeyValueHolder : NSObject
{
	id key;
	id value;
}
@property (retain) id key;
@property (retain) id value;
+ (id)holderWithValue:(id)value forKey:(id)key;
- (id)initWithValue:(id)value forKey:(id)key;
@end
@implementation XspfMKeyValueHolder
@synthesize key;
@synthesize value;
+ (id)holderWithValue:(id)inValue forKey:(id)inKey
{
	return [[[self alloc] initWithValue:inValue forKey:inKey] autorelease];
}
- (id)initWithValue:(id)inValue forKey:(id)inKey
{
	[super init];
	self.value = inValue;
	self.key = inKey;
	
	return self;
}
- (void)dealloc
{
	self.value = nil;
	self.key = nil;
	[super dealloc];
}

- (NSUInteger)hash
{
	NSLog(@"hash wad called.");
	exit(-1234);
}
- (BOOL)isEqual:(id)object
{
	if([super isEqual:object]) return YES;
	XspfMKeyValueHolder *obj = object;
	if(![self.key isEqual:obj.key]) return NO;
	if(![self.value isEqual:obj.value]) return NO;
	
	return YES;
}
- (id)description
{
	return [NSString stringWithFormat:@"(%@ = %@;)", self.key, self.value];
}
@end


@implementation XspfMSimple
@synthesize keyPath;

- (NSInteger)numberOfChildrenForChild:(id)child {return 0;}
- (id)childForChild:(id)child atIndex:(NSInteger)index {return nil;}
- (id)displayValueForChild:(id)child {return nil;}
- (NSDictionary *)predicateForChild:(id)child withDisplayValue:(id)value {return nil;}
+ (id)simpleWithKeyPath:(NSString *)inKeyPath rightType:(XspfMRightType)type operator:(NSPredicateOperatorType)operator
{
	return [[[self alloc] initWithKeyPath:inKeyPath rightType:type operator:operator] autorelease];
}
- (id)initWithKeyPath:(NSString *)inKeyPath rightType:(XspfMRightType)type operator:(NSPredicateOperatorType)operator
{
	[super init];
	self.keyPath = inKeyPath;
	[self setup];
	
	return self;
}
- (void)dealloc
{
	self.keyPath = nil;
	[super dealloc];
}
- (NSUInteger)hash
{
	return [keyPath hash];
}
- (BOOL)isEqual:(id)object
{
	XspfMSimple *obj = object;
	if([super isEqual:object]) return YES;
	return [self.keyPath isEqualToString:obj.keyPath];
}
- (void)setup {}
- (BOOL)isMyChild:(id)child
{
//	if(!child) return YES;
//	child = [self myChildFromChild:child];
//	return child != nil;
	return YES;
}
- (id)myChildFromChild:(id)child
{
//	XspfMKeyValueHolder *holder = child;
//	if([holder.key isEqual:self]) return holder.value;
//	return nil;
	return child;
}
- (id)childFromMyChild:(id)myChild
{
//	return [XspfMKeyValueHolder holderWithValue:myChild forKey:self];
	return myChild;
}
@end


static NSString *XspfMStringPredicateLeftExpression = @"left";
static NSString *XspfMStringPredicateRightExpression = @"field";
static NSString *XspfMStringPredicateIsEqualOperator = @"is";
static NSString *XspfMStringPredicateIsNotEqualOperator = @"is not";
static NSString *XspfMStringPredicateContainsOperator = @"contains";
static NSString *XspfMStringPredicateBeginsWithOperator = @"begins with";
static NSString *XspfMStringPredicateEndsWithOperator = @"ends with";

@implementation XspfMStringPredicate
@synthesize fieldValue;
- (void)setup
{
	self.fieldValue = @"";
}
- (id)textField
{
	id text = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[text cell] setControlSize:NSSmallControlSize];
	[text setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[text setStringValue:@"0123456"];
	[text sizeToFit];
	[text setStringValue:self.fieldValue];
	[text setDelegate:self];
	
	return text;
}
- (void)controlTextDidChange:(NSNotification *)obj
{
	self.fieldValue = [[obj object] stringValue];
}
- (NSInteger)numberOfChildrenForChild:(id)child
{
	if(!child) return 1;
	
	child = [self myChildFromChild:child];
	if(!child) return 0;
	
	if([child isEqualToString:XspfMStringPredicateLeftExpression]) return 5;
	if([child isEqualToString:XspfMStringPredicateRightExpression]) return 0;
	
	return 1;
}
- (id)childForChild:(id)child atIndex:(NSInteger)index
{
	if(!child) return [self childFromMyChild:XspfMStringPredicateLeftExpression];
	
	child = [self myChildFromChild:child];
	if(!child) return nil;
	
	if([child isEqualToString:XspfMStringPredicateLeftExpression]) {
		switch(index) {
			case 0:
				return [self childFromMyChild:XspfMStringPredicateIsEqualOperator];
			case 1:
				return [self childFromMyChild:XspfMStringPredicateIsNotEqualOperator];
			case 2:
				return [self childFromMyChild:XspfMStringPredicateContainsOperator];
			case 3:
				return [self childFromMyChild:XspfMStringPredicateBeginsWithOperator];
			case 4:
				return [self childFromMyChild:XspfMStringPredicateEndsWithOperator];
		}
	} else {
		return [self childFromMyChild:XspfMStringPredicateRightExpression];
	}
	
	return nil;
}
- (id)displayValueForChild:(id)child
{
	if(!child) return nil;
	child = [self myChildFromChild:child];
	if(!child) return nil;
	
	if([child isEqualToString:XspfMStringPredicateLeftExpression]) {
		if(1) {
			return self.keyPath;
		} else {
			NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:self.keyPath action:Nil keyEquivalent:@""] autorelease];
			return item;
		}
	}
	
	if([child isEqualToString:XspfMStringPredicateRightExpression]) {
		id text = [self textField];
		
		return text;
	}
	
	while(0){
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:child action:Nil keyEquivalent:@""] autorelease];
		return item;
	}
	
	return child;
}
- (NSDictionary *)predicateForChild:(id)child withDisplayValue:(id)value
{
	NSMutableDictionary *result = nil;
	
	child = [self myChildFromChild:child];
	if(!child) return nil;
	
	if([child isEqualToString:XspfMStringPredicateLeftExpression]) {
		id exp = [NSExpression expressionForKeyPath:self.keyPath];
		result = [NSDictionary dictionaryWithObject:exp forKey:NSRuleEditorPredicateLeftExpression];
	} else if([child isEqualToString:XspfMStringPredicateRightExpression]) {
		id exp = [NSExpression expressionForConstantValue:[value stringValue]];
		result = [NSDictionary dictionaryWithObject:exp forKey:NSRuleEditorPredicateRightExpression];
	} else {
		NSPredicateOperatorType type = 9999;
		if([child isEqualToString:XspfMStringPredicateIsEqualOperator]) {
			type = NSEqualToPredicateOperatorType;
		} else if([child isEqualToString:XspfMStringPredicateIsNotEqualOperator]) {
			type = NSNotEqualToPredicateOperatorType;
		} else if([child isEqualToString:XspfMStringPredicateContainsOperator]) {
			type = NSContainsPredicateOperatorType;
		} else if([child isEqualToString:XspfMStringPredicateBeginsWithOperator]) {
			type = NSBeginsWithPredicateOperatorType;
		} else if([child isEqualToString:XspfMStringPredicateEndsWithOperator]) {
			type = NSEndsWithPredicateOperatorType;
		}
		
		if(type < 999) {
			result = [NSDictionary dictionaryWithObjectsAndKeys:
					  [NSNumber numberWithUnsignedInt:type],
					  NSRuleEditorPredicateOperatorType,
					  [NSNumber numberWithInt:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption],
					  NSRuleEditorPredicateOptions,
					  nil];
		}
	}
	
	return result;
}

@end

static NSString *XspfMAbDatePredicateLeftExpression = @"left";
static NSString *XspfMAbDatePredicatePicker01 = @"date";
static NSString *XspfMAbDatePredicatePicker02 = @"beginDate";
static NSString *XspfMAbDatePredicatePicker03 = @"endDate";
static NSString *XspfMAbDatePredicateIsEqualOperator = @"is the date";
static NSString *XspfMAbDatePredicateLessThanOperator = @"is after the date";
static NSString *XspfMAbDatePredicateGreaterThanOperator = @"is before the date";
static NSString *XspfMAbDatePredicateBetweenOperator = @"is in the range";
static NSString *XspfMAbDatePredicateAndField = @"andField";

@implementation XspfMAbsoluteDatePredicate
@synthesize firstValue;
@synthesize secondValue;

- (void)setup
{
	self.firstValue = self.secondValue = [NSDate dateWithTimeIntervalSinceNow:0.0];
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
- (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell
validateProposedDateValue:(NSDate **)proposedDateValue
		  timeInterval:(NSTimeInterval *)proposedTimeInterval
{
	switch([aDatePickerCell tag]) {
		case 1000:
			self.firstValue = [aDatePickerCell dateValue];
			break;
		case 2000:
			self.secondValue = [aDatePickerCell dateValue];
			break;
	}
}

- (NSInteger)numberOfChildrenForChild:(id)child
{
	if(!child) return 1;
	
	child = [self myChildFromChild:child];
	if(!child) return 0;
	
	if([child isEqualToString:XspfMAbDatePredicateLeftExpression]) return 4;
	if([child isEqualToString:XspfMAbDatePredicateBetweenOperator]) return 1;
	if([child isEqualToString:XspfMAbDatePredicatePicker02]) return 1;
	if([child isEqualToString:XspfMAbDatePredicateAndField]) return 1;
	if([child isEqualToString:XspfMAbDatePredicatePicker03]) return 0;
	if([child isEqualToString:XspfMAbDatePredicatePicker01]) return 0;
	
	return 1;
}
- (id)childForChild:(id)child atIndex:(NSInteger)index
{
	if(!child) return [self childFromMyChild:XspfMAbDatePredicateLeftExpression];
	
	child = [self myChildFromChild:child];
	if(!child) return nil;
	
	if([child isEqualToString:XspfMAbDatePredicateLeftExpression]) {
		switch(index) {
			case 0:
				return [self childFromMyChild:XspfMAbDatePredicateIsEqualOperator];
			case 1:
				return [self childFromMyChild:XspfMAbDatePredicateLessThanOperator];
			case 2:
				return [self childFromMyChild:XspfMAbDatePredicateGreaterThanOperator];
			case 3:
				return [self childFromMyChild:XspfMAbDatePredicateBetweenOperator];
		}
	} else if([child isEqualToString:XspfMAbDatePredicateBetweenOperator]) {
		return [self childFromMyChild:XspfMAbDatePredicatePicker02];
	} else if([child isEqualToString:XspfMAbDatePredicatePicker02]) {
		return [self childFromMyChild:XspfMAbDatePredicateAndField];
	} else if([child isEqualToString:XspfMAbDatePredicateAndField]) {
		return [self childFromMyChild:XspfMAbDatePredicatePicker03];
	} else {
		return [self childFromMyChild:XspfMAbDatePredicatePicker01];
	}
	
	return nil;
}
- (id)displayValueForChild:(id)child
{
	if(!child) return nil;
	child = [self myChildFromChild:child];
	if(!child) return nil;
	
	if([child isEqualToString:XspfMAbDatePredicateLeftExpression]) {
		if(1) {
			return self.keyPath;
		} else {
			NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:self.keyPath action:Nil keyEquivalent:@""] autorelease];
			return item;
		}
	}
	
	if([child isEqualToString:XspfMAbDatePredicatePicker01]) {
		id date = [self datePicker];
		[date setTag:1000];
		[date setDateValue:self.firstValue];
		
		return date;
	}
	if([child isEqualToString:XspfMAbDatePredicatePicker02]) {
		id date = [self datePicker];
		[date setTag:1000];
		[date setDateValue:self.firstValue];
		
		return date;
	}
	if([child isEqualToString:XspfMAbDatePredicatePicker03]) {
		id date = [self datePicker];
		[date setTag:2000];
		[date setDateValue:self.secondValue];
		
		return date;
	}
	if([child isEqualToString:XspfMAbDatePredicateAndField]) {
		return @"to";
	}
	
	while(0){
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:child action:Nil keyEquivalent:@""] autorelease];
		return item;
	}
	
	return child;
}
@end
