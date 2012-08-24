//
//  IATPerspectiveView
//  IATBaseClasses
//
//  Created by Kurt Arnlund.
//  Copyright 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface IATPerspectiveView : UIView

@property (readwrite, strong, nonatomic) NSArray *viewsMirroringTransform;

- (CATransform3D)perspectiveTransform;
- (void)tiltDegrees:(CGFloat)degrees;

@end
