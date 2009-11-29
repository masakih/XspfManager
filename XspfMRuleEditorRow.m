//
//  XspfMRuleEditorRow.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/29.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorRow.h"

@implementation XspfMCompound
- (NSInteger)numberOfChildrenForChild:(id)child
{
	if(!child) return 2;
	if([child isEqualToString:@"All"] || [child isEqualToString:@"Any"]) return 1;
	return 0;
}
- (id)childForChild:(id)child atIndex:(NSInteger)index
{
	if(!child) {
		if(index == 0) return @"All";
		if(index == 1) return @"Any";
	}
	return @"of the following are true";
}
- (id)displayValueForChild:(id)child
{
	return child;
}
@end

@interface XspfMKeyValueHolder : NSObject
{
	id key;
	id value;
}
@property (retain) id key;
@property (retain) id value;
+ (id)holderWithValue:(id)value forKey:(id)key;
- (id)initWithValue:(id)value forKey:(id)key;
@end
@implementation XspfMKeyValueHolder
@synthesize key;
@synthesize value;
+ (id)holderWithValue:(id)inValue forKey:(id)inKey
{
	return [[[self alloc] initWithValue:inValue forKey:inKey] autorelease];
}
- (id)initWithValue:(id)inValue forKey:(id)inKey
{
	[super init];
	self.value = inValue;
	self.key = inKey;
	
	return self;
}
- (void)dealloc
{
	self.value = nil;
	self.key = nil;
	[super dealloc];
}

- (NSUInteger)hash
{
	NSLog(@"hash wad called.");
	exit(-1234);
}
- (BOOL)isEqual:(id)object
{
	if([super isEqual:object]) return YES;
	XspfMKeyValueHolder *obj = object;
	if(![self.key isEqual:obj.key]) return NO;
	if(![self.value isEqual:obj.value]) return NO;
	
	return YES;
}
- (id)description
{
	return [NSString stringWithFormat:@"(%@ = %@;)", self.key, self.value];
}
@end


@implementation XspfMSimple
@synthesize keyPath;

- (NSInteger)numberOfChildrenForChild:(id)child {return 0;}
- (id)childForChild:(id)child atIndex:(NSInteger)index {return nil;}
- (id)displayValueForChild:(id)child {return nil;}

+ (id)simpleWithKeyPath:(NSString *)inKeyPath rightType:(XspfMRightType)type operator:(NSPredicateOperatorType)operator
{
	return [[[self alloc] initWithKeyPath:inKeyPath rightType:type operator:operator] autorelease];
}
- (id)initWithKeyPath:(NSString *)inKeyPath rightType:(XspfMRightType)type operator:(NSPredicateOperatorType)operator
{
	[super init];
	self.keyPath = inKeyPath;
	
	return self;
}
- (void)dealloc
{
	self.keyPath = nil;
	[super dealloc];
}
- (NSUInteger)hash
{
	return [keyPath hash];
}
- (BOOL)isEqual:(id)object
{
	XspfMSimple *obj = object;
	if([super isEqual:object]) return YES;
	return [self.keyPath isEqualToString:obj.keyPath];
}
- (BOOL)isMyChild:(id)child
{
	if(!child) return YES;
	child = [self myChildFromChild:child];
	return child != nil;
}
- (id)myChildFromChild:(id)child
{
	XspfMKeyValueHolder *holder = child;
//	if(holder.key == self) return holder.value;
	if([holder.key isEqual:self]) return holder.value;
	return nil;
}
- (id)childFromMyChild:(id)myChild
{
	return [XspfMKeyValueHolder holderWithValue:myChild forKey:self];
}
@end


@implementation XspfMStringPredicate

