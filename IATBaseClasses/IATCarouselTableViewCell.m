//
//  IATCarouselCell.m
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/3/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATCarouselTableViewCell.h"

@interface IATCarouselTableViewCell ()
@property (readwrite, strong, nonatomic)		NSString	*reuseIdentifier;
@end



@implementation IATCarouselTableViewCell
@synthesize enabled = _enabled;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.reuseIdentifier = [coder decodeObjectForKey:@"reuseIdentifier"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:self.reuseIdentifier forKey:@"reuseIdentifier"];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier
{
    self = [super initWithFrame:frame];
    if (self) {
        self.reuseIdentifier = identifier;
    }
    return self;
}

- (NSString*)debugDescription
{
	return [NSString stringWithFormat:@"reuseIdentifier:%@\n%@",
			self.reuseIdentifier, [super debugDescription]];
}

- (BOOL)isEnabled
{
	return _enabled;
}

- (void)setEnabled:(BOOL)newEnableState
{
	_enabled = newEnableState;
}

- (void)prepareForReuse
{
	
}

@end
