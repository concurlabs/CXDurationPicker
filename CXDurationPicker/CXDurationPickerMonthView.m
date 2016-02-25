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

#import <CoreText/CoreText.h>

#import "CXDurationPickerView.h"
#import "CXDurationPickerDayView.h"
#import "CXDurationPickerMonthView.h"
#import "CXDurationPickerUtils.h"
#import "UIColor+CXDurationDefaults.h"

@interface CXDurationPickerMonthView ()
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic, strong) NSCalendar *calendar;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) CGFloat monthWidth;
@property (nonatomic) CGFloat monthOffset;
@property (nonatomic) CGFloat monthTitleHeight;
@property (nonatomic) CGFloat weekTitleHeight;
@property (strong, nonatomic) UILabel *dateLabel;
@property (nonatomic) NSDateComponents *components;
@property (nonatomic) NSUInteger numDays;
@end

@implementation CXDurationPickerMonthView

#pragma mark - Lifecycle

- (void)baseInit {
    self.monthTitleHeight = 16;
    self.weekTitleHeight = 12;
    
    self.gridColor = [UIColor grayColor];
    
    self.days = [[NSMutableArray alloc] init];
    
    self.blockedDays = [NSMutableSet new];
    
    self.monthWidth = (floor(self.bounds.size.width / 7) * 7) - 6;
    
    self.monthOffset = (self.bounds.size.width - self.monthWidth) / 2;
    
    self.backgroundColor = [UIColor defaultMonthBackgroundColor];
    
    self.calendar = [NSCalendar currentCalendar];
    
    self.roundedTerminals = YES;
}

- (NSString *)description {
    return self.dateString;
}

-(void)assignBlockedDays:(NSArray *)disabledDays{
    NSMutableSet* componentArray = [NSMutableSet new];
    for (NSDate* date in disabledDays) {
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar]
                                             components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                             fromDate:date];
        [componentArray addObject:todayComponents];
    }
    _blockedDays = componentArray.copy;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (void)layoutSubviews {
    if (!self.date) {
        NSLog(@"monthview layout: Nothing to do.");
        return;
    }

    NSDate *today = [NSDate date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar]
                                         components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                         fromDate:today];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSDateComponents *yesterdayComponents = [[NSCalendar currentCalendar]
                                             components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                             fromDate:yesterday];

    float cellSize = self.bounds.size.width / 7;
    
    self.cellWidth = floor(cellSize);
    self.cellHeight = floor(cellSize);
    
    self.dateLabel.frame = CGRectMake(self.monthOffset, 0,
                                      self.bounds.size.width - self.monthOffset,
                                      self.monthTitleHeight + 4);

    float yOffset = self.dateLabel.frame.size.height + 10;
    
    for (int i = 0; i < 7; i++) {
        float xOffset = 0;
        
        if (i != 0) {
            xOffset = -1 * i;
        }
        
        NSUInteger tag = 100 + i;
        
        UIView *dayLabel = [self viewWithTag:tag];
        
        dayLabel.frame = CGRectMake(i * self.cellWidth + self.monthOffset + xOffset,
                                    yOffset,
                                    self.cellWidth,
                                    self.weekTitleHeight);
    }
    
    yOffset += self.weekTitleHeight + 5;
    
    int colIndex = 0;
    int rowIndex = 0;
    
    for (int i = 1; i < self.components.weekday; i++) {
        colIndex++;
    }
    
    for (int i = 0; i < self.numDays; i++) {
        float x = colIndex * self.cellWidth;
        float y = rowIndex * self.cellHeight;
        
        float xOffset = 0;
        
        if (colIndex != 0) {
            xOffset = -1 * (colIndex);
        }
        
        float yOffset2 = 0;
        if (rowIndex != 0) {
            yOffset2 = -1 * (rowIndex);
        }
        
        NSUInteger tag = 200 + i;
        
        CXDurationPickerDayView *dayView = (CXDurationPickerDayView*)[self viewWithTag:tag];
        
        dayView.frame = CGRectMake(x + self.monthOffset + xOffset,
                                   y + yOffset + yOffset2,
                                   self.cellWidth,
                                   self.cellHeight);
        
        colIndex++;
        
        if (colIndex % 7 == 0) {
            colIndex = 0;
            rowIndex++;
        }
        
        if (self.disableDaysBeforeToday) {
            if (self.components.year < todayComponents.year) {
                dayView.isDisabled = YES;
            } else if (self.components.year <= todayComponents.year
                       && self.components.month < todayComponents.month) {
                dayView.isDisabled = YES;
            } else if (self.components.year == yesterdayComponents.year
                       && self.components.month == yesterdayComponents.month
                       && i == yesterdayComponents.day - 1
                       && !self.disableYesterday) {
                dayView.isDisabled = NO;
            } else if (self.components.year == todayComponents.year
                       && self.components.month == todayComponents.month
                       && i < todayComponents.day - 1) {
                dayView.isDisabled = YES;
            }
        } else {
            dayView.isDisabled = NO;
        }
        
        //Disable Day here
        if (self.blockedDays.count > 0 ) {
            NSDateComponents *dayComponent = [CXDurationPickerUtils dateComponentsFromPickerDate:dayView.pickerDate];
            if ([self.blockedDays containsObject:dayComponent]) {
                dayView.isDisabled = YES;
                dayView.type = CXDurationPickerDayTypeDisabled;
            }
        }
        
        dayView.roundedTerminals = self.roundedTerminals;
        
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    float cellSize = self.bounds.size.width / 7;
    
    self.cellWidth = floor(cellSize);
    self.cellHeight = floor(cellSize);
    
    NSUInteger height = 0;
    
    height += (self.dateLabel.frame.size.height + 10);
    height += (self.weekTitleHeight + 5);
    
    NSUInteger numWeeks = [self numberOfWeekRowsNeeded];
    
    height += (numWeeks * self.cellHeight);
    
    height += 20; // bottom
    
    CGSize viewSize = CGSizeMake(self.bounds.size.width, height);
    
    return viewSize;
}

