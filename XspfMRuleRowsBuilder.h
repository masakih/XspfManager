//
//  XspfMRuleRowsBuilder.h
//
//  Created by Hori,Masaki on 10/04/22.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XspfMRuleRowTemplate;
@interface XspfMRuleRowsBuilder : NSObject
{
	XspfMRuleRowTemplate *rowTemplate;
	id predicate;
}

@property (retain) XspfMRuleRowTemplate *rowTemplate;

+ (id)builderWithPredicate:(NSPredicate *)predicate;
- (id)initWithPredicate:(NSPredicate *)predicate;

- (void)build;
- (id)rows;
@end
