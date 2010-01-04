//
//  XspfMLabelMenuItem.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/04.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMLabelMenuItem : NSMenuItem
{

}

- (void)setObjectValue:(id)value;
- (id)objectValue;
- (void)setIntegerValue:(NSInteger)value;
- (NSInteger)integerValue;

@end
