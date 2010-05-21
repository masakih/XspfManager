//
//  XspfMRule_Subclasses.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/19.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2009-2010, masakih
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
 Copyright (c) 2009-2010, masakih
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
		default:
			//
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
		default:
			//
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

