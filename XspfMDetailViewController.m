//
//  XspfMDetailViewController.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/11/08.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に
 限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含
 めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表
 示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、
 コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、
 明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証
 も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューター
 も、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか
 厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する
 可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用
 サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定
 されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害につい
 て、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 1, Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.
 3, The names of its contributors may be used to endorse or promote
    products derived from this software without specific prior
    written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL,EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/

#import "XspfMDetailViewController.h"

#import "XspfManager.h"
#import "XspfMLabelControl.h"

@interface XspfMDetailViewController(HMPrivate)
- (void)buildFamilyNameFromFile;
@end

@implementation XspfMDetailViewController

- (id)init
{
	[super initWithNibName:@"DetailView" bundle:nil];
	
	[self buildFamilyNameFromFile];
	
	return self;
}

#pragma mark#### NSTokenField Delegate ####
#if 0
- (NSURL *)dictionayStoreURL
{
	NSString *appSupport = [[NSApp delegate] applicationSupportFolder];
	NSString *storeString = [appSupport stringByAppendingPathComponent:@"Dictionay.qdb"];
	
	return [NSURL fileURLWithPath:storeString];
}
- (id)dictionayStore
{
	id store = [[[self managedObjectContext] persistentStoreCoordinator] persistentStoreForURL:[self dictionayStoreURL]];
	if(!store) {
		NSError *error = nil;
		store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSApp delegate] managedObjectModel]];
		if (![store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self dictionayStoreURL] options:nil error:&error]){
			[[NSApplication sharedApplication] presentError:error];
		}
	}
	return store;
}
#else
- (id)dictionayStore { return nil; }
#endif

#if 1
- (NSArray *)tokenField:(NSTokenField *)tokenField
completionsForSubstring:(NSString *)substring
		   indexOfToken:(NSInteger)tokenIndex
	indexOfSelectedItem:(NSInteger *)selectedIndex
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	
	NSPredicate *aPredicate = [NSPredicate predicateWithFormat:
							   @"roman BEGINSWITH[cd] %@"
							   @"OR japanese BEGINSWITH[cd] %@"
							   @"OR yomigana BEGINSWITH[cd] %@", substring,substring,substring];
	NSEntityDescription *entry = [NSEntityDescription entityForName:@"FamilyName"
											 inManagedObjectContext:moc];
	
	[fetch setEntity:entry];
	[fetch setPredicate:aPredicate];
	
	NSError *error = nil;
	NSArray *objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			HMLog(HMLogLevelError, @"fail fetch reason -> %@", error);
		}
	}
	
	NSString *entryName = @"";
	switch([tokenField tag]) {
		case 2000:
			entryName = @"VoiceActor";
			break;
		case 2001:
			entryName = @"Product";
			break;
	}
	
	if([objects count] > 0) {
		NSMutableString *string = [NSMutableString string];
		NSMutableArray *names = [NSMutableArray array];
		for(id e in objects) {
			if([string length]) {
				[string appendString:@" OR "];
			}
			[string appendFormat:@"name BEGINSWITH[cd] %%@ "];
			[names addObject:[e valueForKey:@"japanese"]];
		}
		aPredicate = [NSPredicate predicateWithFormat:string argumentArray:names];
	} else {
		aPredicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", substring];
	}
	entry = [NSEntityDescription entityForName:entryName inManagedObjectContext:moc];
	[fetch setEntity:entry];
	[fetch setPredicate:aPredicate];
	
	error = nil;
	objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			HMLog(HMLogLevelError, @"fail fetch reason -> %@", error);
		}
	}
	
	NSMutableArray *result = [NSMutableArray arrayWithObject:substring];
	for(id obj in objects) {
		[result addObject:[obj valueForKey:@"name"]];
	}
	
	return result;
}
#else
- (NSArray *)tokenField:(NSTokenField *)tokenField
completionsForSubstring:(NSString *)substring
		   indexOfToken:(NSInteger)tokenIndex
	indexOfSelectedItem:(NSInteger *)selectedIndex
{
	HMLog(HMLogLevelDebug, @"Enter %@", NSStringFromSelector(_cmd));
	
	NSString *entryName = @"";
	switch([tokenField tag]) {
		case 2000:
			entryName = @"VoiceActor";
			break;
		case 2001:
			entryName = @"Product";
			break;
	}
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", substring];
	NSEntityDescription *entry = [NSEntityDescription entityForName:entryName
											 inManagedObjectContext:moc];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:entry];
	[fetch setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			HMLog(HMLogLevelError, @"fail fetch reason -> %@", error);
		}
	}
	
	NSMutableArray *result = [NSMutableArray array];
	for(id obj in objects) {
		[result addObject:[obj valueForKey:@"name"]];
	}
	
	return result;
}
#endif

