// 
//  XSPFMInfomationObject.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/02.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XSPFMInfomationObject.h"

#import "XSPFMXspfObject.h"

@implementation XSPFMInfomationObject 

@dynamic productsList;
@dynamic voiceActorsList;
@dynamic xspf;

static NSString *const VoiceActorsDelimiter = @":::";

- (NSArray *)voiceActors
{
	[self willAccessValueForKey:@"voiceActors"];
	NSArray *voiceActors = [self primitiveValueForKey:@"voiceActors"];
	[self didAccessValueForKey:@"voiceActors"];
	if (voiceActors == nil) {
		NSString *voiceActorsList = [self valueForKey:@"voiceActorsList"];
		if (voiceActorsList) {
			voiceActors = [voiceActorsList componentsSeparatedByString:VoiceActorsDelimiter];
			[self setValue:voiceActors forKey:@"voiceActors"];
		}
	}
	return voiceActors;
}
- (void)setVoiceActors:(NSArray *)actors
{
	[self willChangeValueForKey:@"voiceActors"];
	[self setPrimitiveValue:actors forKey:@"voiceActors"];
	[self didChangeValueForKey:@"voiceActors"];
	[self setValue:[actors componentsJoinedByString:VoiceActorsDelimiter] forKey:@"voiceActorsList"];
}
- (NSArray *)products
{
	[self willAccessValueForKey:@"products"];
	NSArray *products = [self primitiveValueForKey:@"products"];
	[self didAccessValueForKey:@"products"];
	if (products == nil) {
		NSString *productsList = [self valueForKey:@"productsList"];
		if (productsList) {
			products = [productsList componentsSeparatedByString:VoiceActorsDelimiter];
			[self setValue:products forKey:@"products"];
		}
	}
	return products;
}
- (void)setProducts:(NSArray *)actors
{
	[self willChangeValueForKey:@"products"];
	[self setPrimitiveValue:actors forKey:@"products"];
	[self didChangeValueForKey:@"products"];
	[self setValue:[actors componentsJoinedByString:VoiceActorsDelimiter] forKey:@"productsList"];
}

@end
