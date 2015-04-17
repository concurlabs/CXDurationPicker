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

@class CXDurationModeSwitch;

@protocol CXDurationModeSwitchDelegate <NSObject>

- (void)modeSwitch:(CXDurationModeSwitch *)modeSwitch modeChanged:(CXDurationPickerMode)mode;

@end

@interface CXDurationModeSwitch : UIView

@property (assign, nonatomic) id<CXDurationModeSwitchDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *indicator;
@property (weak, nonatomic) IBOutlet UIView *button1;
@property (weak, nonatomic) IBOutlet UIView *button2;
@property (nonatomic) CXDurationPickerMode mode;

- (void)setStartDateString:(NSString *)startDateString;
- (void)setEndDateString:(NSString *)endDateString;

@end
