//
//  XspfMRule_private.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/17.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfMRuleEditorRow.h"

@interface XspfMRule (XspfMPrivate)
- (NSView *)textField;
- (NSView *)datePicker;
- (NSView *)ratingIndicator;
- (NSView *)numberField;
@end
