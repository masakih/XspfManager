/*
 *  HMUtilities.h
 *
 *  Created by Hori,Masaki on 10/01/01.
 *  Copyright 2010 masakih. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

void HMLog(NSInteger level, NSString *format, ...);
void HMLogv(NSInteger level, NSString *format, va_list args);

enum _HMLogLevel {
	HMLogLevelError,
	HMLogLevelAlert,
	HMLogLevelCaution,
	HMLogLevelNotice,
	HMLogLevelDebug,
};


// user defaults.
extern NSString *HMLogEnable;	// BOOL
extern NSString *HMLogLevel;	// integer

