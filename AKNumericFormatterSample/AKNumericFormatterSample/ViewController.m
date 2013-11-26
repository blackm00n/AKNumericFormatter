//
// This file is subject to the terms and conditions defined in
// file 'LICENSE', which is part of this source code package.
//

#import "ViewController.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"

@interface ViewController()

@property(nonatomic, weak) IBOutlet UITextField* textField;

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

@end