//
//  IATIntRange.h
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/19/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <Foundation/NSValue.h>
#import <Foundation/NSObjCRuntime.h>

@class NSString;

typedef struct _IATIntRange {
    NSInteger location;
    NSUInteger length;
} IATIntRange;

typedef IATIntRange *IATIntRangePointer;

NS_INLINE IATIntRange R5MakeIntRange(NSInteger loc, NSUInteger len) {
    IATIntRange r;
    r.location = loc;
    r.length = len;
    return r;
}

NS_INLINE NSInteger R5MaxIntRange(IATIntRange range) {
    return (range.location + (NSInteger)range.length);
}

NS_INLINE BOOL R5LocationInIntRange(NSInteger loc, IATIntRange range) {
    return (loc - range.location < range.length);
}

NS_INLINE BOOL R5EqualIntRanges(IATIntRange range1, IATIntRange range2) {
    return (range1.location == range2.location && range1.length == range2.length);
}

FOUNDATION_EXPORT IATIntRange R5UnionIntRange(IATIntRange range1, IATIntRange range2);
FOUNDATION_EXPORT IATIntRange R5IntersectionIntRange(IATIntRange range1, IATIntRange range2);
FOUNDATION_EXPORT NSString *NSStringFromIntRange(IATIntRange range);
FOUNDATION_EXPORT IATIntRange IATIntRangeFromString(NSString *aString);
FOUNDATION_EXPORT NSRange NSRangeFromIntRange(IATIntRange range);

@interface NSValue (R5ValueIntRangeExtensions)

+ (NSValue *)valueWithIntRange:(IATIntRange)range;
- (IATIntRange)intRangeValue;

@end

