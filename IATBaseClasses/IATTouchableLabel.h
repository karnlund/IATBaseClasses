//
//  IATTouchableLabel.h
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 8/1/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol IATTouchableLabelDelegate;


@interface IATTouchableLabel : UILabel

@property (readwrite, weak, nonatomic) IBOutlet id <IATTouchableLabelDelegate> delegate;

@end


@protocol IATTouchableLabelDelegate <NSObject>

- (void)touchableLabel:(IATTouchableLabel*)label touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end

