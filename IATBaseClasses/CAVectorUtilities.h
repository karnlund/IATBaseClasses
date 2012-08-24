//
//  CATransformVectorMath.h
//  Utilities
//
//  Created by Kurt Arnlund on 8/25/10.
//  Copyright 2010 Ingenious Arts and Technologies LLC. All rights reserved.
//

#ifndef CAVectorUtilities
#define CAVectorUtilities

#include <CoreGraphics/CGBase.h>
#include <QuartzCore/QuartzCore.h>

 
#define DEGREES_TO_RADIANS(value)  (value * (M_PI / 180.0))

typedef union {
	CGFloat value[3];
	struct {
		CGFloat x;
		CGFloat y;
		CGFloat z;
	} s_vector;
} vector;

extern const CGFloat unitVectorX[3];
extern const CGFloat unitVectorY[3];
extern const CGFloat unitVectorZ[3];
extern const CGFloat unitVectorXInverted[3];
extern const CGFloat unitVectorYInverted[3];
extern const CGFloat unitVectorZInverted[3];

CG_INLINE vector vectorMake(CGFloat x, CGFloat y, CGFloat z);

// (fromVector X toVector) = resultant
// resultant is perpendicular to plane defined by the two vectors.
// resultant length is proportional to area of parallelogram defined by the two vectors
CG_INLINE void vectorCrossProduct(CGFloat *resultant, CGFloat *fromVector, CGFloat *toVector);

// |vectorA|
CG_INLINE CGFloat vectorLength(CGFloat *vector);

// (vectorA . vectorB) = scalar result
// result is |vectorA| * |vectorB| * cos( angle between A and B )
// if A and B are unit vectors then result is just the cosine of the angle between A and B
CG_INLINE CGFloat vectorDotProduct(CGFloat *vectorA, CGFloat *vectorB);

// (vectorA - vectorB) = resultant
CG_INLINE void vectorDifference(CGFloat *resultant, CGFloat *vectorA, CGFloat *vectorB);

// (vectorA + vectorB) = resultant
CG_INLINE void vectorAddition(CGFloat *resultant, CGFloat *vectorA, CGFloat *vectorB);

// vector / |vector| = resultant
CG_INLINE void vectorNormalize(CGFloat *vector);

// (-vector) = resultant
CG_INLINE void vectorInvert(CGFloat *resultant, CGFloat *vector);

CG_INLINE void CATransform3DRotateVector(CGFloat *vector, CGFloat angle, CGFloat axis_x, CGFloat axis_y, CGFloat axis_z);

CG_INLINE CATransform3D CATransform3DMakeFromVectors(CGFloat *axis_x, CGFloat *axis_y, CGFloat *axis_z);

CG_INLINE CATransform3D CATransform3DConstructOrthogonalMatrixUsingVectorsXY(CGFloat *vectorX, CGFloat *vectorY);

CG_INLINE CATransform3D CATransform3DConstructOrthogonalMatrixUsingVectorsZY(CGFloat *vectorZ, CGFloat *vectorY);

CG_INLINE NSString* NSStringFromVector(vector *vec);

#pragma mark  Inline implementations

CG_INLINE vector
vectorMake(CGFloat x, CGFloat y, CGFloat z)
{
	vector result = {{x, y, z}};
	return result;
}

CG_INLINE void 
vectorCrossProduct(CGFloat*resultant, CGFloat*fromVector, CGFloat*toVector)
{
	resultant[0] =  fromVector[1] * toVector[2] - fromVector[2] * toVector[1];
	resultant[1] =  fromVector[2] * toVector[0] - fromVector[0] * toVector[2];
	resultant[2] =  fromVector[0] * toVector[1] - fromVector[1] * toVector[0];
}

CG_INLINE CGFloat
vectorLength(CGFloat * vector)
{
	return (CGFloat)sqrt((vector[0] * vector[0]) + 
						 (vector[1] * vector[1]) + 
						 (vector[2] * vector[2]));
}

