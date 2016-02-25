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
#import "CXDurationPickerView.h"

@class CXDurationPickerDayView;
@class CXDurationPickerMonthView;

@protocol CXDurationPickerMonthViewDelegate <NSObject>

- (void)monthView:(CXDurationPickerMonthView *)view daySelected:(CXDurationPickerDayView *)dayView;

@end

@interface CXDurationPickerMonthView : UIView

@property (weak, nonatomic) id<CXDurationPickerMonthViewDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *days;
@property (nonatomic) NSInteger monthIndex;
@property (nonatomic) UIEdgeInsets padding;
@property (nonatomic) CXDurationPickerMonth pickerMonth;
@property (nonatomic) BOOL disableDaysBeforeToday;
@property (nonatomic) BOOL disableYesterday;

@property (nonatomic,strong)NSMutableSet* blockedDays;
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

- (BOOL)containsDate:(CXDurationPickerDate)pickerDate;
- (CXDurationPickerDayView *)dayForPickerDate:(CXDurationPickerDate)pickerDate;
-(void)assignBlockedDays:(NSArray *)disabledDays;
@end
