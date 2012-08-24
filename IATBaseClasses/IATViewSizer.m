//
//  IATViewSizer.m
//
//  Created by Kurt Arnlund on 4/26/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATViewSizer.h"
#import <QuartzCore/QuartzCore.h>


@implementation IATViewSizer
@synthesize view = _view;
@synthesize adjustingView = _adjustingView;
@synthesize adjustmentVector = _adjustmentVector;
@synthesize delegate = _delegate;

+ (id)viewSizerForView:(UIView*)viewToHide
         adjustingView:(UIView*)viewToAdjust
        adjustmentSize:(CGSize)adjSize
		  keepCentered:(BOOL)center
              delegate:(id <IATViewSizerDelegate>)newDelegate
{
    id sizer = [[IATViewSizer alloc] init];
	if (sizer) {
		[sizer setView:viewToHide];
		[sizer setAdjustingView:viewToAdjust];
		[sizer setAdjustmentVector:adjSize];
		[sizer setKeepCentered:center];
		
		[sizer setDelegate:newDelegate];
	}
	
    return sizer;
}

- (void)dealloc
{
	[self setView:nil];
	[self setAdjustingView:nil];
	[self setDelegate:nil];
}

- (void)sizeAnimated:(BOOL)animated
{
	if (self.resized)
        return;
    
    if ([self.delegate respondsToSelector:@selector(viewSizer:willSizeView:animated:)])
        [self.delegate viewSizer:self willSizeView:self.view animated:animated];

    self.resized = YES;
	self.resing = YES;
	void (^sizeBlock)(void) = ^(){
		CGRect newFrame = self.view.frame;
		newFrame.size.width += _adjustmentVector.width;
		newFrame.size.height += _adjustmentVector.height;
		newFrame.origin.x -= (_adjustmentVector.width * 0.5f);
		newFrame.origin.y -= (_adjustmentVector.height * 0.5f);
		self.view.frame = newFrame;

#pragma warning("disabled adjusting view for IATViewSizer")
		//    CGRect newAdjFrame = self.adjustingView.frame;
		//    newAdjFrame.origin.y += hideVector.y;
		//    newAdjFrame.size.height -= hideVector.y;
		//    newAdjFrame.origin.x += hideVector.x;
		//    newAdjFrame.size.width -= hideVector.x;
		//    self.adjustingView.frame = newAdjFrame;
	};
	
	void (^sizeCompletionBlock)(BOOL finished) = ^(BOOL finished){
		self.resing = NO;
		if ([self.delegate respondsToSelector:@selector(viewSizer:didSizeView:)])
			[self.delegate viewSizer:self didSizeView:self.view];
	};

	if (animated)
		[UIView animateWithDuration:0.33f
							  delay:0.0f
							options:UIViewAnimationOptionBeginFromCurrentState |
		 UIViewAnimationOptionCurveEaseInOut
						 animations:sizeBlock
						 completion:sizeCompletionBlock];
	else {
		sizeBlock();
		sizeCompletionBlock(YES);
	}
}


- (void)unsizeAnimated:(BOOL)animated
{
	if (!self.resized)
        return;
    
    if ([self.delegate respondsToSelector:@selector(viewSizer:willUnsizeView:animated:)])
        [self.delegate viewSizer:self willUnsizeView:self.view animated:animated];

    self.resized = NO;
	self.resing = YES;
	void (^sizeBlock)(void) = ^(){
		CGRect newFrame = self.view.frame;
		newFrame.size.width -= _adjustmentVector.width;
		newFrame.size.height -= _adjustmentVector.height;
		newFrame.origin.x += (_adjustmentVector.width * 0.5f);
		newFrame.origin.y += (_adjustmentVector.height * 0.5f);
		self.view.frame = newFrame;
		
#pragma warning("disabled adjusting view for IATViewSizer")
		//    CGRect newAdjFrame = self.adjustingView.frame;
		//    newAdjFrame.origin.y -= hideVector.y;
		//    newAdjFrame.size.height += hideVector.y;
		//    newAdjFrame.origin.x -= hideVector.x;
		//    newAdjFrame.size.width += hideVector.x;
		//    self.adjustingView.frame = newAdjFrame;
	};
	
	void (^sizeCompletionBlock)(BOOL finished) = ^(BOOL finished){
		self.resing = NO;
		if ([self.delegate respondsToSelector:@selector(viewSizer:didUnsizeView:)])
			[self.delegate viewSizer:self didUnsizeView:self.view];
	};
	
	if (animated)
		[UIView animateWithDuration:0.33f
							  delay:0.0f
							options:UIViewAnimationOptionBeginFromCurrentState |
									 UIViewAnimationOptionCurveEaseInOut
						 animations:sizeBlock
						 completion:sizeCompletionBlock];
	else {
		sizeBlock();
		sizeCompletionBlock(YES);
	}
}

@end




