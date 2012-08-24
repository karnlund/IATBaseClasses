//
//  CGRectUtilities.h
//  Utilities
//
//  Created by Kurt Arnlund on 8/17/10.
//  Copyright 2010 Ingenious Arts and Technologies LLC. All rights reserved.
//

#ifndef CGRectUtilities
#define CGRectUtilities

#include <CoreGraphics/CGBase.h>


CG_INLINE CGRect CGRectScaleSize(CGRect rect, CGFloat scale);
CG_INLINE CGRect CGRectSwapWidthHeight(CGRect rect);
CG_INLINE CGPoint CGRectMidPoint(CGRect rect);
CG_INLINE CGPoint CGRectSizeCenter(CGRect rect);


CG_INLINE CGRect 
CGRectScaleSize(CGRect rect, CGFloat scale)
{
	CGRect result;
	result.origin.x = rect.origin.x; result.origin.y = rect.origin.y;
	result.size.width = rect.size.width * scale; result.size.height = rect.size.height * scale;
	return result;
}


CG_INLINE CGRect 
CGRectSwapWidthHeight(CGRect rect)
{
	CGRect result;
	result = rect;
	result.size.width = rect.size.height;
	result.size.height = rect.size.width;
	return result;
}


CG_INLINE CGPoint 
CGRectMidPoint(CGRect rect)
{
	CGPoint mid = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	return mid;
}


CG_INLINE CGPoint
CGRectSizeCenter(CGRect rect)
{
	CGPoint center = CGPointMake(rect.size.width * 0.5f, rect.size.height * 0.5f);
	return center;
}


#endif
