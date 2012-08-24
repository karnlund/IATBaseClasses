//
//  IATViewHider.h
//
//  Created by Kurt Arnlund on 4/25/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol IATViewHiderDelegate;

typedef enum
{
    USING_HEIGHT,
    USING_WIDTH
} AdjustUsingParameter;

typedef enum
{
    DIRECTION_UP,
    DIRECTION_DOWN,
    DIRECTION_LEFT,
    DIRECTION_RIGHT
} OffscreenDirection;

@interface IATViewHider : NSObject

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *adjustingView;
@property (assign, getter = isHidden) BOOL hidden;
@property (assign) CGPoint hideVector;
@property (assign) CGSize sizeVector;
@property (weak, nonatomic) id <IATViewHiderDelegate> delegate;

+ (id)viewHiderForView:(UIView*)viewToHide
         adjustingView:(UIView*)viewToAdjust
        usingParameter:(AdjustUsingParameter)param 
    offscreenDirection:(OffscreenDirection)direction 
              delegate:(id <IATViewHiderDelegate>)newDelegate;


- (void)setHideVectorFromViewHeightUp;
- (void)setHideVectorFromViewHeightDown;
- (void)setHideVectorFromViewWidthLeft;
- (void)setHideVectorFromViewWidthRight;

- (void)hideAnimated:(BOOL)animated;
- (void)showAnimated:(BOOL)animated;
@end



@protocol IATViewHiderDelegate <NSObject>

@optional

- (void)viewHider:(IATViewHider*)hider willHideView:(UIView*)view animated:(BOOL)animated;
- (void)viewHider:(IATViewHider*)hider didHideView:(UIView*)view;

- (void)viewHider:(IATViewHider*)hider willShowView:(UIView*)view animated:(BOOL)animated;
- (void)viewHider:(IATViewHider*)hider didShowView:(UIView*)view;

@end
