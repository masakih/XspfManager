//
//  XspfMRule_NSExpressionFunctions.m
//  XspfManager
//
//  Created by Hori,Masaki on 09/12/20.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfMRuleEditorRow.h"

@implementation XspfMRule (XspfMNSExpressionFunctions)

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
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
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
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	
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
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
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
	
	NSDateComponents *comp01 = [[NSDateComponents alloc] init];
	NSDateComponents *comp02 = [[NSDateComponents alloc] init];
	NSUInteger unitFlag = 0;
	switch(unit) {
		case XspfMDaysUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
			[comp01 setDay:-number];
			[comp02 setDay:-number+1];
			break;
		case XpsfMWeeksUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit;
			[comp01 setWeek:-number];
			[comp02 setDay:-1];
			break;
		case XspfMMonthsUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit;
			[comp01 setMonth:-number];
			[comp02 setDay:-1];
			break;
		case XspfMYearsUnitType:
			unitFlag = NSYearCalendarUnit;
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
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	NSUInteger unitFlag = 0;
	switch(unit) {
		case XspfMDaysUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
			[comp setDay:-number];
			break;
		case XpsfMWeeksUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit;
			[comp setWeek:-number];
			break;
		case XspfMMonthsUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit;
			[comp setMonth:-number];
			break;
		case XspfMYearsUnitType:
			unitFlag = NSYearCalendarUnit;
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
	
	NSDateComponents *comp01 = [[NSDateComponents alloc] init];
	NSDateComponents *comp02 = [[NSDateComponents alloc] init];
	NSUInteger unitFlag = 0;
	switch(unit) {
		case XspfMDaysUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
			[comp01 setDay:-number];
			[comp02 setDay:-number02];
			break;
		case XpsfMWeeksUnitType:
			unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit;
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
	
	id result = [NSArray arrayWithObjects:pastDay01, pastDay02, nil];
	return result;
}
- (NSArray *)dateRangeFromVariable:(NSString *)date
{
	NSLog(@"In function argument is %@", date);
	
	NSCalendar *aCalendar = [NSCalendar currentCalendar];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSDateComponents *nowComp = [aCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit
											 fromDate:now];
	NSDate *startOfToday = [aCalendar dateFromComponents:nowComp];
	
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	[comp setDay:-1];
	NSDate *startOfYesterday = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	[comp setDay:0];
	[comp setWeekday:-[nowComp weekday]+1];
	NSDate *startOfThisWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	[comp setWeekday:-[nowComp weekday]+1];
	[comp setWeek:-1];
	NSDate *startOfLastWeek = [aCalendar dateByAddingComponents:comp toDate:startOfToday options:0];
	
	NSLog(@"now -> %@\ntoday -> %@\nyesterday -> %@\nthisweek -> %@\nlastweek -> %@",
		  now, startOfToday, startOfYesterday, startOfThisWeek, startOfLastWeek);
	
	id result = [NSArray arrayWithObjects:now, startOfToday, nil];
	return result;
}

@end
