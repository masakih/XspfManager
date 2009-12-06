//
//  XspfMRuleEditorDelegate.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/28.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class XspfMCompound, XspfMSimple;

@interface XspfMRuleEditorDelegate : NSObject
{
	XspfMCompound *compound;
	NSMutableArray *simples;
	
	IBOutlet NSRuleEditor *ruleEditor;
	NSArray *rows;
	NSArray *rowTemplate;
	NSMutableArray *rowIDs;
	NSMutableDictionary *rowFields;
	NSArray *predicateRows;
}

@end
