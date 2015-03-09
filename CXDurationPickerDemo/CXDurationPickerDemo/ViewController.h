//
//  ViewController.h
//  CXDurationPickerDemo
//
//  Created by Richard Puckett on 3/8/15.
//  Copyright (c) 2015 Concur Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CXDurationModeSwitch.h"
#import "CXDurationPickerView.h"

@interface ViewController : UIViewController <CXDurationModeSwitchDelegate, CXDurationPickerViewDelegate>

@property (weak, nonatomic) IBOutlet CXDurationModeSwitch *switcher;
@property (weak, nonatomic) IBOutlet CXDurationPickerView *picker;

@end

