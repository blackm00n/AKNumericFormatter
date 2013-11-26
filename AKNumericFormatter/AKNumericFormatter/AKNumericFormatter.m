//
// This file is subject to the terms and conditions defined in
// file 'LICENSE', which is part of this source code package.
//

#import "AKNumericFormatter.h"
#import "NSString+AKNumericFormatter.h"

@interface AKNumericFormatter()

@property(nonatomic, assign) AKNumericFormatterMode mode;
@property(nonatomic, copy) NSString* mask;
@property(nonatomic, assign) unichar placeholderCharacter;

@end

@implementation AKNumericFormatter

+(NSString*)formatString:(NSString*)string
               usingMask:(NSString*)mask
    placeholderCharacter:(unichar)placeholderCharacter
                    mode:(AKNumericFormatterMode)mode
{
  return [[self formatterWithMask:mask placeholderCharacter:placeholderCharacter mode:mode] formatString:string];
}

+(NSString*)formatString:(NSString*)string
               usingMask:(NSString*)mask
    placeholderCharacter:(unichar)placeholderCharacter
{
  return [self formatString:string usingMask:mask placeholderCharacter:placeholderCharacter
                       mode:AKNumericFormatterStrict];
}

+(instancetype)formatterWithMask:(NSString*)mask
            placeholderCharacter:(unichar)placeholderCharacter
                            mode:(AKNumericFormatterMode)mode
{
  return [[AKNumericFormatter alloc] initWithMask:mask placeholderCharacter:placeholderCharacter mode:mode];
}

+(instancetype)formatterWithMask:(NSString*)mask placeholderCharacter:(unichar)placeholderCharacter
{
  return [self formatterWithMask:mask placeholderCharacter:placeholderCharacter mode:AKNumericFormatterStrict];
}


-(instancetype)initWithMask:(NSString*)mask placeholderCharacter:(unichar)placeholderCharacter mode:(AKNumericFormatterMode)mode
{
  NSParameterAssert(mask);
  self = [super init];
  if( !self ) {
    return nil;
  }
  self.mode = mode;
  self.mask = mask;
  self.placeholderCharacter = placeholderCharacter;
  return self;
}

-(NSUInteger)indexOfFirstDigitOrPlaceholderInMask
{
  const NSUInteger placeholderIndex = [self.mask indexOfCharacter:self.placeholderCharacter];
  const NSUInteger digitIndex = [self.mask rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location;
  return MIN(placeholderIndex, digitIndex);
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
    } else if( self.mode != AKNumericFormatterFillIn && [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:maskCharacter] ) {
      if( digitIndex < onlyDigitsString.length
        && maskCharacter == [onlyDigitsString characterAtIndex:digitIndex] )
      {
        [formattedString appendString:[NSString stringWithCharacters:&maskCharacter length:1]];
        ++digitIndex;
      } else if( self.mode == AKNumericFormatterMixed ) {
        [formattedString appendString:[NSString stringWithCharacters:&maskCharacter length:1]];
      } else {
        break;
      }
    } else {
      [formattedString appendString:[NSString stringWithCharacters:&maskCharacter length:1]];
    }
  }
  if( [formattedString stringContainingOnlyDecimalDigits].length == 0 ) {
    return @"";
  }
  return formattedString;
}

-(BOOL)isFormatFulfilled:(NSString*)string
{
  return string.length == self.mask.length && [self isCorrespondingToFormat:string];
}

-(BOOL)isCorrespondingToFormat:(NSString*)string
{
  NSString* formattedString = [self formatString:string];
  return string.length <= formattedString.length && [[formattedString substringToIndex:string.length] isEqualToString:string];
}

-(NSString*)unfixedDigits:(NSString*)string
{
  if( ![self isCorrespondingToFormat:string] ) {
    return nil;
  }
  NSMutableString* result = [NSMutableString string];
  NSCharacterSet* decimalCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
  NSString* filteredMask = [self.mask filteredStringUsingBlock:^BOOL(unichar character)
  {
    return character == self.placeholderCharacter || [decimalCharacterSet characterIsMember:character];
  }];
  NSString* filteredValue = [string stringContainingOnlyDecimalDigits];
  for( NSUInteger i = 0; i < filteredValue.length && i < filteredMask.length; ++i ) {
    if( [filteredMask characterAtIndex:i] == self.placeholderCharacter ) {
      [result appendString:[filteredValue substringWithRange:NSMakeRange(i, 1)]];
    }
  }
  return result;
}

-(NSString*)fillInMaskWithDigits:(NSString*)digits
{
  return [AKNumericFormatter formatString:digits
                                usingMask:self.mask
                     placeholderCharacter:self.placeholderCharacter
                                     mode:AKNumericFormatterFillIn];
}

@end
