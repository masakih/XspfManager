//
//  XspfMMainModelTransformer.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/19.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMMainModelTransformer.h"

#import "XspfManager.h"


@implementation XspfMMainModelTransformer


+ (NSString *)titleFromURLString:(NSString *)urlString
{
	NSString *title = [urlString lastPathComponent];
	title = [title stringByDeletingPathExtension];
	title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
	return title;
}

@end
