//
//  XspfMViewController.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/06.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMViewController : NSViewController
{
	IBOutlet NSResponder *initialFirstResponder;
	
	IBOutlet NSView *firstKeyView;
	IBOutlet NSView *lastKeyView;
}

- (NSManagedObjectContext *)managedObjectContext;

- (void)recalculateKeyViewLoop;
- (NSView *)firstKeyView;
- (NSView *)lastKeyView;
- (void)setNextKeyView:(NSView *)view;

// if you overwrite this method, you MUST call super's one.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
