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

-(void)deleteBackwardSwizzle
{
  if( self.numericFormatter ) {
    UITextRange* selectedTextRange = self.selectedTextRange;
    NSInteger caretStart = [self offsetFromPosition:self.beginningOfDocument toPosition:selectedTextRange.start];
    NSInteger caretEnd = [self offsetFromPosition:self.beginningOfDocument toPosition:selectedTextRange.end];
    if( caretStart != caretEnd ) {
      self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange((NSUInteger)caretStart, (NSUInteger)(caretEnd - caretStart))
                                                     withString:@""];
      self.selectedTextRange = [self textRangeFromPosition:selectedTextRange.start toPosition:selectedTextRange.start];
    } else if( caretStart > 0 ) {
      self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange((NSUInteger)caretStart - 1, 1)
                                                     withString:@""];
      UITextPosition* newCaretPos = [self positionFromPosition:self.beginningOfDocument offset:caretStart - 1];
      self.selectedTextRange = [self textRangeFromPosition:newCaretPos toPosition:newCaretPos];
    }
    self.handleDeleteBackwards = YES;
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
  } else {
    [self deleteBackwardSwizzle];
  }
}

-(void)handleTextChanged:(NSNotification*)notification
{
  // Check for recursion
  if( self.isFormatting ) {
    return;
  }
  self.isFormatting = YES;

  // Saving caret position
  NSUInteger offsetDigitsCount = 0;
  if( self.handleDeleteBackwards ) {
    NSInteger caretOffset = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    offsetDigitsCount = [[self.text substringToIndex:(NSUInteger)caretOffset] countDecimalDigits];
  } else {
    NSInteger caretOffset = [self offsetFromPosition:self.selectedTextRange.end toPosition:self.endOfDocument];
    offsetDigitsCount = [[self.text substringFromIndex:self.text.length - caretOffset] countDecimalDigits];
  }

  // Format text
  self.text = [self.numericFormatter formatString:self.text];

  // Restoring caret position
  NSInteger newCaretOffset = 0;
  if( self.handleDeleteBackwards ) {
    newCaretOffset = [self.text minPrefixLengthContainingDecimalDigitsCount:offsetDigitsCount];
  } else {
    newCaretOffset = self.text.length - [self.text minSuffixLengthContainingDecimalDigitsCount:offsetDigitsCount];
  }
  if( newCaretOffset < [self.numericFormatter.mask indexOfCharacter:self.numericFormatter.placeholderCharacter] ) {
    newCaretOffset = self.text.length;
  }
  if( newCaretOffset < self.text.length ) {
    if( [self.text rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:0 range:NSMakeRange((NSUInteger)newCaretOffset, self.text.length - newCaretOffset)].location == NSNotFound ) {
      self.text = [self.text substringToIndex:(NSUInteger)newCaretOffset];
    }
  }
  UITextPosition* newCaretPosition = [self positionFromPosition:self.beginningOfDocument offset:newCaretOffset];
  self.selectedTextRange = [self textRangeFromPosition:newCaretPosition toPosition:newCaretPosition];

  self.isFormatting = NO;
  self.handleDeleteBackwards = NO;
}

@end