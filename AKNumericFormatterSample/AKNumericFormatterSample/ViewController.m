//
// This file is subject to the terms and conditions defined in
// file 'LICENSE', which is part of this source code package.
//

#import "ViewController.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"

@interface ViewController()

@property(nonatomic, weak) IBOutlet UITextField* textField;
@property(nonatomic, weak) IBOutlet UILabel* formatFulfilledLabel;

-(IBAction)segmentChanged:(UISegmentedControl*)sender;

@end

@implementation ViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
  [self updateFormatterDependentUI];
}

-(void)updateFormatterDependentUI
{
  self.textField.placeholder = self.textField.numericFormatter.mask;
  [self updateFormatFulfilledLabel];
}

-(void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(IBAction)segmentChanged:(UISegmentedControl*)sender
{
  if( sender.selectedSegmentIndex == 0 ) {
    self.textField.numericFormatter = nil;
  } else {
    AKNumericFormatterMode mode = (sender.selectedSegmentIndex == 1 ? AKNumericFormatterMixed : AKNumericFormatterStrict);
    self.textField.numericFormatter = [AKNumericFormatter formatterWithMask:@"+1(***)***-****"
                                                       placeholderCharacter:'*'
                                                                       mode:mode];
  }
  [self updateFormatterDependentUI];
}

-(IBAction)textFieldEditingChanged:(id)sender
{
  [self updateFormatFulfilledLabel];
}

-(void)updateFormatFulfilledLabel
{
  if( self.textField.numericFormatter ) {
    BOOL isFormatFulfilled = [self.textField.numericFormatter isFormatFulfilled:self.textField.text];
    self.formatFulfilledLabel.text = [NSString stringWithFormat:@"Format fulfilled: %@", (isFormatFulfilled ? @"YES" : @"NO")];
    self.formatFulfilledLabel.hidden = NO;
  } else {
    self.formatFulfilledLabel.hidden = YES;
  }
}

@end