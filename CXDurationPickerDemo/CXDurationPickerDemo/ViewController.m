//
//  ViewController.m
//  CXDurationPickerDemo
//
//  Created by Richard Puckett on 3/8/15.
//  Copyright (c) 2015 Concur Labs. All rights reserved.
//

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
}

#pragma mark - CXDurationModeSwitchDelegate

- (void)modeSwitch:(CXDurationModeSwitch *)modeSwitch modeChanged:(CXDurationPickerMode)mode {
    self.picker.mode = mode;
}

#pragma mark - CXDurationPickerViewDelegate

- (void)durationPicker:(CXDurationPickerView *)durationPicker endDateChanged:(CXDurationPickerDate)pickerDate {
    [self.switcher setEndDateString:[CXDurationPickerUtils stringFromPickerDate:pickerDate]];
}

- (void)durationPicker:(CXDurationPickerView *)durationPicker startDateChanged:(CXDurationPickerDate)pickerDate {
    [self.switcher setStartDateString:[CXDurationPickerUtils stringFromPickerDate:pickerDate]];
}

@end
