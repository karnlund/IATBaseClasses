//
//  IATCarouselDataViewController.m
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/31/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATCarouselDataViewController.h"
#import "IATCarouselData.h"
#import "IATTouchableLabel.h"

#define kInitialPropertyKey		kLayoutAxisB

@interface IATCarouselDataViewController ()
<IATTouchableLabelDelegate, UITextFieldDelegate>
@property (readwrite, strong, nonatomic) NSString *currentProperty;
@property (readwrite, strong, nonatomic) NSNumber *originalValue;
@end



@implementation IATCarouselDataViewController

- (id)initWithMainBundleStandardNib
{
    self = [super initWithNibName:@"IATCarouselDataViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        self.currentProperty = kInitialPropertyKey;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setValueInput:nil];
    [self setValueSlider:nil];
    [self setFineTuneOnOff:nil];
    [self setValueNameLabel:nil];
	[self setFilenameInput:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self LoadValue];
    [self settingsFile];
    self.valueInput.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)settingsFile
{
    self.filenameInput.text = [[IATCarouselData shared] preferredSettingsBaseName];
}

- (void)nextSettingsFile
{
    [[IATCarouselData shared] nextSettingsFile];
	[self settingsFile];
    [self LoadValue];
    [self deleageDataChange];
}

- (void)nextProperty
{
    NSDictionary *layoutData = [[IATCarouselData shared] layoutData];
    NSArray *propertyKeys = [layoutData allKeys];
    NSUInteger idx = [propertyKeys indexOfObject:self.currentProperty];
    
    idx++;
    idx %= propertyKeys.count;
    
    self.currentProperty = [propertyKeys objectAtIndex:idx];
    [self LoadValue];
}


- (void)LoadValue {
    self.valueNameLabel.text = self.currentProperty;
    
    NSDictionary *layoutData = [[IATCarouselData shared] layoutData];
    NSNumber *propValue = [layoutData objectForKey:self.currentProperty];
    
    self.originalValue = propValue;
    CGFloat value = [propValue floatValue];
    CGFloat maxvalue = floorf(MAX(value * 2.0f, 5.0f));
    self.valueSlider.maximumValue = maxvalue;
    self.valueSlider.value = value;
    self.valueStepper.maximumValue = maxvalue;
    self.valueStepper.value = value;
    self.valueInput.text = [propValue stringValue];
}

- (void)storeValue {
    NSMutableDictionary *layoutData = [[[IATCarouselData shared] layoutData] mutableCopy];
    NSNumber *value = [NSNumber numberWithFloat:self.valueSlider.value];
    [layoutData setObject:value forKey:self.currentProperty];
    [[IATCarouselData shared] setLayoutData:[layoutData copy]];
    [self deleageDataChange];
}

- (IBAction)resetValue:(id)sender {
    
    CGFloat value = [self.originalValue floatValue];
    self.valueSlider.value = value;
    self.valueStepper.value = value;
    self.valueInput.text = [self.originalValue stringValue];
    [self storeValue];
}

- (IBAction)sliderChanged:(id)sender {

    [self endValueInput];
    if (sender == self.valueStepper) {
        self.valueStepper.value = floorf([self.valueStepper value]);
        self.valueSlider.value = [self.valueStepper value];
    }
    else if (sender == self.valueSlider) {
        self.valueSlider.value = floorf([self.valueSlider value]);
        self.valueStepper.value = [self.valueSlider value];
    }
    
    
    NSNumber *value = [NSNumber numberWithFloat:self.valueSlider.value];
    
    self.valueInput.text = [value stringValue];
    
    [self storeValue];
}

- (IBAction)valueInputDidEnd:(id)sender {

    self.valueSlider.value = [[sender text] floatValue];
    self.valueStepper.value = [[sender text] floatValue];
    [self storeValue];
}

- (IBAction)fineTuneChanged:(id)sender {
    
    [self endValueInput];
    [self deleageDataChange];
}

- (IBAction)nextSettingsFileAction:(id)sender {
	[self nextSettingsFile];
	[self deleageDataChange];
}

- (IBAction)saveAction:(id)sender {
    [self endValueInput];
	[[IATCarouselData shared] save];
}

- (IBAction)closeAction:(id)sender {
    [self endValueInput];
    [self delegateClose];
}

- (IBAction)filenameInputDidEnd:(id)sender {
	if ([self.filenameInput.text isEqualToString:[[IATCarouselData shared] preferredSettingsBaseName]])
		[[IATCarouselData shared] save];
	else
		[[IATCarouselData shared] createNewSettingsFileWithName:self.filenameInput.text];
}

- (void)delegateClose
{
    if ([self.delegate respondsToSelector:@selector(carouselDataViewControllerClose)])
        [self.delegate carouselDataViewControllerClose];
}

- (void)deleageDataChange
{
    if ([self.delegate respondsToSelector:@selector(carouselDataChange)])
        [self.delegate carouselDataChange];
}

- (void)touchableLabel:(IATTouchableLabel*)label touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (label == self.valueNameLabel) {
        [self nextProperty];
    }
}

#pragma mark - UITextFieldDelegate

- (void)endValueInput
{
    if ([self.valueInput isFirstResponder])
        [self.valueInput resignFirstResponder];
    if ([self.filenameInput isFirstResponder])
        [self.filenameInput resignFirstResponder];
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    
//}
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    
//}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    
//}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
//- (BOOL)textFieldShouldClear:(UITextField *)textField;
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endValueInput];
    return YES;
}

@end
