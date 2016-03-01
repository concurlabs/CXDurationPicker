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

#import "CXDurationPickerDayView.h"
#import "CXDurationPickerMonthView.h"
#import "CXDurationPickerView.h"
#import "CXDurationPickerUtils.h"
#import "UIColor+CXDurationDefaults.h"

#define defaultTodayColor [UIColor colorWithRed:0.1f green:0.004f blue:0.3f alpha:0.3f]

@interface CXDurationPickerView ()

@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSMutableArray *monthViews;
@property (strong, nonatomic) NSMutableArray *days;

@end

@implementation CXDurationPickerView

#pragma mark - Lifecycle

- (void)baseInit {
    self.calendar = [NSCalendar currentCalendar];
    
    self.dayLabelColor = [UIColor defaultDayLabelColor];
    self.monthLabelColor = [UIColor defaultMonthLabelColor];
    
    self.dayBackgroundColor = [UIColor defaultDayBackgroundColor];
    self.dayForegroundColor = [UIColor defaultDayForegroundColor];
    self.disabledDayBackgroundColor = [UIColor defaultDisabledDayBackgroundColor];
    self.disabledDayForegroundColor = [UIColor defaultDisabledDayForegroundColor];
    self.gridColor = [UIColor defaultGridColor];
    self.terminalBackgroundColor = [UIColor defaultTerminalBackgroundColor];
    self.terminalForegroundColor = [UIColor defaultTerminalForegroundColor];
    self.todayBackgroundColor = [UIColor defaultTodayBackgroundColor];
    self.todayForegroundColor = [UIColor defaultTodayForegroundColor];
    self.transitBackgroundColor = [UIColor defaultTransitBackgroundColor];
    self.transitForegroundColor = [UIColor defaultTransitForegroundColor];
    self.roundedTerminals = YES;
    self.allowSelectionsInPast = NO;
    self.startDate = (CXDurationPickerDate) { 0, 0, 0 };
    self.endDate = (CXDurationPickerDate) { 0, 0, 0 };
    
    self.monthViews = [[NSMutableArray alloc] init];
    
    self.table = [[UITableView alloc] initWithFrame:self.bounds];
    
    [self addSubview:self.table];
    
    [self.table setDataSource:self];
    [self.table setDelegate:self];
    
    self.table.allowsSelection = NO;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.showsVerticalScrollIndicator = NO;
    
    [self addMonths];
    
    [self initWithDefaultDuration];
    
    [self scrollToToday:NO];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self baseInit];
    

    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self addMonths];
    
    self.table.frame = self.bounds;
    
    [self.table setNeedsLayout];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Infinite scroll. Load more months when we're "3" months from the end.
    //
#ifndef COMPONENTS_DEMO
    if (indexPath.row == [tableView numberOfRowsInSection:0] - 3) {
        [self addMonthsAsync];
    }
#endif
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"DurationPickerCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DurationPickerCell"];
    }
    
    UIView *oldMonthView = [[cell.contentView subviews] firstObject];
    
    if (oldMonthView != nil) {
        [oldMonthView removeFromSuperview];
    }
    
    NSInteger row = indexPath.row;
    
    CXDurationPickerMonthView *v = [self monthViewForRow:row];
    
    // Tell month view to disable days before today is user has requested it.
    //
    // The logic here is perhaps unnecessarily confusing...
    //
    if (self.allowSelectionsInPast == NO) {
        v.disableDaysBeforeToday = YES;
        if (!self.allowSelectionOfYesterdayAsStartDay) {
            v.disableYesterday = YES;
        } else {
            v.disableYesterday = NO;
        }
    } else {
        v.disableDaysBeforeToday = NO;
        v.disableYesterday = NO;
    }
    
    if (self.blockedDays && self.blockedDays.count > 0) {
        [v assignBlockedDays:self.blockedDays];
    }
    
    v.roundedTerminals = self.roundedTerminals;
    
    v.backgroundColor = self.backgroundColor;
    
    v.dayLabelColor = self.dayLabelColor;
    v.monthLabelColor = self.monthLabelColor;
    
    v.dayBackgroundColor = self.dayBackgroundColor;
    v.dayForegroundColor = self.dayForegroundColor;
    v.disabledDayBackgroundColor = self.disabledDayBackgroundColor;
    v.disabledDayForegroundColor = self.disabledDayForegroundColor;
    v.gridColor = self.gridColor;
    v.terminalBackgroundColor = self.terminalBackgroundColor;
    v.terminalForegroundColor = self.terminalForegroundColor;
    v.todayBackgroundColor = self.todayBackgroundColor;
    v.todayForegroundColor = self.todayForegroundColor;
    v.transitBackgroundColor = self.transitBackgroundColor;
    v.transitForegroundColor = self.transitForegroundColor;
    
    [cell.contentView addSubview:v];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.monthViews count];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CXDurationPickerMonthView *view = [self.monthViews objectAtIndex:indexPath.row];
    
    view.frame = self.bounds;
    [view sizeToFit];
    
    CGFloat cellHeight = view.frame.size.height;
    
    return cellHeight;
}

