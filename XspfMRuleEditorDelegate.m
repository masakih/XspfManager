//
//  XspfMRuleEditorDelegate.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/28.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorDelegate.h"

#import "XspfMRuleEditorRow.h"

@implementation XspfMRuleEditorDelegate

- (void)awakeFromNib
{
	if(!compound) {
		compound = [[XspfMCompound alloc] init];
	}
	if(!simples) {
		simples = [NSMutableArray array];
		[simples retain];
		
		XspfMStringPredicate *pre;
		pre = [XspfMStringPredicate simpleWithKeyPath:@"title" rightType:0 operator:0];
		[simples addObject:pre];
		pre = [XspfMAbsoluteDatePredicate simpleWithKeyPath:@"lastPlayDate" rightType:0 operator:0];
		[simples addObject:pre];
		pre = [XspfMAbsoluteDatePredicate simpleWithKeyPath:@"modificationDate" rightType:0 operator:0];
		[simples addObject:pre];
		pre = [XspfMAbsoluteDatePredicate simpleWithKeyPath:@"creationDate" rightType:0 operator:0];
		[simples addObject:pre];
	}
}

- (void)showPredicate:(id)predicate
{
	if([predicate isKindOfClass:[NSCompoundPredicate class]]) {
		NSArray *sub = [predicate subpredicates];
		NSLog(@"-> %d(%d)\n|\n-->",[predicate compoundPredicateType], [sub count]);
		for(id p in sub) {
			if([p isKindOfClass:[NSCompoundPredicate class]]) {
				[self showPredicate:p];
			} else if([p isKindOfClass:[NSComparisonPredicate class]]) {
				NSLog(@"--> (Comparision) ope->%d, mod->%d, left->%@, right->%@, SEL->%s, opt->%u",
				[p predicateOperatorType], [p comparisonPredicateModifier],
				[p leftExpression], [p rightExpression],
				[p customSelector], [p options]);
			} else if([p isKindOfClass:[NSPredicate class]]) {
				NSLog(@"--> %@", p);
			} else {
				NSLog(@"predicate class is %@", NSStringFromClass([p class]));
			}
		}
	} else {
		NSLog(@"???predicate class is %@", NSStringFromClass([predicate class]));
	}
}
- (void)setPredicate:(id)predicate
{
	NSLog(@"predicate -> %@", predicate);
//	NSLog(@"Predicate class is %@", [predicate class]);
	
	[self showPredicate:predicate];
}
#pragma mark#### NSRuleEditor Delegate ####
- (NSInteger)ruleEditor:(NSRuleEditor *)editor
numberOfChildrenForCriterion:(id)criterion
			withRowType:(NSRuleEditorRowType)rowType
{
	NSInteger result = 0;
	
	if(rowType == NSRuleEditorRowTypeCompound) {
		result = [compound numberOfChildrenForChild:criterion];
		goto end;
	}
	
	if(!criterion) {
		result = [simples count];
		goto end;
		return result;
	}
	
	for(id s in simples) {
		if([s isMyChild:criterion]) result += [s numberOfChildrenForChild:criterion];
	}
	
end:
//	NSLog(@"numner\tcriterion -> %@, type -> %d, result -> %d", criterion, rowType, result);
	
	return result;
}
- (id)ruleEditor:(NSRuleEditor *)editor
		   child:(NSInteger)index
	forCriterion:(id)criterion
	 withRowType:(NSRuleEditorRowType)rowType
{
	id result = nil;
	
	if(rowType == NSRuleEditorRowTypeCompound) {
		result = [compound childForChild:criterion atIndex:index];
		goto end;
	}
	
	if(!criterion) {
		id s = [simples objectAtIndex:index];
		result = [s childForChild:criterion atIndex:index];
		goto end;
	}
	
	for(id s in simples) {
		if([s isMyChild:criterion]) {
			result = [s childForChild:criterion atIndex:index];
			goto end;
		}
	}
	
end:
//	NSLog(@"child\tindex -> %d, criterion -> %@, type -> %d, result -> %@", index, criterion, rowType, result);
	
	return result;
}
- (id)ruleEditor:(NSRuleEditor *)editor
displayValueForCriterion:(id)criterion
		   inRow:(NSInteger)row
{
	id result = nil;
	
	NSRuleEditorRowType rowType = [editor rowTypeForRow:row];
	if(rowType == NSRuleEditorRowTypeCompound) {
		result = [compound displayValueForChild:criterion];
		goto end;
	}
			
	for(id s in simples) {
		if([s isMyChild:criterion]) {
			result = [s displayValueForChild:criterion];
			goto end;
		}
	}
	
end:
//	NSLog(@"display\tcriterion -> %@, row -> %d, result -> %@", criterion, row, result);
	return result;
}

- (NSDictionary *)ruleEditor:(NSRuleEditor *)editor
  predicatePartsForCriterion:(id)criterion
			withDisplayValue:(id)value
					   inRow:(NSInteger)row
{
	id result = nil;
	
	NSRuleEditorRowType rowType = [editor rowTypeForRow:row];
	if(rowType == NSRuleEditorRowTypeCompound) {
		result = [compound predicateForChild:criterion withDisplayValue:value];
		goto end;
	}
	
	for(id s in simples) {
		if([s isMyChild:criterion]) {
			result = [s predicateForChild:criterion withDisplayValue:value];
			goto end;
		}
	}
	
end:
//	NSLog(@"predicate\tcriterion -> %@, value -> %@, row -> %d, result -> %@", criterion, value, row, result);
	
	return result;
}
@end
