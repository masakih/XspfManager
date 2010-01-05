//
//  XspfMTableView.h
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/15.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMTableView : NSTableView
{
	NSInteger contextMenuRow;
}

@end


@interface NSObject (XspfMTableViewDataSource)
/* Optional - Context menu support
 This method overwrite returned NSMenu's delegate.
 */
- (NSMenu *)tableView:(XspfMTableView *)tableView menuForEvent:(NSEvent *)event;
@end
