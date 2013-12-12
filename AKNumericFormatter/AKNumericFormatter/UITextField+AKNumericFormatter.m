//
// This file is subject to the terms and conditions defined in
// file 'LICENSE', which is part of this source code package.
//

#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "objc/runtime.h"
#import "NSString+AKNumericFormatter.h"

static char UITextFieldNumericFormatter;
static char UITextFieldTendCaretToLeft;
static char UITextFieldIsFormatting;

@implementation UITextField(AKNumericFormatter)

-(void)setNumericFormatter:(AKNumericFormatter*)numericFormatter
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    method_exchangeImplementations(class_getInstanceMethod([self class], @selector(deleteBackward)),
        class_getInstanceMethod([self class], @selector(deleteBackwardSwizzle)));
  });
  objc_setAssociatedObject(self, &UITextFieldNumericFormatter, numericFormatter, OBJC_ASSOCIATION_RETAIN);
  if( numericFormatter ) {
    [self addTarget:self action:@selector(handleTextChanged:) forControlEvents:UIControlEventEditingChanged];
  } else {
    [self removeTarget:self action:@selector(handleTextChanged:) forControlEvents:UIControlEventEditingChanged];
  }
}

-(AKNumericFormatter*)numericFormatter
{
  return objc_getAssociatedObject(self, &UITextFieldNumericFormatter);
}

-(void)setHandleDeleteBackwards:(BOOL)handleDeleteBackwards
{
  objc_setAssociatedObject(self, &UITextFieldTendCaretToLeft, @(handleDeleteBackwards), OBJC_ASSOCIATION_COPY);
}

-(BOOL)handleDeleteBackwards
{
  return [objc_getAssociatedObject(self, &UITextFieldTendCaretToLeft) boolValue];
}

-(void)setIsFormatting:(BOOL)isFormatting
{
  objc_setAssociatedObject(self, &UITextFieldIsFormatting, @(isFormatting), OBJC_ASSOCIATION_COPY);
}

-(BOOL)isFormatting
{
  return [objc_getAssociatedObject(self, &UITextFieldIsFormatting) boolValue];
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
-(void)deleteBackwardSwizzle
{
  [self alertDeleteBackwards];
  [self deleteBackwardSwizzle];
}
#pragma clang diagnostic pop

-(void)handleTextChanged:(NSNotification*)notification
{
  // Check for recursion
  if( self.isFormatting ) {
    return;
  }
  self.isFormatting = YES;

  // Saving caret position
  NSUInteger caretHeadOffset = (NSUInteger)[self offsetFromPosition:self.beginningOfDocument
                                                          toPosition:self.selectedTextRange.start];
  NSUInteger caretTailOffset = (NSUInteger)[self offsetFromPosition:self.selectedTextRange.end
                                                        toPosition:self.endOfDocument];
  NSUInteger offsetDigitsCount = 0;
  if( self.handleDeleteBackwards ) {
    offsetDigitsCount = [[self.text substringToIndex:caretHeadOffset] countDecimalDigits];
  } else {
    offsetDigitsCount = [[self.text substringFromIndex:self.text.length - caretTailOffset] countDecimalDigits];
  }

  // Format text
  NSString* newText = [self.numericFormatter formatString:self.text];
  if( ![self.text isEqualToString:newText] ) {
    self.text = newText;
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
  }

  // Restoring caret position
  NSInteger newCaretOffset = 0;
  if( self.handleDeleteBackwards ) {
    newCaretOffset = [self.text minPrefixLengthContainingDecimalDigitsCount:offsetDigitsCount];
  } else {
    newCaretOffset = self.text.length - [self.text minSuffixLengthContainingDecimalDigitsCount:offsetDigitsCount];
  }
  if( newCaretOffset < [self.numericFormatter indexOfFirstDigitOrPlaceholderInMask] ) {
    newCaretOffset = self.text.length;
  }
  if( newCaretOffset < self.text.length ) {
    NSCharacterSet* decimalDigits = [NSCharacterSet decimalDigitCharacterSet];
    BOOL maskHasDigitsAfterCaret = [[self.numericFormatter.mask substringFromIndex:(NSUInteger)newCaretOffset] rangeOfCharacterFromSet:decimalDigits].location != NSNotFound;
    BOOL textHasOnlyThrashAfterCaret  = [[self.text substringFromIndex:(NSUInteger)newCaretOffset] rangeOfCharacterFromSet:decimalDigits].location == NSNotFound;
    if( textHasOnlyThrashAfterCaret || maskHasDigitsAfterCaret ) {
      self.text = [self.text substringToIndex:(NSUInteger)newCaretOffset];
      [self sendActionsForControlEvents:UIControlEventEditingChanged];
    }
  }
  UITextPosition* newCaretPosition = [self positionFromPosition:self.beginningOfDocument offset:newCaretOffset];
  self.selectedTextRange = [self textRangeFromPosition:newCaretPosition toPosition:newCaretPosition];

  self.isFormatting = NO;
  self.handleDeleteBackwards = NO;
}

-(void)formatCurrentText
{
  if( !self.numericFormatter ) {
    return;
  }
  self.handleDeleteBackwards = NO;
  [self handleTextChanged:nil];
}

-(void)alertDeleteBackwards
{
  self.handleDeleteBackwards = YES;
}

@end