#pragma mark - CXCalendarMonthViewDelegate

- (void)monthView:(CXDurationPickerMonthView *)view daySelected:(CXDurationPickerDayView *)dayView {

    // Picker should not allow same day selection if flag is set to NO
    //
    // Duration Mode:
    //   Did user select a zero-day range?
    //
    // Single Mode:
    //   Did user select "today"?
    //
    if (!self.allowSelectionOnSameDay) {
        if (self.mode == CXDurationPickerModeStartDate) {
            if ([self isPickerDate:dayView.pickerDate equalTo:_endDate]) {
                return;
            }
        } else if (self.mode == CXDurationPickerModeEndDate) {
            if ([self isPickerDate:_startDate equalTo:dayView.pickerDate]) {
                return;
            }
        } else if (self.mode == CXDurationPickerModeSingleDate) {
            if ([self isPickerDate:_singleDate equalTo:dayView.pickerDate]) {
                return;
            }
        }
    }

    // Did user select a date before "today"? If so, is this allowed?
    //
    if (self.mode == CXDurationPickerModeStartDate) {
        if ([self isPickerDateInPast:dayView.pickerDate]) {
            if (!self.allowSelectionsInPast) {
                if ([self isPickerDateYesterday:dayView.pickerDate]) {
                    if (!self.allowSelectionOfYesterdayAsStartDay) {
                        if ([self.delegate respondsToSelector:@selector(durationPicker:didSelectDateInPast:forMode:)]) {
                            [self.delegate durationPicker:self didSelectDateInPast:dayView.pickerDate forMode:_mode];
                        }
                        return;
                    }
                }
                else {
                    if ([self.delegate respondsToSelector:@selector(durationPicker:didSelectDateInPast:forMode:)]) {
                        [self.delegate durationPicker:self didSelectDateInPast:dayView.pickerDate forMode:_mode];
                    }
                    return;
                }
            }
        }
    } else if (self.mode == CXDurationPickerModeEndDate) {
        if ([self isPickerDateInPast:dayView.pickerDate]) {
            if (!self.allowSelectionsInPast) {
                if ([self.delegate respondsToSelector:@selector(durationPicker:didSelectDateInPast:forMode:)]) {
                    [self.delegate durationPicker:self didSelectDateInPast:dayView.pickerDate forMode:_mode];
                }
                return;
            }
        }
    } else if (self.mode == CXDurationPickerModeSingleDate) {
        if ([self isPickerDateInPast:dayView.pickerDate]) {
            if (!self.allowSelectionsInPast) {
                if ([self.delegate respondsToSelector:@selector(durationPicker:didSelectDateInPast:forMode:)]) {
                    [self.delegate durationPicker:self didSelectDateInPast:dayView.pickerDate forMode:_mode];
                }
                return;
            }
        }
    }
    
    // Duration Mode:
    //   If user selected a start date which occurs after current end date, or
    //   If user selected a end date which occurs before current start date
    //
    if (self.mode == CXDurationPickerModeStartDate) {
        if (![self isDurationValidForStartPickerDate:dayView.pickerDate andEndPickerDate:_endDate]) {
            if ([self.delegate respondsToSelector:@selector(durationPicker:invalidStartDateSelected:)]) {
                [self.delegate durationPicker:self invalidStartDateSelected:dayView.pickerDate];
            }
            return;
        }
    } else if (self.mode == CXDurationPickerModeEndDate) {
        if (![self isDurationValidForStartPickerDate:_startDate andEndPickerDate:dayView.pickerDate]) {
            if ([self.delegate respondsToSelector:@selector(durationPicker:invalidEndDateSelected:)]) {
                [self.delegate durationPicker:self invalidEndDateSelected:dayView.pickerDate];
            }
            return;
        }
    }
    
    // Notify delegate of date changes.
    //
    if (self.delegate != nil) {
        if (self.mode == CXDurationPickerModeStartDate) {
            _startDate = dayView.pickerDate;
            [self.delegate durationPicker:self startDateChanged:dayView.pickerDate];
        } else if (self.mode == CXDurationPickerModeEndDate) {
            _endDate = dayView.pickerDate;
            [self.delegate durationPicker:self endDateChanged:dayView.pickerDate];
        } else if (self.mode == CXDurationPickerModeSingleDate) {
            [self changeSingleDateForDayView:dayView];
            [self.delegate durationPicker:self singleDateChanged:dayView.pickerDate];
        }
    }
    
    // Duration Mode:
    //    Update the duration.
    //
    if (self.mode == CXDurationPickerModeStartDate || self.mode == CXDurationPickerModeEndDate) {
        [self clearCurrentDuration];
        [self createDuration];
    }
}

