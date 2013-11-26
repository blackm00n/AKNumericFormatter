//
// This file is subject to the terms and conditions defined in
// file 'LICENSE', which is part of this source code package.
//

@import XCTest;

#import "AKNumericFormatter.h"

@interface AKNumericFormatterTests : XCTestCase

@end

@implementation AKNumericFormatterTests

-(void)setUp
{
  [super setUp];
}

-(void)tearDown
{
  [super tearDown];
}

-(void)testFormatString_noDigitPlaceholders
{
  AKNumericFormatter* formatter = [AKNumericFormatter formatterWithMask:@"**:**:**" placeholderCharacter:'*'];
  XCTAssertEqualObjects([formatter formatString:@"1"], @"1");
  XCTAssertEqualObjects([formatter formatString:@"12"], @"12:");
  XCTAssertEqualObjects([formatter formatString:@"123"], @"12:3");
  XCTAssertEqualObjects([formatter formatString:@"1*2*x3*4"], @"12:34:");
  XCTAssertEqualObjects([formatter formatString:@"x*12345x*"], @"12:34:5");
  XCTAssertEqualObjects([formatter formatString:@"1234567"], @"12:34:56");
}

-(void)testFormatString_withDigitPlaceholders
{
  {
    // AKNumericFormatterFillIn mode
    AKNumericFormatter* formatter = [AKNumericFormatter formatterWithMask:@"+1(xxx)xx-77-xx" placeholderCharacter:'x' mode:AKNumericFormatterFillIn];
    XCTAssertEqualObjects([formatter formatString:@"1"], @"+1(1");
    XCTAssertEqualObjects([formatter formatString:@"2"], @"+1(2");
    XCTAssertEqualObjects([formatter formatString:@"123"], @"+1(123)");
    XCTAssertEqualObjects([formatter formatString:@"1*2*x3*4"], @"+1(123)4");
    XCTAssertEqualObjects([formatter formatString:@"x*12345x*"], @"+1(123)45-77-");
    XCTAssertEqualObjects([formatter formatString:@"1234567"], @"+1(123)45-77-67");
    XCTAssertEqualObjects([formatter formatString:@"12345678"], @"+1(123)45-77-67");
  }
  {
    // AKNumericFormatterStrict mode
    AKNumericFormatter* formatter = [AKNumericFormatter formatterWithMask:@"+1(xxx)xx-77-xx" placeholderCharacter:'x'
                                                                     mode:AKNumericFormatterStrict];
    XCTAssertEqualObjects([formatter formatString:@"1"], @"+1(");
    XCTAssertEqualObjects([formatter formatString:@"2"], @"");
    XCTAssertEqualObjects([formatter formatString:@"123"], @"+1(23");
    XCTAssertEqualObjects([formatter formatString:@"1234"], @"+1(234)");
    XCTAssertEqualObjects([formatter formatString:@"123456"], @"+1(234)56-");
    XCTAssertEqualObjects([formatter formatString:@"1234567"], @"+1(234)56-7");
    XCTAssertEqualObjects([formatter formatString:@"12345677"], @"+1(234)56-77-");
    XCTAssertEqualObjects([formatter formatString:@"12345678"], @"+1(234)56-7");
    XCTAssertEqualObjects([formatter formatString:@"123456778"], @"+1(234)56-77-8");
  }
  {
    // AKNumericFormatterMixed mode
    AKNumericFormatter* formatter = [AKNumericFormatter formatterWithMask:@"+1(xxx)xx-77-xx" placeholderCharacter:'x' mode:AKNumericFormatterMixed];
    XCTAssertEqualObjects([formatter formatString:@"1"], @"+1(");
    XCTAssertEqualObjects([formatter formatString:@"2"], @"+1(2");
    XCTAssertEqualObjects([formatter formatString:@"23"], @"+1(23");
    XCTAssertEqualObjects([formatter formatString:@"123"], @"+1(23");
    XCTAssertEqualObjects([formatter formatString:@"123456"], @"+1(234)56-77-");
    XCTAssertEqualObjects([formatter formatString:@"1234567"], @"+1(234)56-77-");
    XCTAssertEqualObjects([formatter formatString:@"12345677"], @"+1(234)56-77-");
    XCTAssertEqualObjects([formatter formatString:@"12345678"], @"+1(234)56-77-8");
    XCTAssertEqualObjects([formatter formatString:@"123456778"], @"+1(234)56-77-8");
  }
}

-(void)testIsFormatFulfilled
{
  AKNumericFormatter* formatter = [AKNumericFormatter formatterWithMask:@"**:**:**" placeholderCharacter:'*'];
  XCTAssertFalse([formatter isFormatFulfilled:@"12:"]);
  XCTAssertFalse([formatter isFormatFulfilled:@"12:34:*6"]);
  XCTAssertFalse([formatter isFormatFulfilled:@"12:34x56"]);
  XCTAssertTrue([formatter isFormatFulfilled:@"12:34:56"]);
  XCTAssertFalse([formatter isFormatFulfilled:@"12:34:56:"]);

}

-(void)testUnfixedDigits
{
  AKNumericFormatter* formatter = [AKNumericFormatter formatterWithMask:@"+1(xxx)xx-77-xx" placeholderCharacter:'x'];
  XCTAssertEqualObjects([formatter unfixedDigits:@"+1(234)56-77-89"], @"2345689");
}

@end
