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

#import "CXDurationPickerDate.h"
#import "CXDurationPickerUtils.h"

@implementation CXDurationPickerUtils

+ (NSDateComponents *)dateComponentsFromPickerDate:(CXDurationPickerDate)pickerDate {
    NSDateComponents *components = [NSDateComponents new];
    
    components.year = pickerDate.year;
    components.month = pickerDate.month;
    components.day = pickerDate.day;
    
    return components;
}

+ (NSDate *)dateFromPickerDate:(CXDurationPickerDate)pickerDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    return [calendar dateFromComponents:[CXDurationPickerUtils dateComponentsFromPickerDate:pickerDate]];
}

+ (BOOL)isPickerDate:(CXDurationPickerDate)date1 equalTo:(CXDurationPickerDate)date2 {
    return date1.year == date2.year
    && date1.month == date2.month
    && date1.day == date2.day;
}

+ (CXDurationPickerDate)pickerDateFromDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:date];
    
    return (CXDurationPickerDate) {
        components.year,
        components.month,
        components.day
    };
}

+ (CXDurationPickerDate)pickerDateShiftedByDays:(NSUInteger)days fromPickerDate:(CXDurationPickerDate)pickerDate {
    NSDate *startDate = [CXDurationPickerUtils dateFromPickerDate:pickerDate];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [NSDateComponents new];
    
    components.day = days;
    
    NSDate *shiftedDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    
    return [CXDurationPickerUtils pickerDateFromDate:shiftedDate];
}

+ (NSString *)stringFromPickerDate:(CXDurationPickerDate)pickerDate {
    NSDate *date = [CXDurationPickerUtils dateFromPickerDate:pickerDate];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    return [formatter stringFromDate:date];
}

+ (NSDate *)today {
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                               fromDate:date];
    
    return [calendar dateFromComponents:components];
}

+ (BOOL)isPickerDateYesterday:(CXDurationPickerDate)pickerDate {
    NSDate *today = [self today];
    NSDate *date = [self dateFromPickerDate:pickerDate];
    
    NSTimeInterval interval = [date timeIntervalSinceDate:today];
    
    // 86400 seconds = 24hrs
    if ( interval >= -86400 && interval < 0) {
        return YES;
    }
    
    return NO;
}

@end