#pragma mark - Gesture recognizers

- (void)daySelected:(UITapGestureRecognizer *)recognizer {
    if (self.delegate != nil) {
        CXDurationPickerDayView *dayView = (CXDurationPickerDayView *)recognizer.view;
        if (!dayView.isDisabled) {
            [self.delegate monthView:self daySelected:dayView];
        }
        
    }
}

#pragma mark - Internal

- (BOOL)containsDate:(CXDurationPickerDate)pickerDate {
    if (self.pickerMonth.month == pickerDate.month
        && self.pickerMonth.year == pickerDate.year) {
        return YES;
    }
    
    return NO;
}

- (CXDurationPickerDayView *)dayForPickerDate:(CXDurationPickerDate)pickerDate {
    CXDurationPickerDayView *day;
    
    for (CXDurationPickerDayView *dayView in self.days) {
        if (dayView.pickerDate.day == pickerDate.day) {
            day = dayView;
            break;
        }
    }
    
    return day;
}

- (void)setupViews {
    self.dateString = [NSString stringWithFormat:@"%@", [self monthNameFromDate:self.date]];
    
    UIFont *dateFont = [UIFont fontWithName:@"HelveticaNeue" size:self.monthTitleHeight];
    
//    [self setIsAccessibilityElement:YES];
//    self.accessibilityIdentifier = self.dateString;
    
    self.dateLabel = [[UILabel alloc] init];
    
    [self.dateLabel setFont:dateFont];
    [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
    [self.dateLabel setTextColor:self.monthLabelColor];
    [self.dateLabel setText:self.dateString];
    
    [self addSubview:self.dateLabel];

    // Build a localized string array instead of hardcoded SUN,MON...FRI,SAT,SUN
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSMutableArray *daysOfWeek = [[NSMutableArray alloc] init];
    for (NSString *dayOfWeek in [dateFormatter shortWeekdaySymbols]) {
        [daysOfWeek addObject:[dayOfWeek uppercaseString]];
    }
    // Add SUN to the end again - not sure why, but the hardcoded array had it there, so if it ain't broke...
    [daysOfWeek addObject:daysOfWeek[0]];
    
    UILabel *dayLabel;
    UIFont *dayFont = [UIFont fontWithName:@"HelveticaNeue" size:self.weekTitleHeight];
    
    for (int i = 0; i < 7; i++) {
        float xOffset = 0;
        
        if (i != 0) {
            xOffset = -1 * i;
        }
        
        NSUInteger tag = 100 + i;
        
        dayLabel = [[UILabel alloc] init];
        
        [dayLabel setTag:tag];
        [dayLabel setFont:dayFont];
        [dayLabel setTextAlignment:NSTextAlignmentCenter];
        [dayLabel setTextColor:self.dayLabelColor];
        [dayLabel setFont:dayFont];
        [dayLabel setText:daysOfWeek[i]];
        
        [self addSubview:dayLabel];
    }
    
    int colIndex = 0;
    int rowIndex = 0;
    
    for (int i = 1; i < self.components.weekday; i++) {
        colIndex++;
    }
    
    NSDate *today = [NSDate date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar]
                                         components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                         fromDate:today];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSDateComponents *yesterdayComponents = [[NSCalendar currentCalendar]
                                         components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                         fromDate:yesterday];
    
    for (int i = 0; i < self.numDays; i++) {
        float xOffset = 0;
        
        if (colIndex != 0) {
            xOffset = -1 * (colIndex);
        }
        
        float yOffset2 = 0;
        if (rowIndex != 0) {
            yOffset2 = -1 * (rowIndex);
        }
        
        CXDurationPickerDayView *v = [[CXDurationPickerDayView alloc] init];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(daySelected:)];
        
        [v addGestureRecognizer:tap];
        
        if (self.disableDaysBeforeToday) {
            if (self.components.year < todayComponents.year) {
                v.isDisabled = YES;
            } else if (self.components.year <= todayComponents.year
                       && self.components.month < todayComponents.month) {
                v.isDisabled = YES;
            } else if (self.components.year == yesterdayComponents.year
                      && self.components.month == yesterdayComponents.month
                      && i == yesterdayComponents.day - 1
                      && !self.disableYesterday) {
                v.isDisabled = NO;
            } else if (self.components.year == todayComponents.year
                       && self.components.month == todayComponents.month
                       && i < todayComponents.day - 1) {
                v.isDisabled = YES;
            }
        } else {
            v.isDisabled = NO;
        }

        if (self.components.year == todayComponents.year
            && self.components.month == todayComponents.month
            && i == todayComponents.day - 1) {
            v.isToday = YES;
        }
        
        colIndex++;
        
        v.tag = 200 + i;
        
        NSString *day = [NSString stringWithFormat:@"%d", i + 1];
        
        v.day = day;
        
        CXDurationPickerDate pickerDate;
        pickerDate.day = i + 1;
        pickerDate.month = self.pickerMonth.month;
        pickerDate.year = self.pickerMonth.year;
        
        v.pickerDate = pickerDate;
        
        v.gridColor = self.gridColor;
        
        [self.days addObject:v];
        
        [self addSubview:v];
        
        if (colIndex % 7 == 0) {
            colIndex = 0;
            rowIndex++;
        }
    }
}

