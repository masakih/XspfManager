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
}

- (NSManagedObjectContext *)managedObjectContext;

// if you overwrite this method, you MUST call super's one.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
