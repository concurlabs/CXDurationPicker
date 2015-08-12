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

#ifndef CalendarViewSample_CXDurationPickerDate_h
#define CalendarViewSample_CXDurationPickerDate_h

#import <UIKit/UIKit.h>

typedef struct {
    NSUInteger year;
    NSUInteger month;
    NSUInteger day;
} CXDurationPickerDate;

typedef struct {
    NSUInteger year;
    NSUInteger month;
} CXDurationPickerMonth;

typedef NS_ENUM(NSUInteger, CXDurationPickerComparison) {
    CXDurationPickerComparisonEqual,
    CXDurationPickerComparisonBefore,
    CXDurationPickerComparisonAfter
};

typedef NS_ENUM(NSUInteger, CXDurationPickerMode) {
    CXDurationPickerModeSingleDate,
    CXDurationPickerModeStartDate,
    CXDurationPickerModeEndDate
};

typedef NS_ENUM(NSUInteger, CXDurationPickerDayType) {
    CXDurationPickerDayTypeDisabled,
    CXDurationPickerDayTypeStart,
    CXDurationPickerDayTypeEnd,
    CXDurationPickerDayTypeTransit,
    CXDurationPickerDayTypeNormal,
    CXDurationPickerDayTypeSingle,
    CXDurationPickerDayTypeOverlap
};

typedef NS_ENUM(NSUInteger, CXDurationPickerType) {
    CXDurationPickerTypeDuration,
    CXDurationPickerTypeSingle
};

#endif
