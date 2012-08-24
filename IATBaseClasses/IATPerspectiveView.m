//
//  PerspectiveView.m
//  IATBaseClasses
//
//  Created by Kurt Arnlund.
//  Copyright 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATPerspectiveView.h"
#import "CATransformUtilities.h"
#import "CAVectorUtilities.h"
#import <QuartzCore/QuartzCore.h>

@interface IATPerspectiveView () {
	CATransform3D saveSublayerTrans;
}
@end



@implementation IATPerspectiveView
@synthesize viewsMirroringTransform;

- (CATransform3D)perspectiveTransform
{
	CATransform3D sublayerTransform = saveSublayerTrans;
	sublayerTransform.m34 = -1.0f/500.f;		//the z distance -- negative moves it away from view (was .01)
	return sublayerTransform;
}

- (void)tiltDegrees:(CGFloat)degrees
{
	CATransform3D sublayerTransform = self.perspectiveTransform;
	sublayerTransform = CATransform3DRotate(sublayerTransform, (float)DEGREES_TO_RADIANS(degrees), 1.0f, 0.0f, 0.0f);
	vectorNormalize(&sublayerTransform.m11);
	vectorNormalize(&sublayerTransform.m21);
	vectorNormalize(&sublayerTransform.m31);
	[self.layer setSublayerTransform:sublayerTransform];
	
	if ([viewsMirroringTransform count]) {
		for (UIView *view in viewsMirroringTransform) {
			[view.layer setSublayerTransform: sublayerTransform];
		}
	}
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	saveSublayerTrans = self.layer.sublayerTransform;
	self.layer.sublayerTransform = [self perspectiveTransform];
}

- (void)removeFromSuperview
{
	self.layer.sublayerTransform = saveSublayerTrans;
	[super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

@end
