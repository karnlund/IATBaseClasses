//
//  IATCarouselData.h
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/10/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAVectorUtilities.h"
#import "IATIntRange.h"

///
#pragma mark - Layout Keys
///
#define kLayoutAxisA	@"axisA"
#define kLayoutAxisB	@"axisB"
#define kLayoutCenterX	@"centerX"
#define kLayoutCenterY	@"centerY"
#define kLayoutCenterZ	@"centerZ"
#define kLayoutRotation	@"rotation"
#define kLayoutNumVisibleCells	@"cellCountOnCarousel"		// Should be an ODD value for the best looking carousel
#define kLayoutStartPositionAngleOffset	@"posAngleOffset"

///
#pragma mark - Carousel Keys
///
#define kCarouselPanelSnapRange		@"carouselPanelSnapRange"

///
#pragma mark - Panel Keys
///
#define kPanelTilt	@"tilt"

@interface IATCarouselData : NSObject <NSCoding>

@property (readwrite, strong, nonatomic) NSMutableDictionary *layoutData;
@property (readwrite, strong, nonatomic) NSMutableDictionary *carouselData;
@property (readwrite, strong, nonatomic) NSMutableDictionary *panelData;

+ (IATCarouselData*)shared;

- (void)initialValuesForVeeLayout;

- (vector)layoutCenter;
- (CGSize)layoutAxisSizes;

- (IATIntRange)initialVisibleCellRangeInt;
- (NSRange)initialVisibleCellRange;

- (NSString*)preferredSettingsBaseName;
- (NSArray*)settingsFilesAvailable;
- (void)selectSettingsFileAtIndex:(NSUInteger)index;
- (void)nextSettingsFile;
- (void)createNewSettingsFileWithName:(NSString*)name;

- (void)save;
- (void)load;

@end
