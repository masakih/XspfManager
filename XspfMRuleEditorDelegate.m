//
//  XspfMRuleEditorDelegate.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/28.
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

#import "XspfMRuleEditorDelegate.h"

#import "XspfMRule.h"
#import "XspfMRuleRowsBuilder.h"
#import "XspfMRuleRowTemplate.h"

@implementation XspfMRuleEditorDelegate

static NSString *XspfMREDPredicateRowsKey = @"predicateRows";

+ (void)initialize
{
	static BOOL isFirst = YES;
	if(isFirst) {
		isFirst = NO;
		[XspfMRule registerStringTypeKeyPaths:[NSArray arrayWithObjects:@"title", @"information.voiceActorsList", @"information.productsList", nil]];
		[XspfMRule registerDateTypeKeyPaths:[NSArray arrayWithObjects:@"lastPlayDate", @"modificationDate", @"creationDate", nil]];
		[XspfMRule setUseRating:YES];
		[XspfMRule setUseLablel:YES];
	}
}

- (void)awakeFromNib
{
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *templatePath = [mainBundle pathForResource:@"LibraryRowTemplate" ofType:@"plist"];
	rowTemplate = [[XspfMRuleRowTemplate rowTemplateWithPath:templatePath] retain];
	
	NSMutableArray *newRows = [NSMutableArray array];
	for(id keyPath in [XspfMRule leftKeys]) {
		id c = [rowTemplate criteriaForKeyPath:keyPath];
		if(c) [newRows addObjectsFromArray:c];
	}
	
	simples = [newRows retain];
	compounds = [[XspfMRule compoundRule] retain];
	
	predicateRows = [[NSMutableArray alloc] init];
	[ruleEditor bind:@"rows" toObject:self withKeyPath:XspfMREDPredicateRowsKey options:nil];
}
- (void)dealloc
{
	[ruleEditor unbind:@"rows"];
	[simples release];
	[compounds release];
	[predicateRows release];
	[rowTemplate release];
	
	[super dealloc];
}

- (void)setPredicateRows:(id)p
{
	if([predicateRows isEqual:p]) return;
	
	[predicateRows release];
	predicateRows = [p retain];
}
- (void)setPredicate:(id)predicate
{
	XspfMRuleRowsBuilder *builder = [XspfMRuleRowsBuilder builderWithPredicate:predicate];
	builder.rowTemplate = rowTemplate;
	[builder build];
	id new = [NSMutableArray arrayWithObject:[builder row]];
	
	[self setPredicateRows:new];
}

#pragma mark#### NSRleEditor Delegate ####

- (NSInteger)ruleEditor:(NSRuleEditor *)editor
numberOfChildrenForCriterion:(id)criterion
			withRowType:(NSRuleEditorRowType)rowType
{
	NSInteger result = 0;
	
	if(!criterion) {
		if(rowType == NSRuleEditorRowTypeCompound) {
			result = [compounds count];
		} else {
			result = [simples count];
		}
	} else {
		result = [criterion numberOfChildren];
	}
	
	return result;
}

- (id)ruleEditor:(NSRuleEditor *)editor
		   child:(NSInteger)index
	forCriterion:(id)criterion
	 withRowType:(NSRuleEditorRowType)rowType
{
	id result = nil;
	
	if(!criterion) {
		if(rowType == NSRuleEditorRowTypeCompound) {
			result = [compounds objectAtIndex:index];
		} else {
			result = [simples objectAtIndex:index];
		}
	} else {
		result = [criterion childAtIndex:index];
	}
		
	return result;
}
- (id)ruleEditor:(NSRuleEditor *)editor
displayValueForCriterion:(id)criterion
		   inRow:(NSInteger)row
{
	id result = [criterion displayValueForRuleEditor:editor inRow:row];
	
	return result;
}
- (NSDictionary *)ruleEditor:(NSRuleEditor *)editor
  predicatePartsForCriterion:(id)criterion
			withDisplayValue:(id)displayValue
					   inRow:(NSInteger)row
{
	id result = [criterion predicatePartsWithDisplayValue:displayValue forRuleEditor:editor inRow:row];
	
	return result;
}
- (void)ruleEditorRowsDidChange:(NSNotification *)notification
{
	//
}

#pragma mark---- Debugging ----
- (void)resolveExpression:(id)exp
{
	NSString *message = nil;
	
	switch([exp expressionType]) {
		case NSConstantValueExpressionType:
			message = [NSString stringWithFormat:@"constant -> %@", [exp constantValue]];
			break;
		case NSEvaluatedObjectExpressionType:
			message = [NSString stringWithFormat:@"constant -> %@", [exp constantValue]];
			break;
		case NSVariableExpressionType:
			message = [NSString stringWithFormat:@"variable -> %@", [exp variable]];
			break;
		case NSKeyPathExpressionType:
			message = [NSString stringWithFormat:@"keyPath -> %@", [exp keyPath]];
			break;
		case NSFunctionExpressionType:
			message = [NSString stringWithFormat:@"oprand -> %@(%@), function -> %@, arguments -> %@",
					   [exp operand], NSStringFromClass([[exp operand] class]),
					   [exp function], [exp arguments]];
			break;
		case NSAggregateExpressionType:
			message = [NSString stringWithFormat:@"collection -> %@", [exp collection]];
			break;
	}
	
	fprintf(stderr, "%s\n", [message UTF8String]);
}
- (void)resolvePredicate:(id)predicate
{
	if([predicate isKindOfClass:[NSCompoundPredicate class]]) {
		NSArray *sub = [predicate subpredicates];
		for(id p in sub) {
			[self resolvePredicate:p];
		}
	} else if([predicate isKindOfClass:[NSComparisonPredicate class]]) {
		id left = [predicate leftExpression];
		id right = [predicate rightExpression];
		SEL sel = Nil;
		if([predicate predicateOperatorType] == NSCustomSelectorPredicateOperatorType) {
			sel = [predicate customSelector];
		}
		fprintf(stderr, "left ->\t");
		[self resolveExpression:left];
		if(sel) {
			fprintf(stderr, "%s\n", [[NSString stringWithFormat:@"SEL -> %@", NSStringFromSelector(sel)] UTF8String]);
		} else {
			fprintf(stderr, "%s\n", [[NSString stringWithFormat:@"type -> %d, opt -> %d, mod -> %d", [predicate predicateOperatorType], [predicate options], [predicate comparisonPredicateModifier]] UTF8String]);
		}
		fprintf(stderr, "right ->\t");
		[self resolveExpression:right];
		fprintf(stderr, "end resolve.\n");
	}
}
@end
