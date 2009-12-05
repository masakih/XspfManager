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

static inline BOOL nilOrNSNull(id obj)
{
	return !obj || obj == [NSNull null];
}

+ (id)requestWithObject:(XSPFMXspfObject *)anObject
{
	return [[[self alloc] initWithObject:anObject] autorelease];
}
- (id)initWithObject:(XSPFMXspfObject *)anObject
{
	self = [super init];
	self.object = anObject;
	
	return self;
}
- (void)dealloc
{
	self.object = nil;
	
	[super dealloc];
}

- (void)operate
{
	NSError *error = nil;
	
	id attrs = [[NSFileManager defaultManager ] attributesOfItemAtPath:self.object.filePath error:&error];
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
		settingDate = self.object.modificationDate;
		if(nilOrNSNull(settingDate) || NSOrderedSame != [settingDate compare:attr]) {
			self.object.modificationDate = attr;
		}
	}
	attr = [attrs fileCreationDate];
	if(attr) {
		settingDate = self.object.creationDate;
		if(nilOrNSNull(settingDate) || NSOrderedSame != [settingDate compare:attr]) {
			self.object.creationDate = attr;
		}
	}
}
-(void)terminate
{
	[self doesNotRecognizeSelector:_cmd];
}

@end
