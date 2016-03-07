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

#import <CoreText/CoreText.h>

#import "CXDurationPickerDayView.h"
#import "CXDurationPickerUtils.h"
#import "UIColor+CXDurationDefaults.h"

@interface CXDurationPickerDayView ()

@end

@implementation CXDurationPickerDayView

- (void)baseInit {
    self.contentMode = UIViewContentModeRedraw;
    
    self.opaque = NO;
    
    self.isToday = NO;
    
    self.type = CXDurationPickerDayTypeNormal;
    
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
}

- (NSString *)description {
    return [CXDurationPickerUtils stringFromPickerDate:self.pickerDate];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1);
    
    // Draw highlighted background.
    //
    // If we're an overlap then don't draw the background as that will overwrite
    // any previous day grpahics.
    //
        if (self.isToday) {
            CGContextSetFillColorWithColor(context, self.todayBackgroundColor.CGColor);
            
            CGContextFillRect(context, CGRectMake(0.5, 0.5,
                                                  self.bounds.size.width - 1,
                                                  self.bounds.size.height - 1));
        } else if (self.isDisabled) {
            CGContextSetFillColorWithColor(context, self.disabledDayBackgroundColor.CGColor);
            
            CGContextFillRect(context, CGRectMake(0.5, 0.5,
                                                  self.bounds.size.width - 1,
                                                  self.bounds.size.height - 1));
        } else {
            CGContextSetFillColorWithColor(context, self.dayBackgroundColor.CGColor);
            
            CGContextFillRect(context, CGRectMake(0.5, 0.5,
                                                  self.bounds.size.width - 1,
                                                  self.bounds.size.height - 1));
        }
    
    // Draw calendar day border.
    //
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    
    CGContextStrokeRect(context, CGRectMake(0.5, 0.5,
                                            self.bounds.size.width - 1,
                                            self.bounds.size.height - 1));
    
    [self drawText:self.day];
    
#ifdef COMPONENTS_DEMO
    [self setIsAccessibilityElement:YES];
    
    if (self.accessibilityIdentifier.length == 0) {
        
        self.accessibilityIdentifier = [NSString stringWithFormat:@"%@ %@ %@",@(self.pickerDate.year).stringValue, @(self.pickerDate.month).stringValue, @(self.pickerDate.day).stringValue];
        
        NSLog(@"dateID:%@",self.accessibilityIdentifier);
        self.accessibilityValue = @(self.type).stringValue;
    }
#endif
    
}

