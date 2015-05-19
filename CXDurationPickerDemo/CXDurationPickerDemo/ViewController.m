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

#import "CXDurationPickerUtils.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabView.delegate = self;
    self.picker.delegate = self;
    
    self.picker.mode = CXDurationPickerModeStartDate;
    
//    CXDurationPickerDate endPickerDate;
//    endPickerDate.day = 23;
//    endPickerDate.month = 5;
//    endPickerDate.year = 2015;
//    
//    [self.picker setStartDate:endPickerDate];
//    
//    self.picker.mode = CXDurationPickerModeStartDate;
//    
//    CXDurationPickerDate startPickerDate;
//    startPickerDate.day = 19;
//    startPickerDate.month = 5;
//    startPickerDate.year = 2015;
//    
//    [self.picker setStartDate:startPickerDate];
//
//    [self.picker setStartPickerDate:d withDuration:5];
    
    [self synchronizeComponents];
}

#pragma mark - CXTabViewDelegate

- (void)tabView:(CXTabView *)tabView didSelectMode:(CXTabViewMode)mode {
    switch (mode) {
        case CXTabViewModeStart:
            NSLog(@"Selected start mode");
            self.picker.mode = CXDurationPickerModeStartDate;
            break;
        case CXTabViewModeEnd:
            NSLog(@"Selected end mode");
            self.picker.mode = CXDurationPickerModeEndDate;
            break;
    }
}

#pragma mark - CXDurationPickerViewDelegate

- (void)durationPicker:(CXDurationPickerView *)durationPicker endDateChanged:(CXDurationPickerDate)pickerDate {
    self.tabView.durationEndString = [CXDurationPickerUtils stringFromPickerDate:pickerDate];
}

- (void)durationPicker:(CXDurationPickerView *)durationPicker singleDateChanged:(CXDurationPickerDate)pickerDate {
    self.singleDateViewLabel.text = [CXDurationPickerUtils stringFromPickerDate:pickerDate];
}

- (void)durationPicker:(CXDurationPickerView *)durationPicker startDateChanged:(CXDurationPickerDate)pickerDate {
    self.tabView.durationStartString = [CXDurationPickerUtils stringFromPickerDate:pickerDate];
}

#pragma mark - CXDurationPickerViewDelegate Optionals

- (void)durationPicker:(CXDurationPickerView *)durationPicker invalidEndDateSelected:(CXDurationPickerDate)date {
    NSLog(@"Invalid end date selected.");
    
    NSError *error;
    
    BOOL didShift = [self.picker shiftDurationToEndPickerDate:date error:&error];
    
    if (didShift) {
        [self synchronizeComponents];
    } else {
        NSLog(@"Unable to shift end date: %@", error.localizedDescription);
    }
}

- (void)durationPicker:(CXDurationPickerView *)durationPicker invalidStartDateSelected:(CXDurationPickerDate)date {
    NSLog(@"Invalid start date selected.");
    
    NSError *error;
    
    BOOL didShift = [self.picker shiftDurationToStartPickerDate:date error:&error];
    
    if (didShift) {
        [self synchronizeComponents];
    } else {
        NSLog(@"Unable to shift start date: %@", error.localizedDescription);
    }
}

- (void)durationPicker:(CXDurationPickerView *)durationPicker
   didSelectDateInPast:(CXDurationPickerDate)date
               forMode:(CXDurationPickerMode)mode {
    
    NSLog(@"Date was selected in the past. Ignoring.");
}

#pragma mark - Segmented Mode Switcher

- (IBAction)segmentedModeSwitcherChanged {
    if (self.segmentedModeSwitcher.selectedSegmentIndex == 0) {
        self.tabView.alpha = 1;
        self.singleDateView.alpha = 0;
        self.picker.type = CXDurationPickerTypeDuration;
        self.tabView.mode = CXTabViewModeStart;
    } else if (self.segmentedModeSwitcher.selectedSegmentIndex == 1) {
        self.tabView.alpha = 0;
        self.singleDateView.alpha = 1;
        self.picker.type = CXDurationPickerTypeSingle;
    }
    
    [self synchronizeComponents];
}

#pragma mark - Utilities

- (void)synchronizeComponents {
    if (self.segmentedModeSwitcher.selectedSegmentIndex == 0) {
        [self synchronizeRange];
    } else if (self.segmentedModeSwitcher.selectedSegmentIndex == 1) {
        [self synchronizeSingle];
    }
}

- (void)synchronizeRange {
    CXDurationPickerDate startDate = self.picker.startDate;
    self.tabView.durationStartString = [CXDurationPickerUtils stringFromPickerDate:startDate];
    
    CXDurationPickerDate endDate = self.picker.endDate;
    self.tabView.durationEndString = [CXDurationPickerUtils stringFromPickerDate:endDate];
}

- (void)synchronizeSingle {
    CXDurationPickerDate pickerDate = self.picker.singleDate;
    self.singleDateViewLabel.text = [CXDurationPickerUtils stringFromPickerDate:pickerDate];
}

@end
