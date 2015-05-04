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

+ (NSString *)stringFromPickerDate:(CXDurationPickerDate)pickerDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, MMM d"];
    
    NSDate *date = [CXDurationPickerUtils dateFromPickerDate:pickerDate];
    
    return [formatter stringFromDate:date];
}

+ (NSDate *)today {
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                               fromDate:date];
    
    return [calendar dateFromComponents:components];
}

@end
