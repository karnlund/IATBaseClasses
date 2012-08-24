//
//  IATCarouselData.m
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/10/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATCarouselData.h"

@implementation IATCarouselData
@synthesize layoutData = _layoutData;
@synthesize carouselData = _carouselData;
@synthesize panelData = _panelData;

+ (IATCarouselData*)shared
{
	static dispatch_once_t onceToken;
	static IATCarouselData *carouselData = nil;
	dispatch_once(&onceToken, ^{
		carouselData = [[IATCarouselData alloc] init];
	});
	return carouselData;
}

- (id)init
{
    self = [super init];
    if (self) {
		[self initialValuesForVeeLayout];
		[self initialValuesForCarousel];
		[self initialValuesForPanels];
		[self load];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self) {
        _layoutData = [coder decodeObjectForKey:@"layoutData"];
        _carouselData = [coder decodeObjectForKey:@"carouselData"];
        _panelData = [coder decodeObjectForKey:@"panelData"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_layoutData forKey:@"layoutData"];
	[coder encodeObject:_carouselData forKey:@"carouselData"];
	[coder encodeObject:_panelData forKey:@"panelData"];
}

- (NSString*)debugDescription
{
	return [NSString stringWithFormat:@"%@ / %@ / %@", _layoutData, _carouselData, _panelData];
}


#pragma mark - FILE I/O

- (NSString *)filePath
{
	NSString *baseFilename = [self preferredSettingsBaseName];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:baseFilename ofType:@"plist"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		return filePath;
	return nil;
}

- (NSString*)filePathInDocs
{
	NSArray *docsDirs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	NSURL *docsURL = [docsDirs lastObject];
	NSString *baseFilename = [self preferredSettingsBaseName];
	NSString *filePath = [[docsURL path] stringByAppendingPathComponent:baseFilename];
	filePath = [filePath stringByAppendingPathExtension:@"plist"];
	return filePath;
}

- (NSString*)preferredSettingsBaseName
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"carouselSettingsBaseName"])
		return [[NSUserDefaults standardUserDefaults] stringForKey:@"carouselSettingsBaseName"];

	return @"carousel_settings";
}

