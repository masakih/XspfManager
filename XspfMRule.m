//
//  XspfMRule.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/29.
//

/*
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューターも、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害について、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1, Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3, The names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import "XspfMRule.h"
#import "XspfMRule_private.h"

#import "XspfMLabelField.h"
#import "XspfMLabelCell.h"


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
	
	id operatorType = [predicateHints valueForKey:NSRuleEditorPredicateOperatorType];
	id option = [predicateHints valueForKey:NSRuleEditorPredicateOptions];
	id leftExp = [predicateHints valueForKey:NSRuleEditorPredicateLeftExpression];
	id rightExp = [predicateHints valueForKey:NSRuleEditorPredicateRightExpression];
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
		if([arg01 isEqual:@"displayValues"]) {
			arg01 = [ruleEditor displayValuesForRow:row];
		}
		if([arg02 isEqual:@"displayValues"]) {
			arg02 = [ruleEditor displayValuesForRow:row];
		}
		
		id rhs = nil;
		if(arg02 && arg01) {
			rhs = [self performSelector:selector withObject:arg01 withObject:arg02];
		} else if(arg01) {
			rhs = [self performSelector:selector withObject:arg01];
		} else {
			rhs = [self performSelector:selector];
		}
		if(rhs) {
			[result setValue:rhs forKey:NSRuleEditorPredicateRightExpression];
		}
	}
	
	NSString *selName = [predicateHints valueForKey:@"XspfMCustomSelector"];
	if(selName) {
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
		
		id target = [NSExpression expressionForConstantValue:[[self class] functionHost]];
		id rhs = [NSExpression expressionForFunction:target selectorName:selName arguments:args];
		[result setValue:rhs forKey:NSRuleEditorPredicateRightExpression];
	}
	
	//	HMLog(HMLogLevelDebug, @"predicate\tcriterion -> %@, value -> %@, row -> %d, result -> %@", predicateHints, displayValue, row, result);
	
	return result;
}

- (id)displayValue { return _value; }


#pragma mark#### Variables for add/change criteria of Library. ####
static NSArray *leftKeys = nil;
static NSArray *stringKeys = nil;
static NSArray *dateKeys = nil;
static NSArray *numberKeys = nil;
static NSString *rateingKeyPath = @"rating";
static NSString *labelKeyPath = @"label";
static BOOL useRating = NO;
static BOOL useLabel = NO;

+ (void)registerStringTypeKeyPaths:(NSArray *)keyPaths
{
	if(stringKeys) {
		[stringKeys release];
		[leftKeys release];
		leftKeys = nil;
	}
	stringKeys = [[NSArray arrayWithArray:keyPaths] retain];
}
+ (void)registerDateTypeKeyPaths:(NSArray *)keyPaths
{
	if(dateKeys) {
		[dateKeys release];
		[leftKeys release];
		leftKeys = nil;
	}
	dateKeys = [[NSArray arrayWithArray:keyPaths] retain];
}
+ (void)registerNumberTypeKeyPaths:(NSArray *)keyPaths
{
	if(numberKeys) {
		[numberKeys release];
		[leftKeys release];
		leftKeys = nil;
	}
	numberKeys = [[NSArray arrayWithArray:keyPaths] retain];
}
+ (void)setUseRating:(BOOL)flag
{
	if(flag && useRating || !flag && !useRating) {
		[leftKeys release];
		leftKeys = nil;
	}
	useRating = flag;
}
+ (void)setUseLablel:(BOOL)flag
{
	if(flag && useLabel || !flag && !useLabel) {
		[leftKeys release];
		leftKeys = nil;
	}
	useLabel = flag;
}
+ (void)setLabelKeyPath:(NSString *)keyPath
{
	[labelKeyPath release];
	labelKeyPath = [keyPath copy];
}

+ (NSArray *)leftKeys
{
	if(!leftKeys) {
		
		id temp = [NSMutableArray array];
		[temp addObjectsFromArray:stringKeys];
		[temp addObjectsFromArray:dateKeys];
		[temp addObjectsFromArray:numberKeys];
		if(useRating) {
			[temp addObject:rateingKeyPath];
		}
		if(useLabel) {
			[temp addObject:labelKeyPath];
		}
		leftKeys = [[NSArray arrayWithArray:temp] retain];
	}
	return leftKeys;
}
static inline BOOL isDateKeyPath(NSString *keyPath)
{
	return [dateKeys containsObject:keyPath];
}
+ (BOOL)isDateKeyPath:(NSString *)keyPath
{
	return isDateKeyPath(keyPath);
}
- (BOOL)isDateKeyPath:(NSString *)keyPath
{
	return isDateKeyPath(keyPath);
}
static inline BOOL isStringKeyPath(NSString *keyPath)
{
	return [stringKeys containsObject:keyPath];
}
+ (BOOL)isStringKeyPath:(NSString *)keyPath
{
	return isStringKeyPath(keyPath);
}
- (BOOL)isStringKeyPath:(NSString *)keyPath
{
	return isStringKeyPath(keyPath);
}
static inline BOOL isNumberKeyPath(NSString *keyPath)
{
	return [numberKeys containsObject:keyPath];
}
+ (BOOL)isNumberKeyPath:(NSString *)keyPath
{
	return isNumberKeyPath(keyPath);
}
- (BOOL)isNumberKeyPath:(NSString *)keyPath
{
	return isNumberKeyPath(keyPath);
}
+ (BOOL)isRateKeyPath:(NSString *)keyPath
{
	return [keyPath isEqualToString:rateingKeyPath];
}
- (BOOL)isRateKeyPath:(NSString *)keyPath
{
	return [keyPath isEqualToString:rateingKeyPath];
}
+ (BOOL)isLabelKeyPath:(NSString *)keyPath
{
	return [keyPath isEqualToString:labelKeyPath];
}
- (BOOL)isLabelKeyPath:(NSString *)keyPath
{
	return [keyPath isEqualToString:labelKeyPath];
}

#pragma mark == NSCopying Protocol ==
- (id)copyWithZone:(NSZone *)zone
{
	XspfMRule *result = [[[self class] allocWithZone:zone] init];
	[result setChildren:children];
	[result setPredicateParts:predicateHints];
	[result setValue:_value];
	
	return result;
}

#pragma mark == NSCoding Protocol ==
static NSString *const XspfMRuleChildrenKey = @"XspfMRuleChildrenKey";
static NSString *const XspfMRulePredicateHintsKey = @"XspfMRulePredicateHintsKey";
static NSString *const XspfMRuleValueKey = @"XspfMRuleValueKey";
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [self init];
	
	[self setChildren:[decoder decodeObjectForKey:XspfMRuleChildrenKey]];
	[self setPredicateParts:[decoder decodeObjectForKey:XspfMRulePredicateHintsKey]];
	[self setValue:[decoder decodeObjectForKey:XspfMRuleValueKey]];
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:children forKey:XspfMRuleChildrenKey];
	[encoder encodeObject:predicateHints forKey:XspfMRulePredicateHintsKey];
	[encoder encodeObject:_value forKey:XspfMRuleValueKey];
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
	
	id fieldRule = [XspfMFieldRule fieldRuleWithValue:newValue];
	if(fieldRule) {
		[self release];
		self = [fieldRule retain];
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
	[cell setHighlighted:YES];
	[rate sizeToFit];
	
	[rate setAction:@selector(continuousHighlighted:)];
	[rate setTarget:[[self class] functionHost]];
	
	return rate;
}
- (void)setHighlightRate:(id)rate
{
	[[rate cell] setHighlighted:YES];
}
- (IBAction)continuousHighlighted:(id)sender
{
	[self performSelector:@selector(setHighlightRate:) withObject:sender afterDelay:0.0];
}
- (NSView *)numberField
{
	id text = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[text cell] setControlSize:NSSmallControlSize];
	[text setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[text setStringValue:@"1234"];
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setMinimum:[NSNumber numberWithInt:0]];
	[text setFormatter:formatter];
	[text sizeToFit];
	[text setStringValue:@"1"];
	
	return text;
}
- (NSView *)labelField
{
//	HMLog(HMLogLevelDebug, @"Enter -> %@", NSStringFromSelector(_cmd));
	id label = [[[XspfMLabelField alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[label sizeToFit];
	[label setLabelStyle:XspfMSquareStyle];
	[label setDrawX:YES];
	
	return label;
}
@end
@implementation XspfMRule (XspfMExpressionBuilder)
+ (id)functionHost
{
	static id host = nil;
	if(host) return host;
	@synchronized(self) {
		if(!host) {
			host = [[self alloc] init];
		}
	}
	return host;
}
- (NSArray *)twoNumberAndUnitArgs:(NSArray *)displayValues
{
	id value03 = [displayValues objectAtIndex:2];
	id arg01 = [NSNumber numberWithInt:[[value03 objectValue] intValue]];
	
	id value05 = [displayValues objectAtIndex:4];
	id arg02 = [NSNumber numberWithInt:[[value05 objectValue] intValue]];
	
	id value06 = [displayValues objectAtIndex:5];
	id arg03 = nil;
	if([value06 isEqualToString:@"Hours"]) {
		arg03 = [NSNumber numberWithInt:XspfMHoursUnitType];
	} else if([value06 isEqualToString:@"Days"]) {
		arg03 = [NSNumber numberWithInt:XspfMDaysUnitType];
	} else if([value06 isEqualToString:@"Weeks"]) {
		arg03 = [NSNumber numberWithInt:XpsfMWeeksUnitType];
	} else if([value06 isEqualToString:@"Months"]) {
		arg03 = [NSNumber numberWithInt:XspfMMonthsUnitType];
	} else if([value06 isEqualToString:@"Years"]) {
		arg03 = [NSNumber numberWithInt:XspfMYearsUnitType];
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
	if([value04 isEqualToString:@"Hours"]) {
		arg02 = [NSNumber numberWithInt:XspfMHoursUnitType];
	} else if([value04 isEqualToString:@"Days"]) {
		arg02 = [NSNumber numberWithInt:XspfMDaysUnitType];
	} else if([value04 isEqualToString:@"Weeks"]) {
		arg02 = [NSNumber numberWithInt:XpsfMWeeksUnitType];
	} else if([value04 isEqualToString:@"Months"]) {
		arg02 = [NSNumber numberWithInt:XspfMMonthsUnitType];
	} else if([value04 isEqualToString:@"Years"]) {
		arg02 = [NSNumber numberWithInt:XspfMYearsUnitType];
	}
	
	return [NSArray arrayWithObjects:[NSExpression expressionForConstantValue:arg01],
			[NSExpression expressionForConstantValue:arg02], nil];
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
- (NSExpression *)rangeNumberFromDisplayValues:(NSArray *)displayValues
{
	id field01 = nil;
	id field02 = nil;
	
	Class numberFieldClass = [NSTextField class];
	for(id v in displayValues) {
		if([v isKindOfClass:numberFieldClass]) {
			if([v tag] == XspfMPrimaryNumberFieldTag) {
				field01 = v;
			} else {
				field02 = v;
			}
		}
	}
	
	if(!field01 || !field02) return nil;
	
	NSInteger value01, value02;
	value01 = [field01 integerValue]; value02 = [field02 integerValue];
	if(value01 > value02) {
		NSInteger t = value02;
		value02 = value01;
		value01 = t;
	}
	
	id expression01, expression02;
	expression01 = [NSExpression expressionForConstantValue:[NSNumber numberWithInteger:value01]];
	expression02 = [NSExpression expressionForConstantValue:[NSNumber numberWithInteger:value02]];
	
	return [NSExpression expressionForAggregate:[NSArray arrayWithObjects:expression01, expression02, nil]];
}
@end

