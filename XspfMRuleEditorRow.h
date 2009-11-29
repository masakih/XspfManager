//
//  XspfMRuleEditorRow.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/29.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol XspfMPredicate
- (NSInteger)numberOfChildrenForChild:(id)child;
- (id)childForChild:(id)child atIndex:(NSInteger)index;
- (id)displayValueForChild:(id)child;
- (NSDictionary *)predicateForChild:(id)child withDisplayValue:(id)value;
@end

@interface XspfMCompound : NSObject <XspfMPredicate>
@end

typedef NSInteger XspfMRightType;
@interface XspfMSimple : NSObject <XspfMPredicate>
{
	NSRuleEditor *owner;
	NSString *keyPath;
}
@property (copy) NSString *keyPath;

+ (id)simpleWithKeyPath:(NSString *)keyPath rightType:(XspfMRightType)type operator:(NSPredicateOperatorType)operator;
- (id)initWithKeyPath:(NSString *)keyPath rightType:(XspfMRightType)type operator:(NSPredicateOperatorType)operator;

- (void)setOwner:(NSRuleEditor *)editor;

- (BOOL)isMyChild:(id)child;
- (id)myChildFromChild:(id)child;
- (id)childFromMyChild:(id)myChild;
@end

@interface XspfMStringPredicate : XspfMSimple
@end
@interface XspfMNumberPredicate : XspfMSimple
@end
@interface XspfMAbsoluteDatePredicate : XspfMSimple
@end
@interface XspfMRelativeDatePredicate : XspfMSimple
@end