#pragma mark - Public API

- (void)scrollToStartMonth:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *path = [self indexPathForPickerDate:self.startDate];
        
        if (path) {
            [self.table scrollToRowAtIndexPath:path
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:animated];
        }
    });
}

- (void)scrollToToday:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *path = [NSIndexPath indexPathForRow:12 inSection:0];
        
        if (path) {
            [self.table scrollToRowAtIndexPath:path
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:animated];
        }
    });
}

- (void)setStartDate:(NSDate *)date withDuration:(NSUInteger)days {
    CXDurationPickerDate pickerDate = [CXDurationPickerUtils pickerDateFromDate:date];
    
    [self setStartPickerDate:pickerDate withDuration:days];
}

- (void)setStartPickerDate:(CXDurationPickerDate)pickerDate withDuration:(NSUInteger)days {
    [self clearCurrentDuration];
    
    _startDate = pickerDate;
    
    _endDate = [CXDurationPickerUtils pickerDateShiftedByDays:days fromPickerDate:pickerDate];
    
    [self createDuration];
}

- (void)shiftDurationToEndPickerDate:(CXDurationPickerDate)pickerDate {
    NSError *error;
    
    [self shiftDurationToEndPickerDate:pickerDate error:&error];
}

- (void)shiftDurationToStartPickerDate:(CXDurationPickerDate)pickerDate {
    NSError *error;
    
    [self shiftDurationToStartPickerDate:pickerDate error:&error];
}

- (BOOL)shiftDurationToEndPickerDate:(CXDurationPickerDate)pickerDate error:(NSError **)error {
    // Convert picker-dates to NSDates so we easily can do some calcs on them.
    //
    NSDate *d1 = [CXDurationPickerUtils dateFromPickerDate:self.startDate];
    NSDate *d2 = [CXDurationPickerUtils dateFromPickerDate:self.endDate];
    NSDate *n1 = [CXDurationPickerUtils dateFromPickerDate:pickerDate];
    
    // Calculate number of days in current duration, accounting for days in month.
    //
    NSDateComponents *diff = [self.calendar
                              components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                              fromDate:d2 toDate:d1 options:0];

    // Calculate new ending date by adding difference.
    //
    NSDate *n2 = [self.calendar dateByAddingComponents:diff toDate:n1 options:0];
    
    // Convert back to our convenience model.
    //
    CXDurationPickerDate newStartDate = [CXDurationPickerUtils pickerDateFromDate:n2];
    
    if ([self isPickerDateInPast:newStartDate] && !self.allowSelectionsInPast) {
        NSMutableDictionary *details = [NSMutableDictionary dictionary];
        
        [details setValue:@"Unable to set start date in the past." forKey:NSLocalizedDescriptionKey];
        
        *error = [NSError errorWithDomain:@"CXDurationPicker" code:100 userInfo:details];
        
        return NO;
    }
    
    [self clearCurrentDuration];
    
    _startDate.day = newStartDate.day;
    _startDate.month = newStartDate.month;
    _startDate.year = newStartDate.year;
    
    _endDate.day = pickerDate.day;
    _endDate.month = pickerDate.month;
    _endDate.year = pickerDate.year;
    
    [self createDuration];
    
    return YES;
}

