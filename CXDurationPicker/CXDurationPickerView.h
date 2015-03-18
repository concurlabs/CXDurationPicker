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

#import <UIKit/UIKit.h>

#import "CXDurationPickerDate.h"
#import "CXDurationPickerMonthView.h"

@class CXDurationPickerView;

@protocol CXDurationPickerViewDelegate <NSObject>

- (void)durationPicker:(CXDurationPickerView *)durationPicker endDateChanged:(CXDurationPickerDate)date;
- (void)durationPicker:(CXDurationPickerView *)durationPicker startDateChanged:(CXDurationPickerDate)date;

@optional

- (void)durationPicker:(CXDurationPickerView *)durationPicker invalidEndDateSelected:(CXDurationPickerDate)date;
- (void)durationPicker:(CXDurationPickerView *)durationPicker invalidStartDateSelected:(CXDurationPickerDate)date;

@end

@interface CXDurationPickerView : UIView <CXDurationPickerMonthViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) id<CXDurationPickerViewDelegate> delegate;
@property (assign, nonatomic) CXDurationPickerDate startDate;
@property (assign, nonatomic) CXDurationPickerDate endDate;
@property (assign, nonatomic) CXDurationPickerMode mode;

- (void)shiftDurationToEndPickerDate:(CXDurationPickerDate)pickerDate;
- (void)shiftDurationToStartPickerDate:(CXDurationPickerDate)pickerDate;

@end
