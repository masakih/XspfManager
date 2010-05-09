//
//  XspfMRuleDisplayValuesBuilder_private.h
//
//  Created by Hori,Masaki on 10/04/22.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMRuleRowsBuilder.h"

@interface XspfMRuleCompoundPredicateRowsBuilder : XspfMRuleRowsBuilder
@end


@interface XspfMRuleComparisonPredicateRowsBuilder : XspfMRuleRowsBuilder
{
	id rowType;
	id displayValues;
	id criteria;
	id subrows;
}
@end

@interface XspfMRuleStringRowsBuilder : XspfMRuleComparisonPredicateRowsBuilder
@end

@interface XspfMRuleNumberRowsBuilder : XspfMRuleComparisonPredicateRowsBuilder
@end
@interface XspfMRuleRatingRowsBuilder : XspfMRuleNumberRowsBuilder
@end
@interface XspfMRuleLabelRowsBuilder : XspfMRuleNumberRowsBuilder
@end

@interface XspfMRuleDateRowsBuilder : XspfMRuleComparisonPredicateRowsBuilder
@end
@interface XspfMRuleConstantDateRowsBuilder : XspfMRuleComparisonPredicateRowsBuilder
@end
@interface XspfMRuleAggregateDateRowsBuilder : XspfMRuleComparisonPredicateRowsBuilder
@end
@interface XspfMRuleFunctionDateRowsBuilder : XspfMRuleComparisonPredicateRowsBuilder
@end

@interface XspfMRuleRowsBuilder (XspfMPrivate)
- (void)setPredicate:(id)predicate;

- (NSArray *)provisionalDisplayValue;
- (void)buildCriteriaWithProvisionalDisplayValue:(id)provisional;
- (void)buildDisplayValuesWithProvisionalDisplayValue:(id)provisionalDisplayValue;
@end

@interface XspfMRuleRowsBuilder (XspfMAbstractMethods)
+ (BOOL)canBuildPredicate:(NSPredicate *)predicate;
- (id)field;

- (NSNumber *)rowType;
- (NSArray *)displayValues;
- (NSArray *)criteria;
- (NSArray *)subrows;

- (id)value01;
- (id)value02;
- (id)value03;
- (id)value04;
- (id)value05;
- (id)value06;
- (id)value07;
@end
