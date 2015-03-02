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

@interface CXDurationPickerDayView ()

@end

@implementation CXDurationPickerDayView

- (void)baseInit {
    self.opaque = NO;
    
    self.isToday = NO;
    
    self.type = CXDurationPickerDayTypeNormal;
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
    if (self.isToday) {
        CGColorRef background = [[UIColor colorWithRed:198/255.0 green:208/255.0 blue:214/255.0 alpha:0.5] CGColor];
        
        CGContextSetFillColorWithColor(context, background);
        
        CGContextFillRect(context, CGRectMake(0.5, 0.5, self.bounds.size.width - 1, self.bounds.size.height - 1));
    }
    
    // Draw calendar day border.
    //
    CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
    
    CGContextStrokeRect(context, CGRectMake(0.5, 0.5, self.bounds.size.width - 1, self.bounds.size.height - 1));
    
    [self drawText:self.day];
}

- (void)drawText:(NSString *)label {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CTFontRef font = CTFontCreateUIFontForLanguage(kCTFontSystemFontType,
                                                        14.0, NULL);
    
    CGFloat ascenderHeight = CTFontGetAscent(font);
    
    // Set foreground text color.
    //
    CGColorRef color;
    
    if (self.type == CXDurationPickerDayTypeStart || self.type == CXDurationPickerDayTypeEnd) {
        color = [UIColor whiteColor].CGColor;
    } else {
        color = [UIColor blackColor].CGColor;
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
        float a = labelWidth + 15;
        float b = ascenderHeight + 15;
        
        float rectangleHeight = fmaxf(a, b);
        float rectangleWidth = self.bounds.size.width / 2;
        
        float rectangleY = (self.bounds.size.height - rectangleHeight) / 2;
        float rectangleX = rectangleWidth;
        
        CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0
                                                                 green:120/255.0
                                                                  blue:200/255.0
                                                                 alpha:0.25] CGColor]);
        
        CGContextFillRect(context, CGRectMake(rectangleX + 0.5,
                                              rectangleY + 0.5,
                                              rectangleWidth - 1,
                                              rectangleHeight - 1));
    } else if (self.type == CXDurationPickerDayTypeEnd) {
        float a = labelWidth + 15;
        float b = ascenderHeight + 15;
        
        float rectangleHeight = fmaxf(a, b);
        float rectangleWidth = self.bounds.size.width / 2;
        
        float rectangleY = (self.bounds.size.height - rectangleHeight) / 2;
        
        CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0
                                                                 green:120/255.0
                                                                  blue:200/255.0
                                                                 alpha:0.25] CGColor]);
        
        CGContextFillRect(context, CGRectMake(0.5,
                                              rectangleY + 0.5,
                                              rectangleWidth - 1,
                                              rectangleHeight - 1));
    } else if (self.type == CXDurationPickerDayTypeTransit) {
        float a = labelWidth + 15;
        float b = ascenderHeight + 15;
        
        float rectangleHeight = fmaxf(a, b);
        
        float rectangleY = (self.bounds.size.height - rectangleHeight) / 2;
        
        CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0
                                                                 green:120/255.0
                                                                  blue:200/255.0
                                                                 alpha:0.25] CGColor]);
        
        CGContextFillRect(context, CGRectMake(0.5,
                                              rectangleY + 0.5,
                                              self.frame.size.width - 1,
                                              rectangleHeight - 1));
    }
    
    // Draw circle.
    //
    if (self.type == CXDurationPickerDayTypeStart || self.type == CXDurationPickerDayTypeEnd) {
        float circleWidth = labelWidth + 15;
        float circleHeight = ascenderHeight + 15;
        
        float circleDiameter = fmaxf(circleWidth, circleHeight);
        
        float circleY = (self.bounds.size.height - circleDiameter) / 2;
        float circleX = (self.bounds.size.width - circleDiameter) / 2;
        
        CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0
                                                                 green:120/255.0
                                                                  blue:200/255.0
                                                                 alpha:1] CGColor]);
        
        CGContextBeginPath(context);
        CGContextAddEllipseInRect(context, CGRectMake(circleX, circleY, circleDiameter, circleDiameter));
        CGContextDrawPath(context, kCGPathFill);
    }
    
    // Draw day number.
    //
    float xOffset = (self.bounds.size.width - labelWidth) / 2;
    float yCenter = (self.bounds.size.height - ascenderHeight) / 2;
    
    // I can't find the right way to vertically align the text, but adding a couple DIPs here
    // makes it look right. :/
    //
    float yOffset = (yCenter + 2);
    
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)stringToDraw);
    CGContextSetTextPosition(context, xOffset, yOffset);
    CTLineDraw(line, context);
    
    CFRelease(line);
    CFRelease(font);
    
    //CGContextRestoreGState(context);
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
    if (_pickerDate.year == pickerDate.year
        && _pickerDate.month == pickerDate.month
        && _pickerDate.day == pickerDate.day) {
        return YES;
    }
    
    return NO;
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
