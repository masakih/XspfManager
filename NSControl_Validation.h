//
//  NSControl_Validation.h
//  XspfManager
//
//  Created by Hori,Masaki on 10/12/31.
//  Copyright 2010 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (XspfMControlValidator)
- (void)autoControlValidate;
@end

@interface NSObject (XspfMControlValidation)
- (BOOL)validateControl:(NSControl *)aControl;
@end

