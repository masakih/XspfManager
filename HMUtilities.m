/*
 *  HMUtilities.m
 *
 *  Created by Hori,Masaki on 10/01/01.
 *  Copyright 2010 masakih. All rights reserved.
 *
 */

#import "HMUtilities.h"

NSString *HMLogEnable = @"HMLogEnable";
NSString *HMLogLevel = @"HMLogLevel";

void HMLog(NSInteger level, NSString *format, ...)
{
	va_list ap;
	va_start(ap, format);
	HMLogv(level, format, ap);
	va_end(ap);
}
void HMLogv(NSInteger level, NSString *format, va_list args)
{
	[[NSUserDefaults standardUserDefaults] synchronize];
	[NSUserDefaults resetStandardUserDefaults];
	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:HMLogEnable];
	if(!enabled) return;
	
	NSInteger logLevel = [[NSUserDefaults standardUserDefaults] integerForKey:HMLogLevel];
	if(level > logLevel) return;
	
	NSLogv(format, args);
}
