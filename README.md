AKNumericFormatter
==================
Formatter for numerical fields and UITextField category to use it easily while editing.

Usage
-----

You can look at AKNumericFormatterSample project to see `AKNumericFormatter` in action.

Formatter usage:
```objc
NSString* numericInput = @"12345678901";
NSString* formattedInput = [AKNumericFormatter formatString:numericInput
                                                  usingMask:@"+*(***)***-**-**"
                                       placeholderCharacter:'*'];
```
Of course you will get `@"+1(234)567-89-01"`

To format `UITextField`'s input on-the-fly while the text is being entered:
```objc
// Somewhere, let's say in viewDidLoad
self.textField.numericFormatter = [AKNumericFormatter formatterWithMask:@"+*(***)***-**-**"
                                                   placeholderCharacter:'*'];
```
Yep, it's easy and no subclassing.

###iOS 5 Compatibility

It's working on iOS 5, but you should help it a little bit. Call `alertDeleteBackwards` method
in your `UITextField` delegate's `shouldChangeCharactersInRange:replacementString:` method
when `replacementString` parameter has zero length:

```objc
#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
  if (string.length == 0 ) {
    [self.textField alertDeleteBackwards];
  }
  return [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
}
```

Installation
------------

The best approach is to use [CocoaPods](http://cocoapods.org/).

Install CocoaPods gem if it's not installed yet and setup its enviroment:

    $ [sudo] gem install cocoapods
    $ pod setup

Go to the directory containing your project's .xcodeproj file and create Podfile:

    $ cd ~/Projects/MyProject
    $ vim Podfile
  
Add the following lines to Podfile:

```ruby
platform :ios
pod 'AKNumericFormatter'
```
  
Finally install your pod dependencies:

    $ [sudo] pod install
    
That's all, now open just created .xcworkspace file

Contact
-------
Aleksey Kozhevnikov
* [blackm00n on GitHub](https://github.com/blackm00n)
* aleksey.kozhevnikov@gmail.com
* [@kozhevnikoff](https://twitter.com/kozhevnikoff)



