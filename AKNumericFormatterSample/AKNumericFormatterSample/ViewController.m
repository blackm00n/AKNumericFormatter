//
// This file is subject to the terms and conditions defined in
// file 'LICENSE', which is part of this source code package.
//

#import "ViewController.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"

@interface ViewController()

@property(nonatomic, weak) IBOutlet UITextField* textField;
@property(nonatomic, weak) IBOutlet UIButton* button;

-(IBAction)buttonPressed:(id)sender;

@end

@implementation ViewController

-(void)viewDidLoad
{
  [super viewDidLoad];
  [self updateFormatterDependentUI];
}

-(void)updateFormatterDependentUI
{
  if( self.textField.numericFormatter ) {
    [self.button setTitle:@"Remove Formatter" forState:UIControlStateNormal];
  } else {
    [self.button setTitle:@"Add Formatter" forState:UIControlStateNormal];
  }
  self.textField.placeholder = self.textField.numericFormatter.mask;
}

-(void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(IBAction)buttonPressed:(id)sender
{
  if( self.textField.numericFormatter ) {
    self.textField.numericFormatter = nil;
  } else {
    self.textField.numericFormatter = [AKNumericFormatter formatterWithMask:@"TEL *(***)***-**-**" placeholderCharacter:'*'];
  }
  [self updateFormatterDependentUI];
}

@end