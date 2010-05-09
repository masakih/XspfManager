//
//  XspfMRuleEditorDelegate.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/28.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class XspfMRuleRowTemplate;
@interface XspfMRuleEditorDelegate : NSObject
{
	NSArray *compounds;
	NSMutableArray *simples;
	
	IBOutlet NSRuleEditor *ruleEditor;
	NSArray *rows;
	XspfMRuleRowTemplate *rowTemplate;
	NSArray *predicateRows;
}

@end
