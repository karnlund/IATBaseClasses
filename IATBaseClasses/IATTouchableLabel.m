//
//  IATTouchableLabel.m
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 8/1/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATTouchableLabel.h"

@implementation IATTouchableLabel

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(touchableLabel:touchesEnded:withEvent:)])
        [self.delegate touchableLabel:self touchesEnded:touches withEvent:event];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUserInteractionEnabled:YES];
}

@end
