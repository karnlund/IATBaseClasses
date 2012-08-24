//
//  IATViewFader.h
//
//  Created by Kurt Arnlund on 4/25/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol IATViewFaderDelegate;



@interface IATViewFader : NSObject
@property (weak, nonatomic) IBOutlet UIView *view;
@property (assign, getter = isFaded) BOOL faded;
@property (weak, nonatomic) id <IATViewFaderDelegate> delegate;

+ (id)viewFaderForView:(UIView*)viewToHide
              delegate:(id <IATViewFaderDelegate>)newDelegate;

- (void)fadeAnimated:(BOOL)animated;
- (void)showAnimated:(BOOL)animated;
@end



@protocol IATViewFaderDelegate <NSObject>

@optional

- (void)viewFader:(IATViewFader*)fader willHideView:(UIView*)view animated:(BOOL)animated;
- (void)viewFader:(IATViewFader*)fader didHideView:(UIView*)view;

- (void)viewFader:(IATViewFader*)fader willShowView:(UIView*)view animated:(BOOL)animated;
- (void)viewFader:(IATViewFader*)fader didShowView:(UIView*)view;

@end

