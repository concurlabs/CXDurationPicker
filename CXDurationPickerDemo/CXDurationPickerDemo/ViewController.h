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
#import <CXTabView/CXTabView.h>

#import "CXDurationPickerView.h"

@interface ViewController : UIViewController <CXTabViewDelegate, CXDurationPickerViewDelegate>

@property (weak, nonatomic) IBOutlet CXTabView *tabView;
@property (weak, nonatomic) IBOutlet CXDurationPickerView *picker;
@property (weak, nonatomic) IBOutlet UIView *singleDateView;
@property (weak, nonatomic) IBOutlet UILabel *singleDateViewLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedModeSwitcher;

@end