- (void)drawText:(NSString *)label {
#ifdef COMPONENTS_DEMO
    [self setAccessibilityLabel:self.description];
#endif
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CTFontRef font = CTFontCreateUIFontForLanguage(kCTFontSystemFontType,
                                                   self.bounds.size.height / 3, NULL);
    
    CGFloat ascenderHeight = CTFontGetAscent(font);
    
    // Set foreground text color.
    //
    CGColorRef color;
    
    if (self.type == CXDurationPickerDayTypeStart
        || self.type == CXDurationPickerDayTypeEnd
        || self.type == CXDurationPickerDayTypeSingle
        || self.type == CXDurationPickerDayTypeOverlap) {
        color = self.terminalForegroundColor.CGColor;
    } else if (self.isDisabled) {
        color = self.disabledDayForegroundColor.CGColor;
    } else if (self.type == CXDurationPickerDayTypeTransit) {
        color = self.transitForegroundColor.CGColor;
    } else {
        if (self.isToday) {
            color = self.todayForegroundColor.CGColor;
        } else {
            color = self.dayForegroundColor.CGColor;
        }
        
    }
    
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)font, (id)kCTFontAttributeName,
                                    color, (id)kCTForegroundColorAttributeName,
                                    nil];
    
    NSAttributedString *stringToDraw = [[NSAttributedString alloc] initWithString:label
                                                                       attributes:attributesDict];
    
    
    // Flip the coordinate system.
    //
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGSize size = [self labelSize:stringToDraw];
    
    float labelWidth = size.width;
    
    // Draw rectangle for start day.
    //
    if (self.type == CXDurationPickerDayTypeStart) {
        float notBiggerThan = self.bounds.size.height * 0.60;
        float notSmallerThan = ascenderHeight + 5;
        
        float rectangleHeight = fmaxf(notBiggerThan, notSmallerThan);
        float rectangleWidth = self.bounds.size.width / 2;
        
        float rectangleY = (self.bounds.size.height - rectangleHeight) / 2;
        float rectangleX = rectangleWidth;
        
        CGContextSetFillColorWithColor(context, self.transitBackgroundColor.CGColor);
        
        CGContextFillRect(context, CGRectMake(rectangleX + 0.5,
                                              rectangleY + 0.5,
                                              rectangleWidth - 1,
                                              rectangleHeight - 1));
        
    } else if (self.type == CXDurationPickerDayTypeEnd) {
        float notBiggerThan = self.bounds.size.height * 0.60;
        float notSmallerThan = ascenderHeight + 5;
        
        float rectangleHeight = fmaxf(notBiggerThan, notSmallerThan);
        float rectangleWidth = self.bounds.size.width / 2;
        
        float rectangleY = (self.bounds.size.height - rectangleHeight) / 2;
        
        CGContextSetFillColorWithColor(context, self.transitBackgroundColor.CGColor);
        
        CGContextFillRect(context, CGRectMake(0.5,
                                              rectangleY + 0.5,
                                              rectangleWidth - 1,
                                              rectangleHeight - 1));
        
    } else if (self.type == CXDurationPickerDayTypeTransit) {
        
        if (self.roundedTerminals) {
            float notBiggerThan = self.bounds.size.height * 0.60;
            float notSmallerThan = ascenderHeight + 5;
            
            float rectangleHeight = fmaxf(notBiggerThan, notSmallerThan);
            
            float rectangleY = (self.bounds.size.height - rectangleHeight) / 2;
            
            CGContextSetFillColorWithColor(context, self.transitBackgroundColor.CGColor);
            
            CGContextFillRect(context, CGRectMake(0.5,
                                                  rectangleY + 0.5,
                                                  self.frame.size.width - 1,
                                                  rectangleHeight - 1));
        } else {
            CGContextSetFillColorWithColor(context, self.transitBackgroundColor.CGColor);
            
            CGContextFillRect(context, CGRectMake(0.5, 0.5,
                                                  self.bounds.size.width - 1,
                                                  self.bounds.size.height - 1));
        }
    }
    
    // Draw circle.
    //
    if (self.type == CXDurationPickerDayTypeStart
        || self.type == CXDurationPickerDayTypeEnd
        || self.type == CXDurationPickerDayTypeSingle
        || self.type == CXDurationPickerDayTypeOverlap) {
        
        if (self.roundedTerminals) {
            float notBiggerThan = self.bounds.size.height * 0.60;
            float notSmallerThan = ascenderHeight + 5;
            
            float circleDiameter = fmaxf(notBiggerThan, notSmallerThan);
            
            float circleX = (self.bounds.size.width - circleDiameter) / 2;
            float circleY = (self.bounds.size.height - circleDiameter) / 2;
            
            CGContextSetFillColorWithColor(context, self.terminalBackgroundColor.CGColor);
            
            CGContextBeginPath(context);
            CGContextAddEllipseInRect(context, CGRectMake(circleX, circleY, circleDiameter, circleDiameter));
            CGContextDrawPath(context, kCGPathFill);
        } else {
            CGContextSetFillColorWithColor(context, self.terminalBackgroundColor.CGColor);
            
            CGContextFillRect(context, CGRectMake(0.5, 0.5,
                                                  self.bounds.size.width - 1,
                                                  self.bounds.size.height - 1));
        }

    }
    
    if (self.type == CXDurationPickerDayTypeOverlap) {
        
        if (self.roundedTerminals) {
            float notBiggerThan = self.bounds.size.height * 0.80;
            float notSmallerThan = ascenderHeight + 7;
            
            float circleDiameter = fmaxf(notBiggerThan, notSmallerThan);
            float circleRadius = circleDiameter / 2;
            
            float circleX = (self.bounds.size.width - circleDiameter) / 2 + circleRadius;
            float circleY = (self.bounds.size.height - circleDiameter) / 2 + circleRadius;
            
            CGContextSetStrokeColorWithColor(context, self.terminalBackgroundColor.CGColor);
            CGContextSetLineWidth(context, 2);
            CGContextAddArc(context, circleX, circleY, circleRadius, 0, M_PI * 2, false);
            CGContextStrokePath(context);
        } else {
            CGContextSetFillColorWithColor(context, self.terminalBackgroundColor.CGColor);
            
            CGContextFillRect(context, CGRectMake(0.5, 0.5,
                                                  self.bounds.size.width - 1,
                                                  self.bounds.size.height - 1));
        }

        


    }
    
    // Draw day number.
    //
    float xOffset = (self.bounds.size.width - labelWidth) / 2;
    float yCenter = (self.bounds.size.height - ascenderHeight) / 2;
    
    // I can't find the right way to vertically align the text, but adding a couple DIPs here
    // makes it look right. :/
    //
    float yOffset = (yCenter + 3);
    
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)stringToDraw);
    CGContextSetTextPosition(context, xOffset, yOffset);
    CTLineDraw(line, context);
    
    CFRelease(line);
    CFRelease(font);
    
    
    self.accessibilityValue = @(self.type).stringValue;
}

- (BOOL)isAfter:(CXDurationPickerDate)date {
    NSDate *myDate = [CXDurationPickerUtils dateFromPickerDate:self.pickerDate];
    NSDate *otherDate = [CXDurationPickerUtils dateFromPickerDate:date];
    
    return [myDate timeIntervalSinceDate:otherDate] > 0;
}

- (BOOL)isBefore:(CXDurationPickerDate)date {
    NSDate *myDate = [CXDurationPickerUtils dateFromPickerDate:self.pickerDate];
    NSDate *otherDate = [CXDurationPickerUtils dateFromPickerDate:date];
    
    return [myDate timeIntervalSinceDate:otherDate] < 0;
}

- (BOOL)isBetween:(CXDurationPickerDate)startDate and:(CXDurationPickerDate)endDate {
    if (_pickerDate.year <= endDate.year
        && _pickerDate.month <= endDate.month
        && _pickerDate.day <= endDate.day
        && _pickerDate.year >= startDate.year
        && _pickerDate.month >= startDate.month
        && _pickerDate.day >= startDate.day) {
        
        return YES;
    }
    
    return NO;
}

- (BOOL)isPickerDate:(CXDurationPickerDate)pickerDate {
    return _pickerDate.year == pickerDate.year
    && _pickerDate.month == pickerDate.month
    && _pickerDate.day == pickerDate.day;
}

- (CGSize)labelSize:(NSAttributedString *)label {
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(label));
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                                                                        frameSetter,
                                                                        CFRangeMake(0, label.length),
                                                                        NULL,
                                                                        CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX),
                                                                        NULL
                                                                        );
    
    return suggestedSize;
}

- (void)setType:(CXDurationPickerDayType)type {
    _type = type;
    
    [self setNeedsDisplay];
}

@end