- (void)storePreferredSettingsBaseName:(NSString*)basename
{
	[[NSUserDefaults standardUserDefaults] setObject:basename forKey:@"carouselSettingsBaseName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray*)settingsFilesAvailable
{
	NSArray *docsDirs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	NSURL *docsURL = [docsDirs lastObject];
	NSArray *results = [NSArray array];
	
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[docsURL path] error:nil];
	if (dirContents) {
		for (NSString* filename in dirContents) {
			NSRange carouselRange = [filename rangeOfString:@"carousel"];
			if (carouselRange.location != NSNotFound) {
				results = [results arrayByAddingObject:[filename stringByDeletingPathExtension]];
			}
		}
	}
	
	return results;
}

- (void)selectSettingsFileAtIndex:(NSUInteger)index
{
	NSArray *files = [self settingsFilesAvailable];
	NSString *selected = [files objectAtIndex:index];
	
//	NSLog(@"files:\n%@\nselecting settings '%@'", files, selected);
	
	[self storePreferredSettingsBaseName:[selected stringByDeletingPathExtension]];
	[self load];
}

- (void)nextSettingsFile
{
    NSArray *settingsFiles = [self settingsFilesAvailable];
    if (settingsFiles.count <= 1)
        return;
    
    NSUInteger idx = [settingsFiles indexOfObject:[self preferredSettingsBaseName]];
    
    idx++;
    idx %= settingsFiles.count;
    [self selectSettingsFileAtIndex:idx];
    [self load];
}

- (void)createNewSettingsFileWithName:(NSString*)name
{
	NSRange carouselRange = [name rangeOfString:@"carousel_"];
	if (carouselRange.location == NSNotFound)
		name = [NSString stringWithFormat:@"carousel_%@", name];
	[self storePreferredSettingsBaseName:name];

	NSString *filePath;
	
	filePath = [self filePathInDocs];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
		[NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

- (void)save
{
	NSString *filePath = [self filePathInDocs];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	
	[NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

- (void)load
{
	NSString *filePath = [self filePathInDocs];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
		filePath = nil;
	
	if (!filePath) {
		filePath = [self filePath];

		if (!filePath) {
			filePath = [self filePathInDocs];
			[NSKeyedArchiver archiveRootObject:self toFile:filePath];
		}
	}

	NSData *settings = [NSData dataWithContentsOfFile:filePath];
	IATCarouselData *cd = [NSKeyedUnarchiver unarchiveObjectWithData:settings];
	
	_layoutData = cd.layoutData;
	_carouselData = cd.carouselData;
	_panelData = cd.panelData;
}

- (NSDictionary *)layoutData
{
	if (!_layoutData)
		_layoutData = [NSMutableDictionary dictionary];
	return _layoutData;
}

- (NSDictionary *)carouselData
{
	if (!_carouselData)
		_carouselData = [NSMutableDictionary dictionary];
	return _carouselData;
}

- (NSDictionary *)panelData
{
	if (!_panelData)
		_panelData = [NSMutableDictionary dictionary];
	return _panelData;
}


#pragma mark - Dictionary values and value accessor methods


- (void)initialValuesForVeeLayout
{
	[self.layoutData setObject:[NSNumber numberWithFloat:600.0f] forKey:kLayoutAxisA];
	[self.layoutData setObject:[NSNumber numberWithFloat:300.0f] forKey:kLayoutAxisB];
	
	[self.layoutData setObject:[NSNumber numberWithFloat:0.0f] forKey:kLayoutCenterX];
	[self.layoutData setObject:[NSNumber numberWithFloat:0.0f] forKey:kLayoutCenterY];
	[self.layoutData setObject:[NSNumber numberWithFloat:0.0f] forKey:kLayoutCenterZ];
	
	[self.layoutData setObject:[NSNumber numberWithFloat:0.0f] forKey:kLayoutRotation];
	
	// Should be an ODD value for the best looking carousel
	[self.layoutData setObject:[NSNumber numberWithUnsignedInteger:5] forKey:kLayoutNumVisibleCells];

	// 180.0 is midway to 360.0 - Center the starting cell
	[self.layoutData setObject:[NSNumber numberWithFloat:180.0f] forKey:kLayoutStartPositionAngleOffset]; 
}

- (void)initialValuesForCarousel
{
	[self.carouselData setObject:[NSNumber numberWithFloat:0.3f] forKey:kCarouselPanelSnapRange];
}

- (void)initialValuesForPanels
{
	[self.panelData setObject:[NSNumber numberWithFloat:0.0f] forKey:kPanelTilt];
}

#pragma mark - Value helpers

- (vector)layoutCenter
{
	return vectorMake([[_layoutData valueForKey:kLayoutCenterX] floatValue], 
					  [[_layoutData valueForKey:kLayoutCenterY] floatValue],
					  [[_layoutData valueForKey:kLayoutCenterZ] floatValue]);
}

- (CGSize)layoutAxisSizes
{
	return CGSizeMake([[_layoutData valueForKey:kLayoutAxisA] floatValue],
					  [[_layoutData valueForKey:kLayoutAxisB] floatValue]);
}

#pragma mark - Utilities

- (IATIntRange)initialVisibleCellRangeInt
{
	NSUInteger visibleCells = [[self.layoutData objectForKey:kLayoutNumVisibleCells] unsignedIntegerValue];
	NSInteger half = ((visibleCells) / 2) + 0.5;

	return R5MakeIntRange(-half, visibleCells);
}

- (NSRange)initialVisibleCellRange
{
	IATIntRange intRange = [self initialVisibleCellRangeInt];
	
	return NSMakeRange(0, (NSUInteger)R5MaxIntRange(intRange));
}

@end
