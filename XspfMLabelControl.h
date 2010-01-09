//
//  XspfMLabelControl.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/01/06.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMLabelControl : NSControl

- (void)setLabelStyle:(NSInteger)style;
- (NSInteger)labelStyle;
- (void)setDrawX:(BOOL)flag;
- (BOOL)isDrawX;
@end
