//
//  XspfMCheckFileModifiedRequest.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/09.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMCheckFileModifiedRequest.h"


@implementation XspfMCheckFileModifiedRequest
@synthesize object;
@synthesize url;

inline BOOL nilOrNSNull(id obj)
{
	return !obj || obj == [NSNull null];
}

+ (id)requestWithObject:(id)anObject url:(NSURL *)anUrl;
{
	return [[[self alloc] initWithObject:anObject url:anUrl] autorelease];
}
- (id)initWithObject:(id)anObject url:(NSURL *)anUrl
{
	self = [super init];
	self.object = anObject;
	self.url = anUrl;
	
	return self;
}

- (void)operate
{
	NSError *error = nil;
	
	id attrs = [[NSFileManager defaultManager ] attributesOfItemAtPath:[self.url path] error:&error];
	if(!attrs) {
		if(error) {
			NSLog(@"Error at checking XSPF. %@", error);
		} else {
			NSLog(@"Error at checking XSPF.");
		}
		return;
	}
	id attr = [attrs fileModificationDate];
	NSDate *settingDate = nil;
	if(attr) {
		settingDate = [self.object valueForKey:@"modificationDate"];
		if(nilOrNSNull(settingDate) || NSOrderedSame != [settingDate compare:attr]) {
			[self.object setValue:attr forKey:@"modificationDate"];
		}
	}
	attr = [attrs fileCreationDate];
	if(attr) {
		settingDate = [self.object valueForKey:@"creationDate"];
		if(nilOrNSNull(settingDate) || NSOrderedSame != [settingDate compare:attr]) {
			[self.object setValue:attr forKey:@"creationDate"];
		}
	}
}
-(void)terminate
{
	[self doesNotRecognizeSelector:_cmd];
}

@end
