//
//  CXDurationModeSwitch.m
//  CalendarViewSample
//
//  Created by Richard Puckett on 3/6/15.
//  Copyright (c) 2015 Concur Creative Labs. All rights reserved.
//

#import <CoreText/CoreText.h>

#import "CXDurationModeSwitch.h"

@interface CXDurationModeSwitch ()
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) NSMutableArray *customConstraints;
@property (readwrite, nonatomic) CXDurationPickerMode mode;
@end

@implementation CXDurationModeSwitch

- (void)awakeFromNib {
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.mode = CXDurationPickerModeStartDate;
    
    self.customConstraints = [[NSMutableArray alloc] init];
    
    UIView *view = nil;
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CXDurationModeSwitch"
                                                     owner:self
                                                   options:nil];
    
    for (id object in objects) {
        if ([object isKindOfClass:[UIView class]]) {
            view = object;
            break;
        }
    }
    
    if (view != nil) {
        self.containerView = view;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateConstraints {
    [self removeConstraints:self.customConstraints];
    
    [self.customConstraints removeAllObjects];
    
    if (self.containerView != nil) {
        UIView *view = self.containerView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(view);
        
        [self.customConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:
          @"H:|[view]|" options:0 metrics:nil views:views]];
        
        [self.customConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:
          @"V:|[view]|" options:0 metrics:nil views:views]];
        
        [self addConstraints:self.customConstraints];
    }
    
    [super updateConstraints];
}

#pragma mark - View API

- (void)setStartDateString:(NSString *)startDateString {
    self.startDateLabel.text = startDateString;
}

- (void)setEndDateString:(NSString *)endDateString {
    self.endDateLabel.text = endDateString;
}

#pragma mark - Gesture Recognizers

- (IBAction)didTapButton1:(id)sender {
    CGPoint newCenter = CGPointMake(self.button1.center.x, self.indicator.center.y);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.indicator.center = newCenter;
    } completion:nil];
    
    self.mode = CXDurationPickerModeStartDate;
    
    if (self.delegate) {
        [self.delegate modeSwitch:self modeChanged:self.mode];
    }
}

- (IBAction)didTapButton2:(id)sender {
    CGPoint newCenter = CGPointMake(self.button2.center.x, self.indicator.center.y);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.indicator.center = newCenter;
    } completion:nil];
    
    self.mode = CXDurationPickerModeEndDate;
    
    if (self.delegate) {
        [self.delegate modeSwitch:self modeChanged:self.mode];
    }
}

@end