CG_INLINE CGFloat 
vectorDotProduct(CGFloat*vectorA, CGFloat*vectorB)
{
	return	vectorA[0] * vectorB[0] + 
			vectorA[1] * vectorB[1] + 
			vectorA[2] * vectorB[2];
}

CG_INLINE void 
vectorDifference(CGFloat*resultant, CGFloat*vectorA, CGFloat*vectorB)
{
	resultant[0] = vectorA[0] - vectorB[0];
	resultant[1] = vectorA[1] - vectorB[1];
	resultant[2] = vectorA[2] - vectorB[2];
}

CG_INLINE void 
vectorAddition(CGFloat*resultant, CGFloat*vectorA, CGFloat*vectorB)
{
	resultant[0] = vectorA[0] + vectorB[0];
	resultant[1] = vectorA[1] + vectorB[1];
	resultant[2] = vectorA[2] + vectorB[2];
}

CG_INLINE void 
vectorNormalize(CGFloat*vector)
{
	CGFloat length = vectorLength(vector);
	
	CGFloat ratio = 1 / length;
	
	vector[0] = vector[0] * ratio;
	vector[1] = vector[1] * ratio;
	vector[2] = vector[2] * ratio;
}

CG_INLINE void 
vectorInvert(CGFloat*resultant, CGFloat*vector)
{
	resultant[0] = -vector[0];
	resultant[1] = -vector[1];
	resultant[2] = -vector[2];
}

CG_INLINE void 
CATransform3DRotateVector(CGFloat*vector, CGFloat angle, CGFloat axis_x, CGFloat axis_y, CGFloat axis_z)
{
	CATransform3D posMat = CATransform3DMakeTranslation(vector[0], vector[1], vector[2]);
	
	CATransform3D newMat = CATransform3DConcat(posMat, CATransform3DMakeRotation(angle, axis_x, axis_y, axis_z));
	
	vector[0] = newMat.m41;
	vector[1] = newMat.m42;
	vector[2] = newMat.m43;
}

CG_INLINE CATransform3D 
CATransform3DMakeFromVectors(CGFloat *axis_x, CGFloat *axis_y, CGFloat *axis_z)
{
	CATransform3D trans;
	trans.m11 = axis_x[0], trans.m12 = axis_x[1], trans.m13 = axis_x[2], trans.m14 = 0.0f;
	trans.m21 = axis_y[0], trans.m22 = axis_y[1], trans.m23 = axis_y[2], trans.m24 = 0.0f;
	trans.m31 = axis_z[0], trans.m32 = axis_z[1], trans.m33 = axis_z[2], trans.m34 = 0.0f;	
	trans.m41 = 0.0f, trans.m42 = 0.0f, trans.m43 = 0.0f, trans.m44 = 1.0f;
	return trans;
}

CG_INLINE CATransform3D 
CATransform3DConstructOrthogonalMatrixUsingVectorsXY(CGFloat *vectorX, CGFloat *vectorY)
{
	CGFloat crossProdZ[3];
	CGFloat newY[3];
	
	vectorCrossProduct(crossProdZ, vectorX, vectorY);
	vectorNormalize(crossProdZ);
	vectorCrossProduct(newY, crossProdZ, vectorX);
	vectorNormalize(newY);
	
	return CATransform3DMakeFromVectors(vectorX, newY, crossProdZ);
}

CG_INLINE CATransform3D
CATransform3DConstructOrthogonalMatrixUsingVectorsZY(CGFloat *vectorZ, CGFloat *vectorY)
{
	CGFloat crossProdX[3];
	CGFloat newY[3];
	
	vectorCrossProduct(crossProdX, vectorY, vectorZ);
	vectorNormalize(crossProdX);
	vectorCrossProduct(newY, vectorZ, crossProdX);
	vectorNormalize(newY);
	
	return CATransform3DMakeFromVectors(crossProdX, newY, vectorZ);
}


CG_INLINE NSString* 
NSStringFromVector(vector *vec)
{
	return [NSString stringWithFormat:@"[%3.2f, %3.2f, %3.2f] vector <%p>", vec->s_vector.x, vec->s_vector.y, vec->s_vector.z, vec];
}


#endif // CAVectorUtilities

