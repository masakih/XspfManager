//
//  NSControl_Validation.m
//  XspfManager
//
//  Created by Hori,Masaki on 10/12/31.
//  Copyright 2010 masakih. All rights reserved.
//

#import "NSControl_Validation.h"


@implementation NSObject (XspfMControlValidator)
- (NSArray *)targetViews
{
	return [NSArray array];
}

- (void)autoControlValidate
{
	NSArray *views = [self targetViews];
	for(NSControl *control in views) {
		if(![control isKindOfClass:[NSControl class]]) continue;
		SEL action = [control action];
		if(!action) continue;
		
		id target = [NSApp targetForAction:action to:[control target] from:control];
		if(target && [target respondsToSelector:@selector(validateControl:)]) {
			[control setEnabled:[target validateControl:control]];
		}
		if(!target || ![target respondsToSelector:action]) {
			[control setEnabled:NO];
		}
	}
}
@end

@implementation NSApplication (XspfMControlValidator)
- (NSArray *)targetViews
{
	return [[[self mainWindow] contentView] subviews];
}
@end
@implementation NSWindow (XspfMControlValidator)
- (NSArray *)targetViews
{
	return [[self contentView] subviews];
}
@end
@implementation NSView (XspfMControlValidator)
- (NSArray *)targetViews
{
	return [self subviews];
}
@end
@implementation NSWindowController (XspfMControlValidator)
- (NSArray *)targetViews
{
	return [[[self window] contentView] subviews];
}
@end
@implementation NSViewController (XspfMControlValidator)
- (NSArray *)targetViews
{
	return [[self view] subviews];
}
@end