- (void)setMonthIndex:(NSInteger)index {
    _monthIndex = index;
    
    self.date = [self dateForFirstDayInSection:index];
    
    self.pickerMonth = [self monthPickerDateFromDate:self.date];
    
    NSCalendar *c = [NSCalendar currentCalendar];
    
    self.numDays = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:self.date].length;
    
    self.components = [[NSCalendar currentCalendar]
                       components:NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear
                       fromDate:self.date];
    
    [self setupViews];
    
    [self layoutIfNeeded];
}

- (NSDate *)dateForFirstDayInSection:(NSInteger)section {
    section = section - 12;
    
    NSDate *now = [_calendar dateFromComponents:[_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth
                                                             fromDate:[NSDate date]]];
    
    NSDateComponents *components = [NSDateComponents new];
    components.month = 0;
    
    CXDurationPickerDate pickerDate = [CXDurationPickerUtils pickerDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = section;
    
    NSDate *sectionDate = [_calendar dateByAddingComponents:dateComponents toDate:[CXDurationPickerUtils dateFromPickerDate:pickerDate] options:0];
    
    return sectionDate;
}

- (NSString *)monthNameFromDate:(NSDate *)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    // Must use yyyy not YYYY
    //
    // Explanation...
    // YYYY means year of week
    // yyyy means ordinary calendar year
    //
    // Case in point: 2016/01/01 using YYYY
    // US region considers this week to be in 2016
    // UK region considers this week to be in 2015
    // As a result the calendar would display January 2015 incorrectly
    // The reason is straddling days. Some regions say that there must be a minimum number of
    // days straddling a week in the new year to be considered the first week of that new year
    [dateFormatter setDateFormat:@"MMMM yyyy"];
    
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    
    return stringFromDate;
}