- (BOOL)shiftDurationToStartPickerDate:(CXDurationPickerDate)pickerDate error:(NSError **)error {
    [self clearCurrentDuration];
    
    // Convert picker-dates to NSDates so we easily can do some calcs on them.
    //
    NSDate *d1 = [CXDurationPickerUtils dateFromPickerDate:self.startDate];
    NSDate *d2 = [CXDurationPickerUtils dateFromPickerDate:self.endDate];
    NSDate *n1 = [CXDurationPickerUtils dateFromPickerDate:pickerDate];
    
    // Calculate number of days in current duration, accounting for days in month.
    //
    NSDateComponents *diff = [self.calendar
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:d1 toDate:d2 options:0];

    // Calculate new ending date by adding difference.
    //
    NSDate *n2 = [self.calendar dateByAddingComponents:diff toDate:n1 options:0];
    
    // Convert back to our convenience model.
    //
    CXDurationPickerDate newEndDate = [CXDurationPickerUtils pickerDateFromDate:n2];
    
    _startDate.day = pickerDate.day;
    _startDate.month = pickerDate.month;
    _startDate.year = pickerDate.year;

    _endDate.day = newEndDate.day;
    _endDate.month = newEndDate.month;
    _endDate.year = newEndDate.year;
    
    [self createDuration];
    
    return YES;
}

#pragma mark - Internal

- (void)addMonths {
    NSUInteger latestMonthIndex = [self.monthViews count];
    
    for (int i = 0; i < 24; i++) {
        CXDurationPickerMonthView *view = [[CXDurationPickerMonthView alloc] initWithFrame:self.bounds];
        
        view.padding = UIEdgeInsetsMake(5, 0, 20, 0);
        
        view.monthIndex = latestMonthIndex + i;
        
        view.delegate = self;
        
        [view sizeToFit];
        
        [self.monthViews addObject:view];
    }
    
    [self.table reloadData];
}

- (void)addMonthsAsync {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addMonths];
        });
    });
}

- (void)changeSingleDateForDayView:(CXDurationPickerDayView *)dayView {
    CXDurationPickerDayView *oldDayView = [self dayForPickerDate:self.singleDate];
    oldDayView.type = CXDurationPickerDayTypeNormal;
    
    dayView.type = CXDurationPickerDayTypeSingle;
    
    self.singleDate = dayView.pickerDate;
}

- (void)clearCurrentDuration {
    for (long i = 0, ii = [self.days count]; i < ii; i++) {
        CXDurationPickerDayView *day = (CXDurationPickerDayView *) [self.days objectAtIndex:i];
        
        day.type = CXDurationPickerDayTypeNormal;
    }
}

- (void)clearSingle {
    CXDurationPickerDayView *oldDayView = [self dayForPickerDate:self.singleDate];
    
    oldDayView.type = CXDurationPickerDayTypeNormal;
    
    oldDayView = nil;
}

- (void)createDuration {
    // Quick sanity test.
    //
    if (self.startDate.year == 0) {
        return;
    }
    
    if (self.endDate.year == 0) {
        return;
    }
    
    [self clearCurrentDuration];
    
    self.days = [self daysBetween:self.startDate and:self.endDate];
    
    CXDurationPickerDayView *day;
    
    if (self.days.count > 1) {
        day = (CXDurationPickerDayView *) [self.days firstObject];
    
        day.type = CXDurationPickerDayTypeStart;
    }
    
    day = (CXDurationPickerDayView *) [self.days lastObject];
    
    if (self.days.count == 1) {
        day.type = CXDurationPickerDayTypeOverlap;
    } else {
        day.type = CXDurationPickerDayTypeEnd;
    }
    
    for (long i = 1, ii = [self.days count] - 1; i < ii; i++) {
        day = (CXDurationPickerDayView *) [self.days objectAtIndex:i];
        
        day.type = CXDurationPickerDayTypeTransit;
    }
}

- (void)createSingle {
    CXDurationPickerDate today = [self pickerDateForToday];
    
    self.singleDate = today;
    
    CXDurationPickerDayView *dayView = [self dayForPickerDate:self.singleDate];
    
    dayView.type = CXDurationPickerDayTypeSingle;
}

