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
}

@end
