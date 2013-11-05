//
// This file is subject to the terms and conditions defined in
// file 'LICENSE', which is part of this source code package.
//

#import "AKNumericFormatter.h"
#import "NSString+AKNumericFormatter.h"

@interface AKNumericFormatter()

@end

@implementation AKNumericFormatter

+(NSString*)formatString:(NSString*)string usingMask:(NSString*)mask placeholderCharacter:(unichar)placeholderCharacter
{
  return [[self formatterWithMask:mask placeholderCharacter:placeholderCharacter] formatString:string];
}

+(instancetype)formatterWithMask:(NSString*)mask placeholderCharacter:(unichar)placeholderCharacter
{
  return [[AKNumericFormatter alloc] initWithMask:mask placeholderCharacter:placeholderCharacter];
}


-(instancetype)initWithMask:(NSString*)mask placeholderCharacter:(unichar)placeholderCharacter
{
  NSParameterAssert(mask);
  NSParameterAssert([mask countDecimalDigits] == 0);
  self = [super init];
  if( !self ) {
    return nil;
  }
  self.mask = mask;
  self.placeholderCharacter = placeholderCharacter;
  return self;
}

-(NSString*)formatString:(NSString*)string
{
  NSString* onlyDigitsString = [string stringContainingOnlyDecimalDigits];
  if( onlyDigitsString.length == 0 ) {
    return @"";
  }
  NSMutableString* formattedString = [NSMutableString string];
  for( NSUInteger maskIndex = 0, digitIndex = 0; maskIndex < self.mask.length; ++maskIndex ) {
    const unichar maskCharacter = [self.mask characterAtIndex:maskIndex];
    if( maskCharacter == self.placeholderCharacter ) {
      if( digitIndex < onlyDigitsString.length ) {
        [formattedString appendString:[onlyDigitsString substringWithRange:NSMakeRange(digitIndex, 1)]];
        ++digitIndex;
      } else {
        break;
      }
    } else {
      [formattedString appendString:[NSString stringWithCharacters:&maskCharacter length:1]];
    }
  }
  return formattedString;
}

-(BOOL)isFormatFulfilled:(NSString*)string
{
  return string.length == self.mask.length && [[self formatString:string] isEqualToString:string];
}

@end
