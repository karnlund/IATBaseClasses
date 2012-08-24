//
//  IATIntRange.m
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/19/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATIntRange.h"

IATIntRange R5UnionIntRange(IATIntRange range1, IATIntRange range2)
{
	NSInteger maxLocation = MAX(R5MaxIntRange(range1), R5MaxIntRange(range2));
	NSInteger minLocation = MIN(range1.location, range2.location);
	
	return R5MakeIntRange(minLocation, (NSUInteger)(maxLocation - minLocation));
}

IATIntRange R5IntersectionIntRange(IATIntRange range1, IATIntRange range2)
{
	NSInteger maxLocation1 = R5MaxIntRange(range1);
	NSInteger maxLocation2 = R5MaxIntRange(range2);

	if ((range1.location <= range2.location) && (maxLocation1 >= range2.location)) {
		return R5MakeIntRange(range2.location, (NSUInteger)(maxLocation1 - range2.location));
	}
	else if ((range2.location <= range1.location) && (maxLocation2 >= range1.location)) {
		return R5MakeIntRange(range1.location, (NSUInteger)(maxLocation2 - range1.location));
	}
	return R5MakeIntRange(0, 0);
}

NSString *NSStringFromIntRange(IATIntRange range)
{
	return [NSString stringWithFormat:@"[ %d, %d ]", range.location, range.length];
}

IATIntRange IATIntRangeFromString(NSString *aString)
{
	return R5MakeIntRange(0, 0);
}

NSRange NSRangeFromIntRange(IATIntRange range)
{
	NSRange unsignedRange;
	
	if (range.location >= 0)
		unsignedRange.location = (NSUInteger)range.location;
	else
		unsignedRange.location = 0;
	
	NSInteger maxLocation = R5MaxIntRange(range);
	
	unsignedRange.length = (NSUInteger)maxLocation - unsignedRange.location;
	
	return unsignedRange;
}

@implementation NSValue (R5ValueIntRangeExtensions)

+ (NSValue *)valueWithIntRange:(IATIntRange)range
{
	return [NSValue valueWithBytes:&range objCType:@encode(IATIntRange)];
}

- (IATIntRange)intRangeValue
{
	return  *((IATIntRange*)[self pointerValue]);
}

@end
