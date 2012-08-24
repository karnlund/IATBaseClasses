//
//  LayoutFunction2D.h
//  Utilities
//
//  Created by Kurt Arnlund on 8/30/10.
//  Copyright 2010 Ingenious Arts and Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface IATLayoutFunction2D : NSObject {

}

+ (CGPoint)pointOnElipse:(CGPoint)center 
					axis:(CGSize)axis
				   angle:(CGFloat)angleDegrees 
		  elipseRotation:(CGFloat)rotation;

+ (CGPoint)pointOnCirce:(CGPoint)center 
				 radius:(CGFloat)radius
				  angle:(CGFloat)angleDegrees 
		 elipseRotation:(CGFloat)rotation;

+ (CGPoint)pointOnVee:(CGPoint)center 
				 axis:(CGSize)axis
			 position:(CGFloat)pos 
		  veeRotation:(CGFloat)rotation;

@end
