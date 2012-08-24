//
//  IATCarouselDataViewController.h
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/31/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IATCarouselDataViewControllerDelegate;


@interface IATCarouselDataViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *valueInput;
@property (weak, nonatomic) IBOutlet UISlider *valueSlider;
@property (weak, nonatomic) IBOutlet UIStepper *valueStepper;
@property (weak, nonatomic) IBOutlet UISwitch *fineTuneOnOff;
@property (weak, nonatomic) IBOutlet UILabel *valueNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *filenameInput;
@property (weak, nonatomic) IBOutlet id <IATCarouselDataViewControllerDelegate> delegate;

- (IBAction)resetValue:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (IBAction)valueInputDidEnd:(id)sender;
- (IBAction)fineTuneChanged:(id)sender;
- (IBAction)nextSettingsFileAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)closeAction:(id)sender;
- (IBAction)filenameInputDidEnd:(id)sender;


- (id)initWithMainBundleStandardNib;

@end




@protocol IATCarouselDataViewControllerDelegate <NSObject>

@optional
- (void)carouselDataViewControllerClose;
- (void)carouselDataChange;

@end