- (void)registerVoiceActor:(NSTokenField *)tokenField
{
	id array = [tokenField objectValue];
	if(![array isKindOfClass:[NSArray class]]) return;
	
	NSString *entryName = @"";
	switch([tokenField tag]) {
		case 2000:
			entryName = @"VoiceActor";
			break;
		case 2001:
			entryName = @"Product";
			break;
	}
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *entry = [NSEntityDescription entityForName:entryName
											 inManagedObjectContext:moc];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:entry];
	
	for(id token in array) {
		NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"name LIKE[cd] %@", token];
		[fetch setPredicate:aPredicate];
		
		NSError *error = nil;
		NSUInteger count = [moc countForFetchRequest:fetch error:&error];
		if(error) {
			HMLog(HMLogLevelError, @"fail fetch reason -> %@", error);
			continue;
		}
		if(count == 0) {
			id obj = [NSEntityDescription insertNewObjectForEntityForName:entryName inManagedObjectContext:moc];
			[obj setValue:token forKey:@"name"];
			[moc assignObject:obj toPersistentStore:[self dictionayStore]];
		}
	}
}
- (BOOL)control:(id)control textShouldEndEditing:(NSText *)fieldEditor
{
	if([control tag] == 2000 || [control tag] == 2001) {
		[self registerVoiceActor:control];
	}
	
	return YES;
}

#pragma mark#### load familynames ####
- (NSArray *)arrayFromLFSeparatedFile:(NSString *)name
{
	NSString *path;
	
	path = [[[NSApp delegate] applicationSupportFolder] stringByAppendingPathComponent:name];
	path = [path stringByAppendingPathExtension:@"txt"];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir = NO;
	if(![fm fileExistsAtPath:path isDirectory:&isDir] || isDir) {
		path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
	}
	
	NSError *error = nil;
	NSString *content = [NSString stringWithContentsOfFile:path
												  encoding:NSUTF8StringEncoding
													 error:&error];
	if(error) {
		HMLog(HMLogLevelDebug, @"path => %@", path);
		HMLog(HMLogLevelError, @"%@", [error localizedDescription]);
		return NO;
	}
	
	return [content componentsSeparatedByString:@"\x0a"];
}

- (NSArray *)arrayFromTabSeparatedString:(NSString *)string
{
	return [string componentsSeparatedByString:@"\t"];
}
- (BOOL)isEmptyEntityName:(NSString *)name
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSInteger num;
	
	fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:name
								 inManagedObjectContext:moc]];
	num = [moc countForFetchRequest:fetch
							  error:&error];
	[fetch release];
	fetch = nil;
	if(error) {
		HMLog(HMLogLevelError, @"%@", [error localizedDescription]);
		return NO;
	}
	
	return num == 0;
}
- (void)buildFamilyNameFromFile
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	NSString *entityName;
	NSArray *contents;
	entityName = @"FamilyName";
	if([self isEmptyEntityName:entityName]) {
		contents = [self arrayFromLFSeparatedFile:entityName];
		
		id key;
		for(key in contents) {
			NSArray *attr = [self arrayFromTabSeparatedString:key];
			if([attr count] < 2) continue;
			
			id obj = [NSEntityDescription insertNewObjectForEntityForName:entityName
												   inManagedObjectContext:moc];
			[moc assignObject:obj toPersistentStore:[self dictionayStore]];
			[obj setValue:[attr objectAtIndex:0] forKey:@"roman"];
			[obj setValue:[attr objectAtIndex:1] forKey:@"japanese"];
			
			if([attr count] > 2) {
				[obj setValue:[attr objectAtIndex:2] forKey:@"yomigana"];
			}
		}
	}
	
}

- (void)truncateFamilyName
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entry = [NSEntityDescription entityForName:@"FamilyName"
											 inManagedObjectContext:moc];
	[fetch setEntity:entry];
	
	NSError *error = nil;
	NSArray *objects = [moc executeFetchRequest:fetch error:&error];
	if(!objects) {
		if(error) {
			HMLog(HMLogLevelError, @"fail fetch reason -> %@", error);
		}
	}
	
	[moc lock];
	for(id obj in objects) {
		[moc deleteObject:obj];
	}
	[moc unlock];
}

//#pragma mark#### Test ####
//- (IBAction)test01:(id)sender
//{
//	[self truncateFamilyName];
//	[self buildFamilyNameFromFile];
//}

@end
