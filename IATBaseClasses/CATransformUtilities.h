//
//  CATransformUtilities.h
//  Utilities
//
//  Created by Kurt Arnlund on 8/25/10.
//  Copyright 2010 Ingenious Arts and Technologies LLC. All rights reserved.
//

#ifndef CATransformUtilities
#define CATransformUtilities

#include <CoreGraphics/CGBase.h>
#include <QuartzCore/QuartzCore.h>
 
#define DEGREES_TO_RADIANS(value)  (value * (M_PI / 180.0))
#define RADIANS_TO_DEGREES(value)  ((value / M_PI) * 180.0)

CG_INLINE NSString* NSStringFromCATransform3D(CATransform3D trans);



#pragma mark - INLINE IMPLEMENTATIONS

CG_INLINE NSString* 
NSStringFromCATransform3D(CATransform3D trans)
{
	return [NSString stringWithFormat:@"CATransform3D <%p>\n[%03.2f, %03.2f, %03.2f, %03.2f]\n[%03.2f, %03.2f, %03.2f, %03.2f]\n[%03.2f, %03.2f, %03.2f, %03.2f]\n[%03.2f, %03.2f, %03.2f, %03.2f]",
			&trans,
			trans.m11, trans.m12, trans.m13, trans.m14,
			trans.m21, trans.m22, trans.m23, trans.m24,
			trans.m31, trans.m32, trans.m33, trans.m34,
			trans.m41, trans.m42, trans.m43, trans.m44];
}



#endif // CAVectorUtilities

