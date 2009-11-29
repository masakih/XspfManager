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
		pre = [XspfMAbsoluteDatePredicate simpleWithKeyPath:@"creationDate" rightType:0 operator:0];
		[simples addObject:pre];
	}
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


@end
