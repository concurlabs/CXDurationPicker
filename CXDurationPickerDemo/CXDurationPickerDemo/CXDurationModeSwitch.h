//
//  CXDurationModeSwitch.h
//  CalendarViewSample
//
//  Created by Richard Puckett on 3/6/15.
//  Copyright (c) 2015 Concur Creative Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CXDurationPickerDate.h"

@class CXDurationModeSwitch;

@protocol CXDurationModeSwitchDelegate <NSObject>

- (void)modeSwitch:(CXDurationModeSwitch *)modeSwitch modeChanged:(CXDurationPickerMode)mode;

@end

@interface CXDurationModeSwitch : UIView

@property (assign, nonatomic) id<CXDurationModeSwitchDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *indicator;
@property (weak, nonatomic) IBOutlet UIView *button1;
@property (weak, nonatomic) IBOutlet UIView *button2;
@property (readonly, nonatomic) CXDurationPickerMode mode;

- (void)setStartDateString:(NSString *)startDateString;
- (void)setEndDateString:(NSString *)endDateString;

@end
