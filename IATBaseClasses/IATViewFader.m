//
//  IATViewFader.m
//
//  Created by Kurt Arnlund on 4/25/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATViewFader.h"
#import <QuartzCore/QuartzCore.h>

@implementation IATViewFader

+ (id)viewFaderForView:(UIView*)viewToHide
              delegate:(id <IATViewFaderDelegate>)newDelegate
{
    id hider = [[IATViewFader alloc] init];
	if (hider) {
		[hider setView:viewToHide];
		[hider setDelegate:newDelegate];
	}
    return hider;
}

- (void)dealloc
{
	[self setView:nil];
	[self setDelegate:nil];
}

- (void)fadeAnimated:(BOOL)animated
{
	if (_faded)
        return;
    
    _faded = YES;
    
    if ([self.delegate respondsToSelector:@selector(viewFader:willHideView:animated:)])
        [self.delegate viewFader:self willHideView:_view animated:animated];
	
	void (^fadeBlock)(void) = ^(){
		_view.layer.opacity = 0.0;
	};
	
	void (^fadeCompletionBlock)(BOOL finished) = ^(BOOL finished){
		if ([self.delegate respondsToSelector:@selector(viewFader:didHideView:)])
			[self.delegate viewFader:self didHideView:_view];
        fadeBlock();
	};

	if (animated)
		[UIView animateWithDuration:0.33f
							  delay:0.0f
							options:UIViewAnimationOptionBeginFromCurrentState |
		 							UIViewAnimationOptionCurveEaseInOut
						 animations:fadeBlock
						 completion:fadeCompletionBlock];
	else {
		fadeBlock();
		fadeCompletionBlock(YES);
	}	
}

- (void)showAnimated:(BOOL)animated
{
	if (!_faded)
        return;
    
    _faded = NO;
    
    if ([self.delegate respondsToSelector:@selector(viewFader:willShowView:animated:)])
        [self.delegate viewFader:self willShowView:_view animated:animated];
	
	void (^fadeBlock)(void) = ^(){
		_view.layer.opacity = 1.0;
	};
	
	void (^fadeCompletionBlock)(BOOL finished) = ^(BOOL finished){
		if ([self.delegate respondsToSelector:@selector(viewFader:didShowView:)])
			[self.delegate viewFader:self didShowView:_view];
        fadeBlock();
	};
	
	if (animated)
		[UIView animateWithDuration:0.33f
							  delay:0.0f
							options:UIViewAnimationOptionBeginFromCurrentState |
                                    UIViewAnimationOptionCurveEaseInOut
						 animations:fadeBlock
						 completion:fadeCompletionBlock];
	else {
		fadeBlock();
		fadeCompletionBlock(YES);
	}
}

@end