- (CXDurationPickerDayView *)dayForPickerDate:(CXDurationPickerDate)pickerDate {
    if (pickerDate.year == 0) {
        return nil;
    }
    
    CXDurationPickerDayView *day;
    
    for (CXDurationPickerMonthView *monthView in self.monthViews) {
        if ([monthView containsDate:pickerDate]) {
            day = [monthView dayForPickerDate:pickerDate];
            break;
        }
    }
    
    return day;
}

- (NSMutableArray *)daysBetween:(CXDurationPickerDate)startDate and:(CXDurationPickerDate)endDate {
    BOOL searchingForStartMonth = YES;
    
    NSMutableArray *days = [[NSMutableArray alloc] init];
    
    for (CXDurationPickerMonthView *monthView in self.monthViews) {
        if (searchingForStartMonth) {
            if ([monthView containsDate:startDate]) {
                [days addObjectsFromArray:[self daysForMonthView:monthView forStartDate:startDate andEndDate:endDate]];
                
                searchingForStartMonth = NO;
                
                if ([monthView containsDate:endDate]) {
                    break;
                }
                
                continue;
            }
            
        }
        
        [days addObjectsFromArray:[self daysForMonthView:monthView forStartDate:startDate andEndDate:endDate]];
        
        if ([monthView containsDate:endDate]) {
            break;
        }
    }
    
    return days;
}

- (NSArray *)daysForMonthView:(CXDurationPickerMonthView *)monthView
                 forStartDate:(CXDurationPickerDate)startDate
                   andEndDate:(CXDurationPickerDate)endDate {
    
    NSMutableArray *days = [NSMutableArray new];
    
    NSArray *dayViews = monthView.days;
    
    for (CXDurationPickerDayView *dayView in dayViews) {
        if ([dayView isBefore:startDate]) {
            continue;
        } else if ([dayView isAfter:endDate]) {
            break;
        } else {
            [days addObject:dayView];
        }
    }
    
    return days;
}

- (void)initWithDefaultDuration {
    CXDurationPickerDate today = [self pickerDateForToday];
    
    _startDate = today;
    
    CXDurationPickerDate tomorrow = [self pickerDateForTomorrow];
    
    _endDate = tomorrow;
    
    [self createDuration];
}

