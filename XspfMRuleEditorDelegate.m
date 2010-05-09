//
//  XspfMRuleEditorDelegate.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/28.
//  Copyright 2009 masakih. All rights reserved.
//

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
	id new = [builder rows];
	
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
