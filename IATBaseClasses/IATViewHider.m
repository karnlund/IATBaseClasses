//
//  IATViewHider.m
//
//  Created by Kurt Arnlund on 4/25/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATViewHider.h"
#import <QuartzCore/QuartzCore.h>


@implementation IATViewHider

+ (id)viewHiderForView:(UIView*)viewToHide
         adjustingView:(UIView*)viewToAdjust
        usingParameter:(AdjustUsingParameter)param 
    offscreenDirection:(OffscreenDirection)direction 
              delegate:(id <IATViewHiderDelegate>)newDelegate
{
    id hider = [[IATViewHider alloc] init];
	if (hider) {
		[hider setView:viewToHide];
		[hider setAdjustingView:viewToAdjust];
		
		if (param == USING_HEIGHT) {
			switch (direction) {
				case DIRECTION_UP:
					[hider setHideVectorFromViewHeightUp];
					break;
				case DIRECTION_DOWN:
					[hider setHideVectorFromViewHeightDown];
					break;
				default:
					break;
			}
		}
		else {
			if (param == USING_WIDTH) {
				switch (direction) {
					case DIRECTION_RIGHT:
						[hider setHideVectorFromViewWidthRight];
						break;
					case DIRECTION_LEFT:
						[hider setHideVectorFromViewWidthLeft];
						break;
					default:
						break;
				}
			}
		}
		[hider setDelegate:newDelegate];
	}
	
    return hider;
}

- (void)dealloc
{
	[self setView:nil];
	[self setAdjustingView:nil];
	[self setDelegate:nil];
}

- (void)setHideVectorFromViewHeightUp
{
	_hideVector.x = 0.0f;
	_hideVector.y = -_view.frame.size.height;
}

- (void)setHideVectorFromViewHeightDown
{
	_hideVector.x = 0.0f;
	_hideVector.y = _view.frame.size.height;
}

- (void)setHideVectorFromViewWidthLeft
{
	_hideVector.x = -_view.frame.size.width;
	_hideVector.y = 0.0f;
}

- (void)setHideVectorFromViewWidthRight
{
	_hideVector.x = _view.frame.size.width;
	_hideVector.y = 0.0f;
}

- (void)hideAnimated:(BOOL)animated
{
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(hideAnimated:) withObject:[NSNumber numberWithBool:animated] waitUntilDone:NO];
		return;
	}

	if (self.hidden)
        return;
    
    self.hidden = YES;
    
    if ([self.delegate respondsToSelector:@selector(viewHider:willHideView:animated:)])
        [self.delegate viewHider:self willHideView:_view animated:animated];
	
	void (^hideBlock)(void) = ^(){
		CGRect newFrame = self.view.frame;
		newFrame.origin.y += _hideVector.y - _sizeVector.height;
		newFrame.origin.x += _hideVector.x - _sizeVector.width;
		newFrame.size.height += _sizeVector.height;
		newFrame.size.width += _sizeVector.width;
		self.view.frame = newFrame;
		
		if (self.adjustingView) {
			CGRect newAdjFrame = self.adjustingView.frame;
			if ((_hideVector.y < 0) && (newFrame.origin.y < newAdjFrame.origin.y)) {
				newAdjFrame.origin.y += _hideVector.y;
				newAdjFrame.size.height -= _hideVector.y;
			}
			else
				newAdjFrame.size.height += _hideVector.y;
			
			if ((_hideVector.x < 0) && (newFrame.origin.x < newAdjFrame.origin.x)) {
				newAdjFrame.origin.x += _hideVector.x;
				newAdjFrame.size.width -= _hideVector.x;
			}
			else
				newAdjFrame.size.width += _hideVector.x;
			self.adjustingView.frame = newAdjFrame;
		}
	};
	
	void (^hideCompletionBlock)(BOOL finished) = ^(BOOL finished){
		if ([self.delegate respondsToSelector:@selector(viewHider:didHideView:)])
			[self.delegate viewHider:self didHideView:_view];
		[self.view setHidden:YES];
	};
	
	CGFloat duration = 0.0f;
	if (animated)
		duration = 0.33f;

	[UIView animateWithDuration:duration
						  delay:0.0f
						options:UIViewAnimationOptionOverrideInheritedDuration|
								 UIViewAnimationOptionOverrideInheritedCurve |
								 UIViewAnimationOptionBeginFromCurrentState |
								 UIViewAnimationOptionCurveEaseInOut
					 animations:hideBlock
					 completion:hideCompletionBlock];
}

- (void)showAnimated:(BOOL)animated
{
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(showAnimated:) withObject:[NSNumber numberWithBool:animated] waitUntilDone:NO];
		return;
	}
	
	if (!self.hidden)
        return;
    
    self.hidden = NO;
	
	[self.view setHidden:NO];
	
    if ([self.delegate respondsToSelector:@selector(viewHider:willShowView:animated:)])
        [self.delegate viewHider:self willShowView:_view animated:animated];
    
	void (^hideBlock)(void) = ^(){
		CGRect newFrame = self.view.frame;
		newFrame.origin.y -= _hideVector.y - _sizeVector.height;
		newFrame.origin.x -= _hideVector.x - _sizeVector.width;
		newFrame.size.height -= _sizeVector.height;
		newFrame.size.width -= _sizeVector.width;
		self.view.frame = newFrame;
		
		if (self.adjustingView) {
			CGRect newAdjFrame = self.adjustingView.frame;
			newAdjFrame.origin.y -= _hideVector.y;
			newAdjFrame.size.height += _hideVector.y;
			newAdjFrame.origin.x -= _hideVector.x;
			newAdjFrame.size.width += _hideVector.x;
			self.adjustingView.frame = newAdjFrame;
		}
	};
	
	void (^hideCompletionBlock)(BOOL finished) = ^(BOOL finished){
		if ([self.delegate respondsToSelector:@selector(viewHider:didShowView:)])
			[self.delegate viewHider:self didShowView:_view];
	};

	CGFloat duration = 0.0f;
	if (animated)
		duration = 0.33f;

	[UIView animateWithDuration:duration
						  delay:0.0f
						options:UIViewAnimationOptionOverrideInheritedDuration|
								 UIViewAnimationOptionOverrideInheritedCurve |
								 UIViewAnimationOptionBeginFromCurrentState |
								 UIViewAnimationOptionCurveEaseInOut
					 animations:hideBlock
					 completion:hideCompletionBlock];

}

@end
