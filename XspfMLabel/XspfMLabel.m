//
//  XspfMLabel.m
//  XspfMLabel
//
//  Created by Hori,Masaki on 10/06/09.
//  Copyright 2010 masakih. All rights reserved.
//

#import "XspfMLabel.h"

@implementation XspfMLabel
- (NSArray *)libraryNibNames {
    return [NSArray arrayWithObject:@"XspfMLabelLibrary"];
}

- (NSArray *)requiredFrameworks {
    return [NSArray arrayWithObjects:[NSBundle bundleWithIdentifier:@"com.masakih.XspfMLabel"], nil];
}

@end
