//
//  XspfMListController.h
//  XspfManager
//
//  Created by Hori,Masaki on 11/01/03.
//  Copyright 2011 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfMListController : NSArrayController

- (IBAction)sortByTitle:(id)sender;
- (IBAction)sortByLastPlayDate:(id)sender;
- (IBAction)sortByModificationDate:(id)sender;
- (IBAction)sortByCreationDate:(id)sender;
- (IBAction)sortByRegisterDate:(id)sender;
- (IBAction)sortByRate:(id)sender;
- (IBAction)sortByMovieNumber:(id)sender;
- (IBAction)sortByLabel:(id)sender;

@end
