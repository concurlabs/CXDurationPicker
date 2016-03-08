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

#import "UIColor+CXDurationDefaults.h"

@implementation UIColor (Defaults)

#pragma mark - Month-specific Colors

+ (UIColor *)defaultDayLabelColor {
    return [UIColor colorWithRed:127/255.0 green:143/255.0 blue:151/255.0 alpha:1];
}

+ (UIColor *)defaultMonthLabelColor {
    return [UIColor colorWithRed:56/255.0 green:63/255.0 blue:70/255.0 alpha:1];
}

#pragma mark - Day-specific Colors

+ (UIColor *)defaultDayBackgroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)defaultDayForegroundColor {
    return [UIColor darkGrayColor];
}

+ (UIColor *)defaultDisabledDayBackgroundColor {
    return [UIColor colorWithRed:255/255.0
                           green:150/255.0
                            blue:150/255.0
                           alpha:0.1];
}

+ (UIColor *)defaultDisabledDayForegroundColor {
    return [UIColor darkGrayColor];
}

+ (UIColor *)defaultMonthBackgroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)defaultGridColor {
    return [UIColor grayColor];
}

+ (UIColor *)defaultTerminalBackgroundColor {
    return [UIColor colorWithRed:0
                           green:120/255.0
                            blue:200/255.0
                           alpha:1];
}

+ (UIColor *)defaultTerminalForegroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)defaultTodayBackgroundColor {
    return [UIColor colorWithRed:198/255.0
                           green:208/255.0
                            blue:214/255.0
                           alpha:0.5];
}

+ (UIColor *)defaultTodayForegroundColor {
    return [UIColor darkGrayColor];
}

+ (UIColor *)defaultTransitBackgroundColor {
    return [UIColor colorWithRed:0
                           green:120/255.0
                            blue:200/255.0
                           alpha:0.25];
}

+ (UIColor *)defaultTransitForegroundColor {
    return [UIColor darkGrayColor];
}

@end
