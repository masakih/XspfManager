//
//  XspfMRuleRowTemplate.h
//
//  Created by Hori,Masaki on 10/05/04.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMRuleRowTemplate : NSObject
{
	NSString *rowTemplatePath;
	NSDictionary *rowTemplate;
}

+ (id)rowTemplateWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

- (id)criteriaForKeyPath:(NSString *)keyPath;

@end
