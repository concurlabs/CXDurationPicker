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

- (void)baseInit {
    self.monthTitleHeight = 16;
    self.weekTitleHeight = 12;
    
    self.days = [[NSMutableArray alloc] init];
    
    self.monthWidth = (floor(self.bounds.size.width / 7) * 7) - 6;
    
    self.monthOffset = (self.bounds.size.width - self.monthWidth) / 2;
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.calendar = [NSCalendar currentCalendar];
}

- (NSString *)description {
    return self.dateString;
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
    
    float cellSize = self.bounds.size.width / 7;
    
    self.cellWidth = floor(cellSize);
    self.cellHeight = floor(cellSize);
    
    self.dateLabel.frame = CGRectMake(self.monthOffset, 0,
                                      self.bounds.size.width - self.monthOffset,
                                      self.monthTitleHeight);
    
    float yOffset = self.monthTitleHeight + 10;
    
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
        
        UIView *dayView = [self viewWithTag:tag];
        
        dayView.frame = CGRectMake(x + self.monthOffset + xOffset,
                                   y + yOffset + yOffset2,
                                   self.cellWidth,
                                   self.cellHeight);
        
        colIndex++;
        
        if (colIndex % 7 == 0) {
            colIndex = 0;
            rowIndex++;
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    float cellSize = self.bounds.size.width / 7;
    
    self.cellWidth = floor(cellSize);
    self.cellHeight = floor(cellSize);
    
    NSUInteger height = 0;
    
    height += (self.monthTitleHeight + 10);
    height += (self.weekTitleHeight + 5);
    
    NSDate *date = [self dateForFirstDayInSection:self.monthIndex];
    NSUInteger numWeeks = [self numberOfWeeksForMonthOfDate:date];
    
    height += (numWeeks * self.cellHeight);
    
    height += 20; // bottom
    
    CGSize viewSize = CGSizeMake(self.bounds.size.width, height);
    
    return viewSize;
}

#pragma mark - Gesture recognizers

- (void)daySelected:(UITapGestureRecognizer *)recognizer {
    if (self.delegate != nil) {
        CXDurationPickerDayView *dayView = (CXDurationPickerDayView *)recognizer.view;
        
        [self.delegate monthView:self daySelected:dayView];
    }
}

#pragma mark - Business logic

- (BOOL)containsDate:(CXDurationPickerDate)pickerDate {
    if (self.pickerMonth.month == pickerDate.month
        && self.pickerMonth.year == pickerDate.year) {
        return YES;
    }
    
    return NO;
}

- (void)setupViews {
    self.dateString = [NSString stringWithFormat:@"%@", [self monthNameFromDate:self.date]];
    
    UIFont *dateFont = [UIFont fontWithName:@"HelveticaNeue" size:self.monthTitleHeight];
    
    self.dateLabel = [[UILabel alloc] init];
    
    [self.dateLabel setFont:dateFont];
    [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
    [self.dateLabel setTextColor:[UIColor colorWithRed:56/255.0 green:63/255.0 blue:70/255.0 alpha:1]];
    [self.dateLabel setText:self.dateString];
    
    [self addSubview:self.dateLabel];
    
    NSArray *days = @[@"SUN", @"MON", @"TUE", @"WED", @"THU", @"FRI", @"SAT", @"SUN"];
    
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
        [dayLabel setTextColor:[UIColor colorWithRed:127/255.0 green:143/255.0 blue:151/255.0 alpha:1]];
        [dayLabel setFont:dayFont];
        [dayLabel setText:days[i]];
        
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
        
        [self.days addObject:v];
        
        [self addSubview:v];
        
        if (colIndex % 7 == 0) {
            colIndex = 0;
            rowIndex++;
        }
    }
}

- (void)setMonthIndex:(NSInteger)index {
    //NSLog(@"set month index to %ld", (long) index);
    
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
    
    [dateFormatter setDateFormat:@"MMMM YYYY"];
    
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    
    return stringFromDate;
}

- (NSUInteger)numberOfWeeksForMonthOfDate:(NSDate *)date {
    
    NSDate *firstDayInMonth = [self.calendar
                               dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date]];
    
    NSDate *lastDayInMonth = [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = 1;
        dateComponents.day = -1;
        return dateComponents;
    })()) toDate:firstDayInMonth options:0];
    
    NSDate *fromSunday = [self.calendar dateFromComponents:((^{
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:firstDayInMonth];
        dateComponents.weekday = 1;
        return dateComponents;
    })())];
    
    NSDate *toSunday = [self.calendar dateFromComponents:((^{
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:lastDayInMonth];
        dateComponents.weekday = 1;
        return dateComponents;
    })())];
    
    return 1 + [self.calendar components:NSCalendarUnitWeekOfMonth
                                fromDate:fromSunday
                                  toDate:toSunday
                                 options:0].weekOfMonth;
    
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

/*
 - (void)setSelectedDayFromPickerDate:(CXDurationPickerDate)pickerDate {
 NSLog(@"picker date = %lu/%lu/%lu",
 (unsigned long)pickerDate.day,
 (unsigned long)pickerDate.month,
 (unsigned long)pickerDate.year);
 
 for (UIView *view in self.subviews) {
 if ([view isKindOfClass:[CXDurationPickerDayView class]]) {
 CXDurationPickerDayView *dayView = (CXDurationPickerDayView *) view;
 
 if ([dayView isPickerDate:pickerDate]) {
 NSLog(@"Setting today");
 dayView.isSelected = YES;
 }
 }
 }
 }
 */

@end
