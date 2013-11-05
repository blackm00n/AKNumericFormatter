//
// This file is subject to the terms and conditions defined in
// file 'LICENSE', which is part of this source code package.
//

@interface AKNumericFormatter : NSObject

+(NSString*)formatString:(NSString*)string usingMask:(NSString*)mask placeholderCharacter:(unichar)placeholderCharacter;

+(instancetype)formatterWithMask:(NSString*)mask placeholderCharacter:(unichar)placeholderCharacter;

@property(nonatomic, copy) NSString* mask;
@property(nonatomic, assign) unichar placeholderCharacter;

// Returns empty string if input string has no decimal digits
-(NSString*)formatString:(NSString*)string;
-(BOOL)isFormatFulfilled:(NSString*)string;

@end