- (int)numberOfWeekRowsNeeded
{
    int colIndex = (int)self.components.weekday - 1; // starting weekday column
    int rowIndex = 4; // All months have 4 weeks / 28 days
    
    for (int i = 28; i < self.numDays; i++) {
        colIndex++;
        if (colIndex % 7 == 0) {
            colIndex = 0;
            rowIndex++;
        }
    }
    return colIndex == 0 ? rowIndex : rowIndex+1;
}

- (CXDurationPickerMonth)monthPickerDateFromDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:date];
    
    return (CXDurationPickerMonth) {
        components.year,
        components.month
    };
}

#pragma mark - Colors

- (void)setDayLabelsToColor:(UIColor *)color {
    for (int i = 0; i < 7; i++) {
        NSUInteger tag = 100 + i;
        
        UIView *view = [self viewWithTag:tag];
        
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *dayLabel = (UILabel *) view;
            
            [dayLabel setTextColor:self.dayLabelColor];
            
            [dayLabel setNeedsDisplay];
        }
    }
}

- (void)setDaysToColor:(UIColor *)color forKey:(NSString *)key {
    for (int i = 0; i < self.numDays; i++) {
        NSUInteger tag = 200 + i;
        
        UIView *view = [self viewWithTag:tag];
        
        if ([view isKindOfClass:[CXDurationPickerDayView class]]) {
            CXDurationPickerDayView *dayView = (CXDurationPickerDayView *) view;
            
            [dayView setValue:color forKey:key];
            
            [dayView setNeedsDisplay];
        }
    }
}

// Month-specific colors
//
- (void)setDayLabelColor:(UIColor *)color {
    _dayLabelColor = color;
    [self setDayLabelsToColor:_dayLabelColor];
}

// Day-specific colors
//
- (void)setDayBackgroundColor:(UIColor *)color {
    _dayBackgroundColor = color;
    [self setDaysToColor:_dayBackgroundColor forKey:@"dayBackgroundColor"];
}

- (void)setDayForegroundColor:(UIColor *)color {
    _dayForegroundColor = color;
    [self setDaysToColor:_dayForegroundColor forKey:@"dayForegroundColor"];
}

- (void)setDisabledDayBackgroundColor:(UIColor *)color {
    _disabledDayBackgroundColor = color;
    [self setDaysToColor:_disabledDayBackgroundColor forKey:@"disabledDayBackgroundColor"];
}

- (void)setDisabledDayForegroundColor:(UIColor *)color {
    _disabledDayBackgroundColor = color;
    [self setDaysToColor:_disabledDayBackgroundColor forKey:@"disabledDayForegroundColor"];
}

- (void)setGridColor:(UIColor *)color {
    _gridColor = color;
    [self setDaysToColor:_gridColor forKey:@"gridColor"];
}

- (void)setMonthLabelColor:(UIColor *)color {
    _monthLabelColor = color;
    [self.dateLabel setTextColor:self.monthLabelColor];
}

- (void)setTerminalBackgroundColor:(UIColor *)color {
    _terminalBackgroundColor = color;
    [self setDaysToColor:_terminalBackgroundColor forKey:@"terminalBackgroundColor"];
}

- (void)setTerminalForegroundColor:(UIColor *)color {
    _terminalForegroundColor = color;
    [self setDaysToColor:_terminalForegroundColor forKey:@"terminalForegroundColor"];
}

- (void)setTodayBackgroundColor:(UIColor *)color {
    _todayBackgroundColor = color;
    [self setDaysToColor:_todayBackgroundColor forKey:@"todayBackgroundColor"];
}

- (void)setTodayForegroundColor:(UIColor *)color {
    _todayForegroundColor = color;
    [self setDaysToColor:_todayForegroundColor forKey:@"todayForegroundColor"];
}

- (void)setTransitBackgroundColor:(UIColor *)color {
    _transitBackgroundColor = color;
    [self setDaysToColor:_transitBackgroundColor forKey:@"transitBackgroundColor"];
}

- (void)setTransitForegroundColor:(UIColor *)color {
    _transitForegroundColor = color;
    [self setDaysToColor:_transitForegroundColor forKey:@"transitForegroundColor"];
}

@end
