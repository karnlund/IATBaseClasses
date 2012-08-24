//
//  LayoutFunction2D.m
//  Utilities
//
//  Created by Kurt Arnlund on 8/30/10.
//  Copyright 2010 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATLayoutFunction2D.h"
#import "CATransformUtilities.h"
#import <UIKit/UIGeometry.h>

@implementation IATLayoutFunction2D


+ (CGPoint)pointOnElipse:(CGPoint)center 
					axis:(CGSize)axis
				   angle:(CGFloat)angleDegrees 
		  elipseRotation:(CGFloat)rotation
{
	// Angle is given by Degree Value
	//(Math.PI/180) converts Degree Value into Radians
	double beta = (double)DEGREES_TO_RADIANS(-rotation); 
	double sinbeta = sin(beta);
	double cosbeta = cos(beta);
	
	double angleRad = DEGREES_TO_RADIANS( (360 - angleDegrees + 90.0f) );
	double sinalpha = sin(angleRad);
	double cosalpha = cos(angleRad);
	
	CGFloat X = center.x + (axis.width * cosalpha * cosbeta - axis.height * sinalpha * sinbeta);
	CGFloat Y = center.y + (axis.width * cosalpha * sinbeta + axis.height * sinalpha * cosbeta);
	
	return CGPointMake(X, Y);
}

+ (CGPoint)pointOnCirce:(CGPoint)center 
				 radius:(CGFloat)radius
				  angle:(CGFloat)angleDegrees 
		 elipseRotation:(CGFloat)rotation
{
	CGSize axisRadii = CGSizeMake( radius, radius );
	
	return [self pointOnElipse:center axis:axisRadii angle:angleDegrees elipseRotation:rotation];
}


+ (CGPoint)pointOnVee:(CGPoint)center 
				 axis:(CGSize)axis
			 position:(CGFloat)pos 
		  veeRotation:(CGFloat)rotation
{
	double slopeLeft = -axis.height / axis.width;
	double slopeRight = axis.height / axis.width;
	
	double normalizedXPos = (pos / 180.0f) - 1.0f;
	CGPoint position;
	
	CGFloat xPos = normalizedXPos * axis.width;
	
	if (normalizedXPos <= 0.0f) {
		position = CGPointMake( xPos , -slopeLeft * xPos );
	}
	else {
		position = CGPointMake( xPos , -slopeRight * xPos );
	}
	
//	NSLog(@"%@", NSStringFromCGPoint(position));
	
	// Angle is given by Degree Value
	double beta = (double)DEGREES_TO_RADIANS(-rotation); //(Math.PI/180) converts Degree Value into Radians
	double sinbeta = sin(beta);
	double cosbeta = cos(beta);
	
	CGFloat X = center.x + (position.x * cosbeta - position.y * sinbeta);
	CGFloat Y = center.y + (position.x * sinbeta + position.y * cosbeta);
	
	return CGPointMake(X, Y);
}


@end
