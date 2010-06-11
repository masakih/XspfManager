//
//  XspfMLabelField.m
//  XspfMLabel
//
//  Created by Hori,Masaki on 10/06/09.
//  Copyright 2010 masakih. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <XspfMLabel/XspfMLabelField.h>
#import <XspfMLabel/XspfMLabelControl.h>
#import <XspfMLabel/XspfMLabelCell.h>
#import <XspfMLabel/XspfMLabelMenuItem.h>
#import "XspfMLabelInspector.h"

@interface XspfMLabelField (XspfMIBPrivate)
- (NSSize)minimumSize;
@end


@implementation XspfMLabelField ( XspfMLabel )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];
	
	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"value", @"labelStyle", @"drawX", nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
    [classes addObject:[XspfMLabelInspector class]];
}

- (NSSize)ibMinimumSize
{
	return [self minimumSize];
}
- (NSSize)ibMaximumSize
{
	NSSize size = [self minimumSize];
	size.width = 100000;
	return size;
}
@end

@implementation XspfMLabelControl ( XspfMLabel )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];
	
	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"value", @"labelStyle", @"drawX", nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
    [classes addObject:[XspfMLabelInspector class]];
}
@end

@implementation XspfMLabelCell ( XspfMLabel )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];
	
	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"value", @"labelStyle", @"drawX", nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
    [classes addObject:[XspfMLabelInspector class]];
}
@end