- (NSInteger)numberOfChildrenForChild:(id)child
{
	if(!child) return 1;
	
	child = [self myChildFromChild:child];
	if(!child) return 0;
	
	if([child isEqualToString:@"left"]) return 5;
	if([child isEqualToString:@"field"]) return 0;
	
	return 1;
}
- (id)childForChild:(id)child atIndex:(NSInteger)index
{
	if(!child) return [self childFromMyChild:@"left"];
	
	child = [self myChildFromChild:child];
	if(!child) return nil;
	
	if([child isEqualToString:@"left"]) {
		switch(index) {
			case 0:
				return [self childFromMyChild:@"is"];
			case 1:
				return [self childFromMyChild:@"is not"];
			case 2:
				return [self childFromMyChild:@"contains"];
			case 3:
				return [self childFromMyChild:@"begins with"];
			case 4:
				return [self childFromMyChild:@"ends with"];
		}
	} else {
		return [self childFromMyChild:@"field"];
	}
	
	return nil;
}
- (id)displayValueForChild:(id)child
{
	if(!child) return nil;
	child = [self myChildFromChild:child];
	if(!child) return nil;
	
	if([child isEqualToString:@"left"]) {
		if(1) {
			return self.keyPath;
		} else {
			NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:self.keyPath action:Nil keyEquivalent:@""] autorelease];
			return item;
		}
	}
	
	if([child isEqualToString:@"field"]) {
		id text = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
		[[text cell] setControlSize:NSSmallControlSize];
		[text setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
		[text setStringValue:@"0123456"];
		[text sizeToFit];
		[text setStringValue:@""];
		
		return text;
	}
	
	while(0){
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:child action:Nil keyEquivalent:@""] autorelease];
		return item;
	}
	
	return child;
}
@end

@implementation XspfMAbsoluteDatePredicate
- (NSView *)datePicker
{
	id date = [[[NSDatePicker alloc] initWithFrame:NSMakeRect(0,0,100,19)] autorelease];
	[[date cell] setControlSize:NSSmallControlSize];
	[date setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[date setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
	[date setDrawsBackground:YES];
	[date setDateValue:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	[date sizeToFit];
	
	return date;
}
- (NSInteger)numberOfChildrenForChild:(id)child
{
	if(!child) return 1;
	
	child = [self myChildFromChild:child];
	if(!child) return 0;
	
	if([child isEqualToString:@"left"]) return 5;
	if([child isEqualToString:@"between"]) return 1;
	if([child isEqualToString:@"beginDate"]) return 1;
	if([child isEqualToString:@"andField"]) return 1;
	if([child isEqualToString:@"endDate"]) return 0;
	if([child isEqualToString:@"date"]) return 0;
	
	return 1;
}
- (id)childForChild:(id)child atIndex:(NSInteger)index
{
	if(!child) return [self childFromMyChild:@"left"];
	
	child = [self myChildFromChild:child];
	if(!child) return nil;
	
	if([child isEqualToString:@"left"]) {
		switch(index) {
			case 0:
				return [self childFromMyChild:@"is"];
			case 1:
				return [self childFromMyChild:@"is not"];
			case 2:
				return [self childFromMyChild:@"is less than"];
			case 3:
				return [self childFromMyChild:@"is greater than"];
			case 4:
				return [self childFromMyChild:@"between"];
		}
	} else if([child isEqualToString:@"between"]) {
		return [self childFromMyChild:@"beginDate"];
	} else if([child isEqualToString:@"beginDate"]) {
		return [self childFromMyChild:@"andField"];
	} else if([child isEqualToString:@"andField"]) {
		return [self childFromMyChild:@"endDate"];
	} else {
		return [self childFromMyChild:@"date"];
	}
	
	return nil;
}
- (id)displayValueForChild:(id)child
{
	if(!child) return nil;
	child = [self myChildFromChild:child];
	if(!child) return nil;
	
	if([child isEqualToString:@"left"]) {
		if(1) {
			return self.keyPath;
		} else {
			NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:self.keyPath action:Nil keyEquivalent:@""] autorelease];
			return item;
		}
	}
	
	if([child isEqualToString:@"date"]) {
		id date = [self datePicker];
		
		return date;
	}
	if([child isEqualToString:@"beginDate"]) {
		id date = [self datePicker];
		
		return date;
	}
	if([child isEqualToString:@"endDate"]) {
		id date = [self datePicker];
		
		return date;
	}
	if([child isEqualToString:@"andField"]) {
		return @"and";
	}
	
	while(0){
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:child action:Nil keyEquivalent:@""] autorelease];
		return item;
	}
	
	return child;
}
@end
