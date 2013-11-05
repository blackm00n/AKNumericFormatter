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

-(void)testFormatString
{
  AKNumericFormatter* formatter = [AKNumericFormatter formatterWithMask:@"**:**:**" placeholderCharacter:'*'];
  XCTAssertEqualObjects([formatter formatString:@"1"], @"1");
  XCTAssertEqualObjects([formatter formatString:@"12"], @"12:");
  XCTAssertEqualObjects([formatter formatString:@"123"], @"12:3");
  XCTAssertEqualObjects([formatter formatString:@"1*2*x3*4"], @"12:34:");
  XCTAssertEqualObjects([formatter formatString:@"x*12345x*"], @"12:34:5");
  XCTAssertEqualObjects([formatter formatString:@"1234567"], @"12:34:56");
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

@end
