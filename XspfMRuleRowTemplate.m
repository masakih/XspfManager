//
//  XspfMRuleRowTemplate.m
//
//  Created by Hori,Masaki on 10/05/04.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMRuleRowTemplate.h"

#import "XspfMRule.h"

@implementation XspfMRuleRowTemplate
+ (id)rowTemplateWithPath:(NSString *)path
{
	return [[[self alloc] initWithPath:path] autorelease];
}
- (id)initWithPath:(NSString *)path
{
	[super init];
	
	NSArray *rowsTemplate = [NSArray arrayWithContentsOfFile:path];
	if(!rowsTemplate) {
		exit(12345);
	}
	
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for(id row in rowsTemplate) {
		id name = [row valueForKey:@"name"];
		id rule = [XspfMRule ruleWithPlist:row];
		[result setObject:rule forKey:name];
	}
	rowTemplate = [result retain];
	
	return self;
}

+ (NSString *)templateKeyForLeftKeyPath:(NSString *)leftKeypath
{
	NSString *key = nil;
	if([XspfMRule isStringKeyPath:leftKeypath]) {
		key = @"String";
	} else if([XspfMRule isNumberKeyPath:leftKeypath]) {
		key = @"Number";
	} else if([XspfMRule isDateKeyPath:leftKeypath]) {
		key = @"AbDate";
	} else if([XspfMRule isRateKeyPath:leftKeypath]) {
		key = @"Rate";
	} else if([XspfMRule isLabelKeyPath:leftKeypath]) {
		key = @"Label";
	}
	
	return key;
}
- (NSString *)templateKeyForLeftKeyPath:(NSString *)leftKeypath
{
	return [[self class] templateKeyForLeftKeyPath:leftKeypath];
}
- (id)criteriaForKeyPath:(NSString *)keyPath
{
	NSString *key = [self templateKeyForLeftKeyPath:keyPath];
	if(key) {
		id row = [rowTemplate valueForKey:key];
		id c = [[[row childAtIndex:0] copy] autorelease];
		if(!c) return nil;
		[c setValue:keyPath];
		return [NSArray arrayWithObject:c];
	}
	
	return nil;
}
@end
