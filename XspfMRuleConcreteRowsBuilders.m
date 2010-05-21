//
//  XspfMRuleConcreteRowsBuilders.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/04/22.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2010, masakih
 All rights reserved.
 
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に
 限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含
 めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表
 示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、
 コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、
 明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証
 も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューター
 も、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか
 厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する
 可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用
 サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定
 されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害につい
 て、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2010, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 1, Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.
 3, The names of its contributors may be used to endorse or promote
    products derived from this software without specific prior
    written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL,EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/


#import "XspfMRuleRowsBuilder.h"
#import "XspfMRuleRowsBuilder_private.h"
#import "XspfMRule.h"
#import "XspfMRule_private.h"
#import "XspfMRuleRowTemplate.h"

#import "XspfMLabelField.h"


@implementation XspfMRuleCompoundPredicateRowsBuilder
- (id)initWithPredicate:(NSPredicate *)aPredicate
{
	[super init];
	[self setPredicate:aPredicate];
	
	return self;
}
+ (BOOL)canBuildPredicate:(NSPredicate *)predicate
{
	return [predicate isKindOfClass:[NSCompoundPredicate class]] ? YES : NO;
}
- (void) build {}
- (id)value01
{
	id value01 = nil;
	switch([predicate compoundPredicateType]) {
		case NSAndPredicateType:
			value01 = @"All";
			break;
		case NSOrPredicateType:
			value01 = @"Any";
			break;
		case NSNotPredicateType:
			value01 = @"None";
			break;
		default:
			[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
			break;
	}
	return value01;
}
- (id)value02
{
	return @"of the following are true";
}
- (NSNumber *)rowType
{
	return [NSNumber numberWithInt:NSRuleEditorRowTypeCompound];
}
- (NSArray *)criteria
{
	id compoundType = nil;
	switch([predicate compoundPredicateType]) {
		case NSAndPredicateType:
			compoundType = [NSNumber numberWithUnsignedInt:NSAndPredicateType];
			break;
		case NSOrPredicateType:
			compoundType = [NSNumber numberWithUnsignedInt:NSOrPredicateType];
			break;
		case NSNotPredicateType:
			compoundType = [NSNumber numberWithUnsignedInt:NSNotPredicateType];
			break;
		default:
			[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
			break;
	}
	id criterion02 = [XspfMRule ruleWithValue:[self value02] children:nil predicateHints:[NSDictionary dictionary]];
	id criterion01 = [XspfMRule ruleWithValue:[self value01]
									 children:[NSArray arrayWithObject:criterion02]
							   predicateHints:[NSDictionary dictionaryWithObject:compoundType forKey:NSRuleEditorPredicateCompoundType]];
	return [NSArray arrayWithObjects:criterion01, criterion02, nil];
}
- (NSArray *)subrows
{
	id newSubrows = [NSMutableArray array];
	NSArray *sub = [predicate subpredicates];
	for(id subPredicate in sub) {
		XspfMRuleRowsBuilder *builder = [XspfMRuleRowsBuilder builderWithPredicate:subPredicate];
		builder.rowTemplate = self.rowTemplate;
		[builder build];
		id row = [builder row];
		
		[newSubrows addObject:row];
	}
	return newSubrows;
}
@end

#pragma mark#### XspfMRuleComparisonPredicateRowsBuilder ####
@implementation XspfMRuleComparisonPredicateRowsBuilder
- (id)initWithPredicate:(NSPredicate *)aPredicate
{
	[super init];
	[self setPredicate:aPredicate];
	
	return self;
}
- (void)dealloc
{
	[rowType release];
	[displayValues release];
	[criteria release];
	[subrows release];
	
	[super dealloc];
}
+ (BOOL)canBuildPredicate:(NSPredicate *)predicate
{
	return [predicate isKindOfClass:[NSComparisonPredicate class]] ? YES : NO;
}
- (void)build
{
	id provisionalDisplayValue = [self provisionalDisplayValue];
	[self buildCriteriaWithProvisionalDisplayValue:provisionalDisplayValue];
	[self buildDisplayValuesWithProvisionalDisplayValue:provisionalDisplayValue];
}
- (NSNumber *)rowType
{
	return [NSNumber numberWithInt:NSRuleEditorRowTypeSimple];
}
- (NSArray *)criteria
{
	return criteria;
}
- (NSArray *)displayValues
{
	return displayValues;
}
- (void)buildCriteriaWithProvisionalDisplayValue:(id)provisional
{
	NSMutableArray *result = [NSMutableArray array];
	NSInteger index = 0;
	id allRows = [rowTemplate criteriaForKeyPath:[[predicate leftExpression] keyPath]];
	
	do {
		id displayValue = [provisional objectAtIndex:index];
		XspfMRule *hitCriterion = nil;
		
		// find XspfMRule conformed dispalyValue.
		for(XspfMRule *criterion in allRows) {
			id value = criterion.value;
			if([value isEqualToString:displayValue]) {
				hitCriterion = criterion;
				break;
			}
			
			if(![displayValue isKindOfClass:[NSControl class]]) continue;
			
			Class fieldClass = Nil;
			NSInteger tag = 0;
			if([value isEqualToString:@"textField"]) {
				fieldClass = [NSTextField class];
			} else if([value isEqualToString:@"dateField"]) {
				fieldClass = [NSDatePicker class];
				tag = XspfMPrimaryDateFieldTag;
			} else if([value isEqualToString:@"dateField02"]) {
				fieldClass = [NSDatePicker class];
				tag = XspfMSeconraryDateFieldTag;
			} else if([value isEqualToString:@"rateField"]) {
				fieldClass = [NSLevelIndicator class];
			} else if([value isEqualToString:@"numberField"]) {
				fieldClass = [NSTextField class];
				tag = XspfMPrimaryNumberFieldTag;
			} else if([value isEqualToString:@"numberField02"]) {
				fieldClass = [NSTextField class];
				tag = XspfMSecondaryNumberFieldTag;
			} else if([value hasPrefix:@"labelField"]) {
				fieldClass = [XspfMLabelField class];
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
		
		allRows = [hitCriterion valueForKey:@"children"];
		index++;
	} while(allRows && [allRows count] != 0);
	
	criteria = [result retain];
}
- (void)buildDisplayValuesWithProvisionalDisplayValue:(id)provisionalDisplayValue
{
	id formalDisplayValues = [NSMutableArray array];
	NSInteger i = 0;
	for(id criterion in criteria) {
		id displayValue = [criterion displayValue];
		if([displayValue isKindOfClass:[NSControl class]]) {
			[displayValue setObjectValue:[[provisionalDisplayValue objectAtIndex:i] objectValue]];
		}
		[formalDisplayValues addObject:displayValue];
		i++;
	}
	
	displayValues = [[NSArray arrayWithArray:formalDisplayValues] retain];
}

- (NSArray *)provisionalDisplayValue
{
	return [super displayValues];
}

- (id)value01
{
	return [[predicate leftExpression] keyPath];
}
- (id)value02
{
	id value02 = nil;
	
	switch([predicate predicateOperatorType]) {
		case NSLessThanPredicateOperatorType:
			value02 = @"is less than";
			break;
		case NSGreaterThanPredicateOperatorType:
			value02 = @"is greater than";
			break;
		case NSEqualToPredicateOperatorType:
			value02 = @"is";
			break;
		case NSNotEqualToPredicateOperatorType:
			value02 = @"is not";
			break;
			
		case NSBeginsWithPredicateOperatorType:
			value02 = @"begins with";
			break;
		case NSEndsWithPredicateOperatorType:
			value02 = @"ends with";
			break;
		case NSContainsPredicateOperatorType:
			value02 = @"contains";
			break;
			
		case NSMatchesPredicateOperatorType:
			value02 = @"not contains";
			break;
			
		case NSBetweenPredicateOperatorType:
			value02 = @"between";
			break;
		default:
			[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
			break;
	}
	
	return value02;
}
@end

@implementation XspfMRuleStringRowsBuilder
+ (BOOL)canBuildPredicate:(id)predicate
{
	if(![predicate isKindOfClass:[NSComparisonPredicate class]]) return NO;
	if([XspfMRule isStringKeyPath:[[predicate leftExpression] keyPath]]) return YES;
	
	return NO;
}
- (id)field
{
	return [[XspfMRule functionHost] textField];
}
- (id)value03
{
	id rightConstant = [[predicate rightExpression] constantValue];
	id value03 = [self field];
	
	if([predicate predicateOperatorType] == NSMatchesPredicateOperatorType) {
		NSString *notContainREGPrefix = @"(?:(?!.*";
		NSString *notContainREGSuffix = @").)*";
		if([rightConstant isKindOfClass:[NSString class]] && [rightConstant hasPrefix:notContainREGPrefix] && [rightConstant hasSuffix:notContainREGSuffix]) {
			NSScanner *scanner = [NSScanner scannerWithString:rightConstant];
			[scanner setScanLocation:[notContainREGPrefix length]];
			NSString *strings = nil;
			if([scanner scanUpToString:notContainREGSuffix intoString:&strings]) {
				rightConstant = strings;
			}
		}
	}
	[value03 setObjectValue:rightConstant];
	
	return value03;
}
@end

@implementation XspfMRuleNumberRowsBuilder
+ (BOOL)canBuildPredicate:(id)predicate
{
	if(![predicate isKindOfClass:[NSComparisonPredicate class]]) return NO;	
	if([XspfMRule isNumberKeyPath:[[predicate leftExpression] keyPath]]) return YES;
	
	return NO;
}
- (id)field
{
	return [[XspfMRule functionHost] numberField];
}
- (id)value03
{
	id value;
	if([predicate predicateOperatorType] != NSBetweenPredicateOperatorType) {
		value = [[predicate rightExpression] constantValue];
	} else {
		value = [[[[predicate rightExpression] constantValue] objectAtIndex:0] constantValue];
	}
	id value03 = [self field];
	[value03 setObjectValue:value];
	[value03 setTag:XspfMPrimaryNumberFieldTag];
	
	return value03;
}
- (id)value04
{
	if([predicate predicateOperatorType] != NSBetweenPredicateOperatorType) return nil;
	
	return @"and";
}
- (id)value05
{
	if([predicate predicateOperatorType] != NSBetweenPredicateOperatorType) return nil;
	
	id value = [[[[predicate rightExpression] constantValue] objectAtIndex:1] constantValue];
	id value05 = [self field];
	[value05 setObjectValue:value];
	[value05 setTag:XspfMSecondaryNumberFieldTag];
	
	return value05;
}
@end

@implementation XspfMRuleRatingRowsBuilder
+ (BOOL)canBuildPredicate:(id)predicate
{
	if(![predicate isKindOfClass:[NSComparisonPredicate class]]) return NO;
	if([XspfMRule isRateKeyPath:[[predicate leftExpression] keyPath]]) return YES;
	
	return NO;
}
- (id)field
{
	return [[XspfMRule functionHost] ratingIndicator];
}
- (id)value03
{
	id value03 = [super value03];
	[value03 setTag:XspfMDefaultTag];
	
	return value03;
}
@end

@implementation XspfMRuleLabelRowsBuilder
+ (BOOL)canBuildPredicate:(id)predicate
{
	if(![predicate isKindOfClass:[NSComparisonPredicate class]]) return NO;
	if([XspfMRule isLabelKeyPath:[[predicate leftExpression] keyPath]]) return YES;
	
	return NO;
}
- (id)field
{
	return [[XspfMRule functionHost] labelField];
}
- (id)value03
{
	id value03 = [super value03];
	[value03 setTag:XspfMDefaultTag];
	
	return value03;
}
@end

@implementation XspfMRuleDateRowsBuilder
- (id)initWithPredicate:(NSPredicate *)aPredicate
{
	[super init];
	[self release];
	
	Class subclasses[] = {
		[XspfMRuleConstantDateRowsBuilder class],
		[XspfMRuleAggregateDateRowsBuilder class],
		[XspfMRuleFunctionDateRowsBuilder class],
		Nil,
	};
	
	NSInteger i = 0;
	while(subclasses[i]) {
		if([subclasses[i] canBuildPredicate:aPredicate]) {
			id obj = [[subclasses[i] alloc] initWithPredicate:aPredicate];
			return obj;
		}
		i++;
	}
	
	NSLog(@"Could not find corresponded concrete class.");
	return nil;
}

+ (BOOL)canBuildPredicate:(id)predicate
{
	if(![predicate isKindOfClass:[NSComparisonPredicate class]]) return NO;
	if([XspfMRule isDateKeyPath:[[predicate leftExpression] keyPath]]) return YES;
	
	return NO;
}
@end

@implementation XspfMRuleConstantDateRowsBuilder
+ (BOOL)canBuildPredicate:(id)predicate
{
	if([[predicate rightExpression] expressionType] == NSConstantValueExpressionType) return YES;
	return NO;
}
- (id)field
{
	return [[XspfMRule functionHost] datePicker];
}
- (id)value02
{
	id value02 = nil;
	switch([predicate predicateOperatorType]) {
		case NSEqualToPredicateOperatorType:
			value02 = @"is the date";
			break;
		case NSNotEqualToPredicateOperatorType:
			value02 = @"is not the date";
			break;
		case NSGreaterThanPredicateOperatorType:
			value02 = @"is after the date";
			break;
		case NSLessThanPredicateOperatorType:
			value02 = @"is before the date";
			break;
		default:
			[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
			break;
	}
	
	return value02;
}
- (id)value03
{
	id rightConstant = [[predicate rightExpression] constantValue];
	id value03 = [self field];
	[value03 setObjectValue:rightConstant];
	[value03 setTag:XspfMPrimaryDateFieldTag];
	
	return value03;
}
@end

@implementation XspfMRuleAggregateDateRowsBuilder
+ (BOOL)canBuildPredicate:(id)predicate
{
	if([[predicate rightExpression] expressionType] == NSAggregateExpressionType) return YES;
	return NO;
}
- (id)field
{
	return [[XspfMRule functionHost] datePicker];
}
- (id)value02
{
	return @"is in the range";
}
- (id)value03
{
	id value03 = [self field];
	[value03 setTag:XspfMPrimaryDateFieldTag];
	[value03 setObjectValue:[[[[predicate rightExpression] collection] objectAtIndex:0] constantValue]];
	
	return value03;
}
- (id)value04
{
	return @"to";
}
- (id)value05
{
	id value05 = [self field];
	[value05 setObjectValue:[[[[predicate rightExpression] collection] objectAtIndex:1] constantValue]];
	[value05 setTag:XspfMSeconraryDateFieldTag];
	
	return value05;
}
@end

@implementation XspfMRuleFunctionDateRowsBuilder
+ (BOOL)canBuildPredicate:(id)predicate
{
	if([[predicate rightExpression] expressionType] == NSFunctionExpressionType) return YES;
	return NO;
}
- (id)field
{
	return [[XspfMRule functionHost] numberField];
}

- (NSString *)displayValueForUnitType:(NSNumber *)unitValue
{
	NSString *result = nil;
	
	switch([unitValue intValue]) {
		case XspfMHoursUnitType:
			result = @"Hours";
			break;
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

- (id)value02
{
	id value02 = nil;
	
	NSExpression *rightExp = [predicate rightExpression];
	NSString *function = [rightExp function];
	
	if([function isEqualToString:@"rangeOfToday"]) {
		value02 = @"is today";
	} else if([function isEqualToString:@"rangeOfYesterday"]) {
		value02 = @"is yesterday";
	} else if([function isEqualToString:@"rangeOfThisWeek"]) {
		value02 = @"is this week";
	} else if([function isEqualToString:@"rangeOfLastWeek"]) {
		value02 = @"is last week";
	} else if([function isEqualToString:@"dateRangeByNumber:unit:"]) {
		value02 = @"is exactly";
	} else if([function isEqualToString:@"dateByNumber:unit:"]) {
		switch([predicate predicateOperatorType]) {
			case NSGreaterThanOrEqualToPredicateOperatorType:
				value02 = @"is in the last";
				break;
			case NSLessThanPredicateOperatorType:
				value02 = @"is not in the last";
				break;
			default:
				[NSException raise:@"XspfMUnknownPredicateType" format:@"XpsfM: unknown predicate type."];
				break;
		}
	} else if([function isEqualToString:@"rangeDateByNumber:toNumber:unit:"]) {
		value02 = @"is between";
		
	}
	
	return value02;
}
- (id)value03
{
	id value03 = nil;
	NSExpression *rightExp = [predicate rightExpression];
	NSString *function = [rightExp function];
	
	if([function isEqualToString:@"dateRangeByNumber:unit:"]) {
		value03 = [self field];
		[value03 setTag:XspfMPrimaryNumberFieldTag];
		[value03 setObjectValue:[[[rightExp arguments] objectAtIndex:0] constantValue]];
	} else if([function isEqualToString:@"dateByNumber:unit:"]) {
		value03 = [self field];
		[value03 setTag:XspfMPrimaryNumberFieldTag];
		[value03 setObjectValue:[[[rightExp arguments] objectAtIndex:0] constantValue]];
	} else if([function isEqualToString:@"rangeDateByNumber:toNumber:unit:"]) {
		value03 = [self field];
		[value03 setTag:XspfMPrimaryNumberFieldTag];
		[value03 setObjectValue:[[[rightExp arguments] objectAtIndex:0] constantValue]];
	}
	
	return value03;
}
- (id)value04
{
	id value04 = nil;
	
	NSExpression *rightExp = [predicate rightExpression];
	NSString *function = [rightExp function];
	
	if([function isEqualToString:@"dateRangeByNumber:unit:"]) {
		id unitValue = [[[rightExp arguments] objectAtIndex:1] constantValue];
		value04 = [self displayValueForUnitType:unitValue];
	} else if([function isEqualToString:@"dateByNumber:unit:"]) {
		id unitValue = [[[rightExp arguments] objectAtIndex:1] constantValue];
		value04 = [self displayValueForUnitType:unitValue];
	} else if([function isEqualToString:@"rangeDateByNumber:toNumber:unit:"]) {
		value04 = @"and";
	}
	
	return value04;
}
- (id)value05
{
	id value05 = nil;
	
	NSExpression *rightExp = [predicate rightExpression];
	NSString *function = [rightExp function];
	
	if([function isEqualToString:@"dateRangeByNumber:unit:"]) {
		value05 = @"ago";
	} else if([function isEqualToString:@"rangeDateByNumber:toNumber:unit:"]) {
		value05 = [self field];
		[value05 setTag:XspfMSecondaryNumberFieldTag];
		[value05 setObjectValue:[[[rightExp arguments] objectAtIndex:1] constantValue]];
	}
	
	return value05;
}
- (id)value06
{
	id value06 = nil;
	
	NSExpression *rightExp = [predicate rightExpression];
	NSString *function = [rightExp function];
	
	if([function isEqualToString:@"rangeDateByNumber:toNumber:unit:"]) {
		id unitValue = [[[rightExp arguments] objectAtIndex:2] constantValue];
		value06 = [self displayValueForUnitType:unitValue];
	}
	
	return value06;
}
- (id)value07
{
	id value07 = nil;
	
	NSExpression *rightExp = [predicate rightExpression];
	NSString *function = [rightExp function];
	
	if([function isEqualToString:@"rangeDateByNumber:toNumber:unit:"]) {
		value07 = @"ago";
	}
	
	return value07;
}

@end