- (BOOL)isPickerDate:(CXDurationPickerDate)startPickerDate
             equalTo:(CXDurationPickerDate)endPickerDate {
    
    NSDate *startDate = [CXDurationPickerUtils dateFromPickerDate:startPickerDate];
    NSDate *endDate = [CXDurationPickerUtils dateFromPickerDate:endPickerDate];
    
    if ([startDate timeIntervalSinceDate:endDate] == 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isPickerDateInPast:(CXDurationPickerDate)pickerDate {
    NSDate *today = [CXDurationPickerUtils today];
    NSDate *date = [CXDurationPickerUtils dateFromPickerDate:pickerDate];
    
    NSTimeInterval interval = [date timeIntervalSinceDate:today];
    
    if (interval < 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isPickerDateYesterday:(CXDurationPickerDate)pickerDate {
    BOOL isYesterday = [CXDurationPickerUtils isPickerDateYesterday:pickerDate];
    return isYesterday;
}

- (BOOL)isDurationValidForStartPickerDate:(CXDurationPickerDate)startPickerDate
                         andEndPickerDate:(CXDurationPickerDate)endPickerDate {
    
    NSDate *startDate = [CXDurationPickerUtils dateFromPickerDate:startPickerDate];
    NSDate *endDate = [CXDurationPickerUtils dateFromPickerDate:endPickerDate];
    
    if ([startDate timeIntervalSinceDate:endDate] > 0) {
        return NO;
    }
    
    if ([endDate timeIntervalSinceDate:startDate] < 0) {
        return NO;
    }
    
    return YES;
}

- (NSIndexPath *)indexPathForPickerDate:(CXDurationPickerDate)pickerDate {
    CXDurationPickerMonthView *monthView = [self monthForPickerDate:pickerDate];
    
    if (monthView) {
        return [NSIndexPath indexPathForRow:monthView.monthIndex inSection:0];
    } else {
        return nil;
    }
}

- (CXDurationPickerMonthView *)monthForPickerDate:(CXDurationPickerDate)pickerDate {
    if (pickerDate.year == 0) {
        return nil;
    }
    
    CXDurationPickerMonthView *month;
    
    for (CXDurationPickerMonthView *monthView in self.monthViews) {
        if ([monthView containsDate:pickerDate]) {
            month = monthView;
            break;
        }
    }
    
    return month;
}

- (CXDurationPickerMonthView *)monthViewForRow:(NSInteger)row {
    CXDurationPickerMonthView *view;
    
    if (row >= [self.monthViews count]) {
        view = [[CXDurationPickerMonthView alloc] initWithFrame:self.bounds];
        
        view.monthIndex = row;
        
        [view sizeToFit];
    } else {
        view = [self.monthViews objectAtIndex:row];
    }
    
    return view;
}

- (CXDurationPickerDate)pickerDateBetweenStartDate:(NSDate*)startDate andEndDate:(NSDate*)endDate {
    NSDate *d1;
    NSDate *d2;
    
    [self.calendar rangeOfUnit:NSCalendarUnitDay startDate:&d1
                      interval:nil forDate:startDate];
    
    [self.calendar rangeOfUnit:NSCalendarUnitDay startDate:&d2
                      interval:nil forDate:endDate];
    
    NSDateComponents *components = [self.calendar
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:d1 toDate:d2 options:0];
    
    
    return (CXDurationPickerDate) {
        components.year,
        components.month,
        components.day
    };
}

- (CXDurationPickerDate)pickerDateForToday {
    NSDate *todayDate = [NSDate date];
    
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar]
                                         components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                         fromDate:todayDate];
    
    CXDurationPickerDate todayPickerDate;
    
    todayPickerDate.day = todayComponents.day;
    todayPickerDate.month = todayComponents.month;
    todayPickerDate.year = todayComponents.year;
    
    return todayPickerDate;
}


- (CXDurationPickerDate)pickerDateForTomorrow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *todayDate = [NSDate date];
    
    NSDateComponents *components = [NSDateComponents new];
    components.day = 2;
    //components.month = 1;
    
    NSDate *tomorrowDate = [calendar dateByAddingComponents:components toDate:todayDate options:0];
    
    CXDurationPickerDate pickerDate = [CXDurationPickerUtils pickerDateFromDate:tomorrowDate];
    
    return pickerDate;
}

- (void)setEndDate:(CXDurationPickerDate)endDate {
    _endDate = endDate;
    
    [self createDuration];
}

- (void)setType:(CXDurationPickerType)type {
    if (type == CXDurationPickerTypeSingle) {
        [self clearCurrentDuration];
        [self createSingle];
        self.mode = CXDurationPickerModeSingleDate;
    } else {
        [self clearSingle];
        [self initWithDefaultDuration];
        [self createDuration];
        self.mode = CXDurationPickerModeStartDate;
    }
    
    _type = type;
}

- (void)setStartDate:(CXDurationPickerDate)startDate {
    _startDate = startDate;
    
    [self createDuration];
}

#pragma mark - Colors

- (void)setDayLabelColor:(UIColor *)color {
    _dayLabelColor = color;
    [self.table reloadData];
}

- (void)setMonthLabelColor:(UIColor *)color {
    _monthLabelColor = color;
    [self.table reloadData];
}

- (void)setBackgroundColor:(UIColor *)color {
    [super setBackgroundColor:color];
    
    [self.table reloadData];
}

- (void)setDisabledDayBackgroundColor:(UIColor *)color {
    _disabledDayBackgroundColor = color;
    [self.table reloadData];
}

- (void)setDisabledDayForegroundColor:(UIColor *)color {
    _disabledDayForegroundColor = color;
    [self.table reloadData];
}

- (void)setGridColor:(UIColor *)color {
    _gridColor = color;
    [self.table reloadData];
}

- (void)setTerminalBackgroundColor:(UIColor *)color {
    _terminalBackgroundColor = color;
    [self.table reloadData];
}

- (void)setTerminalForegroundColor:(UIColor *)color {
    _terminalForegroundColor = color;
    [self.table reloadData];
}

- (void)setTodayBackgroundColor:(UIColor *)color {
    _todayBackgroundColor = color;
    [self.table reloadData];
}

- (void)setTodayForegroundColor:(UIColor *)color {
    _todayForegroundColor = color;
    [self.table reloadData];
}

- (void)setTransitBackgroundColor:(UIColor *)color {
    _transitBackgroundColor = color;
    [self.table reloadData];
}

- (void)setTransitForegroundColor:(UIColor *)color {
    _transitForegroundColor = color;
    [self.table reloadData];
}

@end
