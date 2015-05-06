#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "CXDurationPickerDate.h"
#import "CXDurationPickerUtils.h"

@interface CXDurationPickerDemoTests : XCTestCase

@end

@implementation CXDurationPickerDemoTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    XCTAssert(YES, @"Pass");
}

- (void)testUtilComponents {
    CXDurationPickerDate pickerDate;
    pickerDate.day = 1;
    pickerDate.month = 1;
    pickerDate.year = 2015;
    
    NSDateComponents *testComponents = [CXDurationPickerUtils dateComponentsFromPickerDate:pickerDate];
    
    XCTAssertEqual(testComponents.day, 1, @"Incorrect day returned.");
    XCTAssertEqual(testComponents.month, 1, @"Incorrect month returned.");
    XCTAssertEqual(testComponents.year, 2015, @"Incorrect year returned.");
}

- (void)testUtilToday {
    NSDate *t1 = [CXDurationPickerUtils today];
    
    NSDate *t2 = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *c1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                               fromDate:t1];
    
    NSDateComponents *c2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                       fromDate:t2];
    
    XCTAssertEqual(c1.day, c2.day, "Day is not the same");
    XCTAssertEqual(c1.month, c2.month, "Month is not the same");
    XCTAssertEqual(c1.year, c2.year, "Year is not the same");
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

@end
