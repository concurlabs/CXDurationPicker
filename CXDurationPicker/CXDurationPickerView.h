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

@optional

- (void)durationPicker:(CXDurationPickerView *)durationPicker endDateChanged:(CXDurationPickerDate)date;
- (void)durationPicker:(CXDurationPickerView *)durationPicker singleDateChanged:(CXDurationPickerDate)date;
- (void)durationPicker:(CXDurationPickerView *)durationPicker startDateChanged:(CXDurationPickerDate)date;

- (void)durationPicker:(CXDurationPickerView *)durationPicker invalidEndDateSelected:(CXDurationPickerDate)date;
- (void)durationPicker:(CXDurationPickerView *)durationPicker invalidStartDateSelected:(CXDurationPickerDate)date;

- (void)durationPicker:(CXDurationPickerView *)durationPicker
   didSelectDateInPast:(CXDurationPickerDate)date
               forMode:(CXDurationPickerMode)mode;

@end

@interface CXDurationPickerView : UIView <CXDurationPickerMonthViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<CXDurationPickerViewDelegate> delegate;
@property (nonatomic) CXDurationPickerDate singleDate;
@property (nonatomic) CXDurationPickerDate startDate;
@property (nonatomic) CXDurationPickerDate endDate;
@property (nonatomic) CXDurationPickerMode mode;
@property (nonatomic) CXDurationPickerType type;    
@property (nonatomic) BOOL allowSelectionsInPast;
@property (nonatomic) BOOL allowSelectionOnSameDay;
@property (nonatomic) BOOL allowSelectionOfYesterdayAsStartDay;

@property (nonatomic,strong)NSArray* blockedDays;
// Month-specific colors
//
@property (strong, nonatomic) UIColor *dayLabelColor;
@property (strong, nonatomic) UIColor *monthLabelColor;

// Day-specific colors
//
@property (strong, nonatomic) UIColor *dayBackgroundColor;
@property (strong, nonatomic) UIColor *dayForegroundColor;

@property (strong, nonatomic) UIColor *disabledDayBackgroundColor;
@property (strong, nonatomic) UIColor *disabledDayForegroundColor;

@property (strong, nonatomic) UIColor *gridColor;

@property (strong, nonatomic) UIColor *terminalBackgroundColor;
@property (strong, nonatomic) UIColor *terminalForegroundColor;

@property (strong, nonatomic) UIColor *todayBackgroundColor;
@property (strong, nonatomic) UIColor *todayForegroundColor;

@property (strong, nonatomic) UIColor *transitBackgroundColor;
@property (strong, nonatomic) UIColor *transitForegroundColor;

@property (nonatomic)BOOL roundedTerminals;

- (void)scrollToStartMonth:(BOOL)animated;

// Maintained for backward-compat. Will be removed in v1.0
//
- (void)shiftDurationToEndPickerDate:(CXDurationPickerDate)pickerDate __attribute__((deprecated));
- (void)shiftDurationToStartPickerDate:(CXDurationPickerDate)pickerDate __attribute__((deprecated));

- (BOOL)shiftDurationToEndPickerDate:(CXDurationPickerDate)pickerDate error:(NSError **)error;
- (BOOL)shiftDurationToStartPickerDate:(CXDurationPickerDate)pickerDate error:(NSError **)error;

- (void)setStartDate:(NSDate *)date withDuration:(NSUInteger)days;
- (void)setStartPickerDate:(CXDurationPickerDate)pickerDate withDuration:(NSUInteger)days;

@end
