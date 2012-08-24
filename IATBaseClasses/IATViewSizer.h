//
//  IATViewSizer.h
//
//  Created by Kurt Arnlund on 4/26/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol IATViewSizerDelegate;



@interface IATViewSizer : NSObject
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *adjustingView;
@property (assign, getter = isResized) BOOL resized;
@property (assign, getter = isResizing) BOOL resing;
@property (assign) CGSize adjustmentVector;
@property (assign) BOOL keepCentered;
@property (weak, nonatomic) id <IATViewSizerDelegate> delegate;

+ (id)viewSizerForView:(UIView*)viewToHide
         adjustingView:(UIView*)viewToAdjust
        adjustmentSize:(CGSize)adjSize
		  keepCentered:(BOOL)center
              delegate:(id <IATViewSizerDelegate>)newDelegate;

- (void)sizeAnimated:(BOOL)animated;
- (void)unsizeAnimated:(BOOL)animated;
@end


@protocol IATViewSizerDelegate <NSObject>

@optional

- (void)viewSizer:(IATViewSizer*)sizer willSizeView:(UIView*)view animated:(BOOL)animated;
- (void)viewSizer:(IATViewSizer*)sizer didSizeView:(UIView*)view;

- (void)viewSizer:(IATViewSizer*)sizer willUnsizeView:(UIView*)view animated:(BOOL)animated;
- (void)viewSizer:(IATViewSizer*)sizer didUnsizeView:(UIView*)view;

@end

