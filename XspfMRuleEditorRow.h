//
//  XspfMRuleEditorRow.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/29.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMRule : NSObject
{
	@private
	NSMutableArray *children;
	NSMutableDictionary *predicateHints;
	NSString *value;
}

@property (copy) NSString *value;

- (NSInteger)numberOfChildren;
- (id)childAtIndex:(NSInteger)index;
- (id)displayValueForRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row;
- (NSDictionary *)predicatePartsWithDisplayValue:(id)value forRuleEditor:(NSRuleEditor *)ruleEditor inRow:(NSInteger)row;
@end


@interface XspfMRule (XspfMCreation)
+ (id)ruleWithPlist:(id)plist;
- (id)initWithPlist:(id)plist;

+ (NSArray *)compoundRule;
@end

@interface XspfMSeparatorRule : XspfMRule
+ (id)separatorRule;
@end

typedef enum {
	XspfMUnknownType = 0,
	XspfMTextFieldType = 1,
	XspfMNumberFieldType,
	XspfMDateFieldType,
	XspfMRateFieldType,
} XspfMFieldType;

@interface XspfMFieldRule : XspfMRule
{
	XspfMFieldType type;
	NSInteger tag;
	id field;
}
+ (id)ruleWithFieldType:(XspfMFieldType)type;
- (id)initWithFieldType:(XspfMFieldType)type;
+ (id)ruleWithFieldType:(XspfMFieldType)type tag:(NSInteger)tag;
- (id)initWithFieldType:(XspfMFieldType)type tag:(NSInteger)tag;
@end

