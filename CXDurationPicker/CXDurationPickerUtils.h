/*
 * Copyright (C) 2015 Concur Technologies
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

#import "CXDurationPickerDate.h"

@interface CXDurationPickerUtils : NSObject

+ (NSDateComponents *)dateComponentsFromPickerDate:(CXDurationPickerDate)pickerDate;
+ (NSDate *)dateFromPickerDate:(CXDurationPickerDate)pickerDate;
+ (BOOL)isPickerDate:(CXDurationPickerDate)date1 equalTo:(CXDurationPickerDate)date2;
+ (CXDurationPickerDate)pickerDateFromDate:(NSDate *)date;
+ (CXDurationPickerDate)pickerDateShiftedByDays:(NSUInteger)days fromPickerDate:(CXDurationPickerDate)pickerDate;
+ (NSString *)stringFromPickerDate:(CXDurationPickerDate)pickerDate;
+ (NSDate *)today;
+ (BOOL)isPickerDateYesterday:(CXDurationPickerDate)pickerDate;

@end
