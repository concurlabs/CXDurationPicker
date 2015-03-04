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

@interface CXDurationPickerView ()

@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSMutableArray *monthViews;
@property (strong, nonatomic) NSMutableArray *days;

@end

@implementation CXDurationPickerView

- (void)baseInit {
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
    if (indexPath.row == [tableView numberOfRowsInSection:0] - 3) {
        [self addMonthsAsync];
    }
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"CalendarViewCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CalendarViewCell"];
    }
    
    UIView *oldMonthView = [[cell.contentView subviews] firstObject];
    
    if (oldMonthView != nil) {
        [oldMonthView removeFromSuperview];
    }
    
    NSInteger row = indexPath.row;
    
    CXDurationPickerMonthView *v = [self monthViewForRow:row];
    
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

#pragma mark - CXCalendarMonthViewDelegate

- (void)monthView:(CXDurationPickerMonthView *)view daySelected:(CXDurationPickerDayView *)dayView {
    if (self.mode == CXDurationPickerModeStartDate) {
        if (![self isDurationValidForStart:dayView.pickerDate andEnd:_endDate]) {
            NSLog(@"Invalid duration");
            return;
        }
    } else if (self.mode == CXDurationPickerModeEndDate) {
        if (![self isDurationValidForStart:_startDate andEnd:dayView.pickerDate]) {
            NSLog(@"Invalid duration");
            return;
        }
    }
    
    if (self.delegate != nil) {
        if (self.mode == CXDurationPickerModeStartDate) {
            _startDate = dayView.pickerDate;
            [self.delegate calendarView:self startDateChanged:dayView.pickerDate];
        } else {
            _endDate = dayView.pickerDate;
            [self.delegate calendarView:self endDateChanged:dayView.pickerDate];
        }
    }
    
    for (CXDurationPickerDayView *dayView in self.days) {
        dayView.type = CXDurationPickerDayTypeNormal;
    }
    
    [self.days removeAllObjects];
    
    [self createDuration];
    
}

#pragma mark - Business

- (BOOL)isDurationValidForStart:(CXDurationPickerDate)startPickerDate andEnd:(CXDurationPickerDate)endPickerDate {
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

- (void)addMonths {
    NSUInteger latestMonthIndex = [self.monthViews count];
    
    for (int i = 0; i < 12; i++) {
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

- (void)createDuration {
    // Quick sanity test.
    //
    if (self.startDate.year == 0) {
        return;
    }
    
    if (self.endDate.year == 0) {
        return;
    }
    
    self.days = [self daysBetween:self.startDate and:self.endDate];
    
    CXDurationPickerDayView *day;
    
    day = (CXDurationPickerDayView *) [self.days firstObject];
    
    day.type = CXDurationPickerDayTypeStart;
    
    day = (CXDurationPickerDayView *) [self.days lastObject];
    
    day.type = CXDurationPickerDayTypeEnd;
    
    for (long i = 1, ii = [self.days count] - 1; i < ii; i++) {
        day = (CXDurationPickerDayView *) [self.days objectAtIndex:i];
        
        day.type = CXDurationPickerDayTypeTransit;
    }
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
    
    [self setStartDate:today];
    
    CXDurationPickerDate tomorrow = [self pickerDateForTomorrow];
    
    [self setEndDate:tomorrow];
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

- (void)setStartDate:(CXDurationPickerDate)startDate {
    _startDate = startDate;
    
    [self createDuration];
}

@end
