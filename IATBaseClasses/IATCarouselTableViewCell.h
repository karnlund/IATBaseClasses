//
//  IATCarouselCell.h
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/3/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IATCarouselTableViewCell : UIView <NSCoding, UIGestureRecognizerDelegate>

@property (readonly, strong, nonatomic)		NSString	*reuseIdentifier;
@property (readwrite, assign, nonatomic, getter = isEnabled)		BOOL	enabled;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier;

- (NSString*)debugDescription;

- (void)prepareForReuse;

@end
