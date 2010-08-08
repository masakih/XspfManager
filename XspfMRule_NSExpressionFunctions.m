//
//  XspfMRule_NSExpressionFunctions.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/20.
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


#import "XspfMRule.h"

@implementation XspfMRule (XspfMNSExpressionFunctions)


- (NSString *)notContainsRegularExpression:(NSArray *)displayValues
{
	NSString *reg = [NSString stringWithFormat:@"(?:(?!.*%@).)*", [[displayValues objectAtIndex:2] stringValue]];
	id result = [NSExpression expressionForConstantValue:reg];
	return result;
}

- (NSArray *)rangeOfToday
{
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	id result = [NSArray arrayWithObjects:startOfToday, now, nil];
	return result;
}
- (NSArray *)rangeOfYesterday
{
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	NSDateComponents *comp = [[[NSDateComponents alloc] init] autorelease];
	[comp setDay:-1];
	NSDate *startOfYesterday = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	id result = [NSArray arrayWithObjects:startOfYesterday, startOfToday, nil];
	return result;
}
- (NSArray *)rangeOfThisWeek
{
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	NSDateComponents *comp = [[[NSDateComponents alloc] init] autorelease];
	
	[comp setWeekday:-[nowComp weekday]+1];
	NSDate *startOfThisWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	id result = [NSArray arrayWithObjects:startOfThisWeek, now, nil];
	return result;
}
- (NSArray *)rangeOfLastWeek
{
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	NSDateComponents *comp = [[[NSDateComponents alloc] init] autorelease];
	[comp setWeekday:-[nowComp weekday]+1];
	NSDate *startOfThisWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	[comp setWeekday:-[nowComp weekday]+1];
	[comp setWeek:-1];
	NSDate *startOfLastWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	id result = [NSArray arrayWithObjects:startOfLastWeek, startOfThisWeek, nil];
	return result;
}

- (NSArray *)dateRangeByNumber:(NSNumber *)numberValue unit:(NSNumber *)unitValue
{
	NSInteger number = [numberValue integerValue];
	NSInteger unit = [unitValue integerValue];
	
	NSDateComponents *comp01 = [[[NSDateComponents alloc] init] autorelease];
	NSDateComponents *comp02 = [[[NSDateComponents alloc] init] autorelease];
	NSUInteger unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | kCFCalendarUnitSecond;
	switch(unit) {
		case XspfMHoursUnitType:
			[comp01 setHour:-number];
			[comp02 setHour:-number+1];
			break;
		case XspfMDaysUnitType:
			[comp01 setDay:-number];
			[comp02 setDay:-number+1];
			break;
		case XpsfMWeeksUnitType:
			[comp01 setWeek:-number];
			[comp02 setDay:-1];
			break;
		case XspfMMonthsUnitType:
			[comp01 setMonth:-number];
			[comp02 setDay:-1];
			break;
		case XspfMYearsUnitType:
			[comp01 setYear:-number];
			[comp02 setDay:-1];
			break;
		default:
			[NSException raise:@"XspfMRuleUnknownUnitType" format:@"unknown unit type."];
			break;
	}
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:unitFlag fromDate:now];
	NSDate *aDay = [aCalendar dateFromComponents:nowComp];
	
	NSDate *pastDay01 = [aCalendar dateByAddingComponents:comp01 toDate:aDay options:0];
	NSDate *pastDay02 = [aCalendar dateByAddingComponents:comp02 toDate:aDay options:0];
	
	id result = [NSArray arrayWithObjects:pastDay01, pastDay02, nil];
	return result;
}
- (NSDate *)dateByNumber:(NSNumber *)numberValue unit:(NSNumber *)unitValue
{
	NSInteger number = [numberValue integerValue];
	NSInteger unit = [unitValue integerValue];
	
	NSDateComponents *comp = [[[NSDateComponents alloc] init] autorelease];
	NSUInteger unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | kCFCalendarUnitSecond;
	switch(unit) {
		case XspfMHoursUnitType:
			[comp setHour:-number];
			break;
		case XspfMDaysUnitType:
			[comp setDay:-number];
			break;
		case XpsfMWeeksUnitType:
			[comp setWeek:-number];
			break;
		case XspfMMonthsUnitType:
			[comp setMonth:-number];
			break;
		case XspfMYearsUnitType:
			[comp setYear:-number];
			break;
		default:
			[NSException raise:@"XspfMRuleUnknownUnitType" format:@"unknown unit type."];
			break;
	}
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:unitFlag fromDate:now];
	NSDate *aDay = [aCalendar dateFromComponents:nowComp];
	
	NSDate *pastDay = [aCalendar dateByAddingComponents:comp toDate:aDay options:0];
	
	return pastDay;
}
- (NSArray *)rangeDateByNumber:(NSNumber *)numberValue toNumber:(NSNumber *)number02Value unit:(NSNumber *)unitValue
{
	NSInteger number = [numberValue integerValue];
	NSInteger number02 = [number02Value integerValue];
	NSInteger unit = [unitValue integerValue];
	
	NSDateComponents *comp01 = [[[NSDateComponents alloc] init] autorelease];
	NSDateComponents *comp02 = [[[NSDateComponents alloc] init] autorelease];
	NSUInteger unitFlag = 0;//NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | kCFCalendarUnitSecond;
	switch(unit) {
		case XspfMHoursUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
			[comp01 setHour:-number];
			[comp02 setHour:-number02];
			break;
		case XspfMDaysUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
			[comp01 setDay:-number];
			[comp02 setDay:-number02];
			break;
		case XpsfMWeeksUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit;
			[comp01 setWeek:-number+1];
			[comp01 setDay:-1];
			[comp02 setWeek:-number02];
			break;
		case XspfMMonthsUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit;
			[comp01 setMonth:-number+1];
			[comp01 setDay:-1];
			[comp02 setMonth:-number02];
			break;
		case XspfMYearsUnitType:
			unitFlag = NSYearCalendarUnit;
			[comp01 setYear:-number+1];
			[comp01 setDay:-1];
			[comp02 setYear:-number02];
			break;
		default:
			[NSException raise:@"XspfMRuleUnknownUnitType" format:@"unknown unit type."];
			break;
	}
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:unitFlag fromDate:now];
	NSDate *aDay = [aCalendar dateFromComponents:nowComp];
	
	NSDate *pastDay01 = [aCalendar dateByAddingComponents:comp01 toDate:aDay options:0];
	NSDate *pastDay02 = [aCalendar dateByAddingComponents:comp02 toDate:aDay options:0];
	
	id result = [NSArray arrayWithObjects:pastDay02, pastDay01, nil];
	return result;
}
- (NSArray *)dateRangeFromVariable:(NSString *)date
{
//	HMLog(HMLogLevelDebug, @"In function argument is %@", date);
	
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
//	NSDateComponents *comp = [[[NSDateComponents alloc] init] autorelease];
//	[comp setDay:-1];
//	NSDate *startOfYesterday = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
//	[comp setDay:0];
//	[comp setWeekday:-[nowComp weekday]+1];
//	NSDate *startOfThisWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
//	[comp setWeekday:-[nowComp weekday]+1];
//	[comp setWeek:-1];
//	NSDate *startOfLastWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
//	HMLog(HMLogLevelDebug, @"now -> %@\ntoday -> %@\nyesterday -> %@\nthisweek -> %@\nlastweek -> %@",
//		  now, startOfToday, startOfYesterday, startOfThisWeek, startOfLastWeek);
	
	id result = [NSArray arrayWithObjects:now, startOfToday, nil];
	return result;
}

@end
