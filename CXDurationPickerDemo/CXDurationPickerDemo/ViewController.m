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
    
    self.switcher.delegate = self;
    self.picker.delegate = self;
    
    self.picker.mode = self.switcher.mode;
    
    [self synchronizeComponents];
}

#pragma mark - CXDurationModeSwitchDelegate

- (void)modeSwitch:(CXDurationModeSwitch *)modeSwitch modeChanged:(CXDurationPickerMode)mode {
    self.picker.mode = mode;
}

#pragma mark - CXDurationPickerViewDelegate

- (void)durationPicker:(CXDurationPickerView *)durationPicker endDateChanged:(CXDurationPickerDate)pickerDate {
    [self.switcher setEndDateString:[CXDurationPickerUtils stringFromPickerDate:pickerDate]];
}

// For this demo, we show how to automatically adjust the mode switch (and mode)
// programmatically. Once user selects start date we switch to end date mode.
//
- (void)durationPicker:(CXDurationPickerView *)durationPicker startDateChanged:(CXDurationPickerDate)pickerDate {
    [self.switcher setStartDateString:[CXDurationPickerUtils stringFromPickerDate:pickerDate]];
    [self.switcher setMode:CXDurationPickerModeEndDate];
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
    
    [self.switcher setMode:CXDurationPickerModeEndDate];
}

- (void)durationPicker:(CXDurationPickerView *)durationPicker
   didSelectDateInPast:(CXDurationPickerDate)date
               forMode:(CXDurationPickerMode)mode {
    
    NSLog(@"Date was selected in the past. Ignoring.");
}

#pragma mark - Utilities

- (void)synchronizeComponents {
    CXDurationPickerDate startDate = self.picker.startDate;
    [self.switcher setStartDateString:[CXDurationPickerUtils stringFromPickerDate:startDate]];
    
    CXDurationPickerDate endDate = self.picker.endDate;
    [self.switcher setEndDateString:[CXDurationPickerUtils stringFromPickerDate:endDate]];
}

@end
