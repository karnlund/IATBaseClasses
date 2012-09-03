//
//  IATCarouselView.m
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/3/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATCarouselTableView.h"
#import "TPPropertyAnimation.h"
#import "IATPerspectiveView.h"
#import "IATCarouselTableViewCell.h"
#import "IATCarouselData.h"
#import "CATransformUtilities.h"
#import "CAVectorUtilities.h"
#import "IATLayoutFunction2D.h"

#define TOUCH_DETECT_DRAG_OFFSET_LIMIT	12.0f
#define DISTANCE_SCALE		0.5f
//#define ENABLE_SHADOWS 		1

const CGFloat previousVelocityWeight = 0.75;

@interface IATCarouselTableView ()
<TPPropertyAnimationDelegate>

@property (readwrite, strong, nonatomic)	NSMutableDictionary	*cellReuseCache;/* cell identifier => mutable array of cells ready for reuse */
@property (readwrite, strong, nonatomic)	NSMutableDictionary *cellLookup;	/* cell identifier => cell that is archived */
@property (readwrite, strong, nonatomic)	NSMutableDictionary *cellNibLookup; /* cell identifier => cell nib */
@property (readwrite, strong, nonatomic)	IATPerspectiveView	*containerView;
@property (readwrite, strong, nonatomic)	IATPerspectiveView	*shadowContainerView;
@property (readwrite, strong, nonatomic)	NSMutableArray	*cells;
@property (readwrite, strong, nonatomic)	NSNumber	*angleAccumulator;
@property (readwrite, strong, nonatomic)	NSIndexPath	*centralCellIndexPath;

@property (readwrite, assign, nonatomic)	CGFloat currentDragVelocity;
@property (readwrite, assign, nonatomic)	CGPoint	dragOrigin;
@property (readwrite, assign, nonatomic)	CGFloat dragOffset;
@property (readwrite, assign, nonatomic)	CGFloat dragCellCountOffset;
@property (readwrite, assign, nonatomic)	NSInteger dragCellCountOffsetInteger;
@property (readwrite, assign, nonatomic)	CGFloat offsetAngle;
@property (readwrite, assign, nonatomic)	CGFloat degressPerCell;
@property (readwrite, assign, nonatomic)	NSRange visibleRange;

@property (readwrite, strong, nonatomic)	NSDate *startTime;
@property (readwrite, assign, nonatomic)	CGFloat startAngle;

- (void)buildContainerLookMatrix;
@end


@implementation IATCarouselTableView

- (void)dealloc
{
	[self stopObservingOrientationChanges];
	[self.containerView removeFromSuperview];
	[self.shadowContainerView removeFromSuperview];
	[self setCells:nil];
	[self setAngleAccumulator:nil];
	[self setCellReuseCache:nil];
	[self setCellLookup:nil];
	[self setCellNibLookup:nil];
	[self setContainerView:nil];
	[self setShadowContainerView:nil];
	[self setCellPrototypes:nil];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _cellReuseCache = [coder decodeObjectForKey:@"cellReuseCache"];
		_cellLookup = [coder decodeObjectForKey:@"cellLookup"];
        _cellNibLookup = [coder decodeObjectForKey:@"cellNibLookup"];
        _dataSource = [coder decodeObjectForKey:@"dataSource"];
        _delegate = [coder decodeObjectForKey:@"delegate"];
        _containerView = [coder decodeObjectForKey:@"containerView"];
		_shadowContainerView = [coder decodeObjectForKey:@"shadownContainerView"];
        _cells = [coder decodeObjectForKey:@"cells"];
        _angleAccumulator = [coder decodeObjectForKey:@"angleAccumulator"];
        _scrollEnabled = [[coder decodeObjectForKey:@"scrollEnabled "] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	
	[coder encodeObject:_cellReuseCache forKey:@"cellReuseCache"];
	[coder encodeObject:_cellLookup forKey:@"cellLookup"];
	[coder encodeObject:_cellNibLookup forKey:@"cellNibLookup"];
	[coder encodeObject:_dataSource forKey:@"dataSource"];
	[coder encodeObject:_delegate forKey:@"delegate"];
	[coder encodeObject:_containerView forKey:@"containerView"];
	[coder encodeObject:_shadowContainerView forKey:@"shadownContainerView"];
	[coder encodeObject:_cells forKey:@"cells"];
	[coder encodeObject:_angleAccumulator forKey:@"angleAccumulator"];
	[coder encodeObject:[NSNumber numberWithBool:_scrollEnabled] forKey:@"scrollEnabled"];
}

- (void)removeFromSuperview
{
	[self stopObservingOrientationChanges];
	[super removeFromSuperview];
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	if (self.superview) {
		// UMM WFT.. this gets called during the call to [super removeFromSuperview] above.
		// but of course the superview is null, so it can't possibly have moved to
		// a superview.
		[self observeOrientationChanges];
	}
}

-(void)awakeFromNib
{
	self.scrollEnabled = YES;
	self.cells = [NSMutableArray arrayWithCapacity: 10];
	self.containerView = [[IATPerspectiveView alloc] initWithFrame:self.bounds];
	self.shadowContainerView = [[IATPerspectiveView alloc] initWithFrame:self.bounds];
	_angleAccumulator = [NSNumber numberWithFloat:0.0f];
	
	[self addSubview: self.shadowContainerView];
	[self addSubview: self.containerView];
	
	[self buildContainerLookMatrix];
}

- (void)buildContainerLookMatrix
{
	[[self containerView] tiltDegrees: 0.0f]; // [tiltSlider value]
	[[self shadowContainerView] tiltDegrees: 0.0f];
}

- (NSArray*)visibleCells
{
	NSArray *visCells = [NSArray array];
	for (IATCarouselTableViewCell *cell in self.cells)
	{
		if ([cell isKindOfClass:IATCarouselTableViewCell.class])
			visCells = [visCells arrayByAddingObject:cell];
	}
	return visCells;
}

#pragma mark - Angle Property Animation


- (void)propertyAnimationDidFinish:(TPPropertyAnimation*)propertyAnimation
{
	[self resetDragOffset];

	CGFloat ipRow = fabsf((self.angleAccumulator.floatValue + self.offsetAngle)/self.degressPerCell);
	self.centralCellIndexPath = [NSIndexPath indexPathForRow:ipRow
												   inSection:0];
	[self setNeedsLayout];
//	NSLog(@"stopped on index path %@", self.centralCellIndexPath);
	if ([self.delegate respondsToSelector:@selector(carouselDidStopSroll:onCellAtIndexPath:)])
		[self.delegate carouselDidStopSroll:self onCellAtIndexPath:self.centralCellIndexPath];
	
	[self enableCellAtIndexPath:self.centralCellIndexPath];
}

- (void)setAngleAccumulator:(NSNumber*)newValue
{
	// NOTE: YES THIS METHOD LOOKS SIMPLE, BUT THE CALL TO setNeedsLayout MAKES THE CELLS ANIMATE INTO POSITION
	_angleAccumulator = newValue;
	[self setNeedsLayout];
}

- (void)finalizeAngle:(CGFloat)finalAngle
{
	CGFloat ipRow = fabsf((self.angleAccumulator.floatValue + self.offsetAngle)/self.degressPerCell);
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ipRow
												inSection:0];
	if ([self.delegate respondsToSelector:@selector(carouselWillStopSroll:onCellAtIndexPath:)])
		[self.delegate carouselWillStopSroll:self onCellAtIndexPath:indexPath];
	
	if ([[NSDate date] timeIntervalSinceDate:self.startTime] < 0.4f) {
		NSUInteger numCells = [self.dataSource carouselView:self numberOfRowsInSection:0];
		
		TPPropertyAnimation *animation = [TPPropertyAnimation propertyMomentumAnimationForStartTime:self.startTime
																						 startValue:self.startAngle
																					   currentValue:self.angleAccumulator.floatValue + self.offsetAngle
																						   valueMod:self.degressPerCell
																					upperLimitValue:0
																					lowerLimitValue:(numCells - 1) * -self.degressPerCell
																					   deceleration:-8250.0  /* -4250 originally */
																						withKeyPath:@"angleAccumulator"];
		animation.delegate = self;
		[animation beginWithTarget:self];
	}
	else {
		TPPropertyAnimation *animation = [TPPropertyAnimation propertyAnimationWithKeyPath:@"angleAccumulator"];
		animation.toValue = [NSNumber numberWithFloat:finalAngle]; // fromValue is taken from current value if not specified
		animation.duration = 0.33f;
		animation.delegate = self;
		animation.timing = TPPropertyAnimationTimingEaseInEaseOut;
		[animation beginWithTarget:self];
	}
}


- (void)resetDragOffset {
	self.offsetAngle = 0.0f;
	self.dragOffset = 0.0f;
	self.dragCellCountOffset = 0;
	self.dragCellCountOffsetInteger = 0;
}


- (void)updateDragOffset:(CGPoint)location
{
	IATCarouselData *data = [IATCarouselData shared];
	NSUInteger visibleCells = [[data.layoutData valueForKey:kLayoutNumVisibleCells] unsignedIntegerValue];
	
	self.dragOffset = (self.dragOrigin.x - location.x);
	self.dragOffset *= DISTANCE_SCALE;
	self.dragCellCountOffset = (self.dragOffset / (CGRectGetWidth(self.bounds) / visibleCells));
	self.offsetAngle = -self.dragCellCountOffset * self.degressPerCell;
	
	self.dragCellCountOffsetInteger = floorf((self.angleAccumulator.floatValue + self.offsetAngle + (-self.degressPerCell * 0.5f)) / -self.degressPerCell);
}


- (NSRange)dragRange
{
	IATCarouselData *data = [IATCarouselData shared];
	
	IATIntRange visibleIntRange = [data initialVisibleCellRangeInt];
	IATIntRange dragRange = visibleIntRange;
	dragRange.location += self.dragCellCountOffsetInteger;
	dragRange.location = MAX(visibleIntRange.location, dragRange.location);
	
	return NSRangeFromIntRange(dragRange) ;
}


- (NSRange)visibleCellRange
{
	NSRange dragRange = [self dragRange];
	if ((NSInteger)dragRange.location < 0)
		dragRange.location = 0;
	
	if ((dragRange.location + 1 + dragRange.length) > self.cells.count)
		dragRange.location = self.cells.count - dragRange.length ;
	
	return dragRange;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	self.dragOrigin = location;
	
	[self resetDragOffset];
	
	self.startTime = [NSDate date];
	self.startAngle = self.angleAccumulator.floatValue + self.offsetAngle;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	CGFloat offset = (self.dragOrigin.x - location.x);
	if (fabsf(offset) > TOUCH_DETECT_DRAG_OFFSET_LIMIT) {
		
		if (self.scrollEnabled) {
			[self enableCellAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0]];
			
			[self updateDragOffset:location];
			
			[self setNeedsLayout];
			[self setNeedsDisplay];
		}
		
		if ([self.delegate respondsToSelector:@selector(carouselViewWillSroll:)])
            [self.delegate carouselViewWillSroll:self];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.scrollEnabled)
		return;
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	CGFloat offset = (self.dragOrigin.x - location.x);
	if (fabsf(offset) <= TOUCH_DETECT_DRAG_OFFSET_LIMIT)
		return;
	
	NSUInteger numCells = [self.dataSource carouselView:self numberOfRowsInSection:0];
	
	IATCarouselData *data = [IATCarouselData shared];
	CGFloat snapPercentage = [[data.carouselData objectForKey:kCarouselPanelSnapRange] floatValue];
	
	[self updateDragOffset:location];
	
	CGFloat correction = 0.0f;
	if (self.dragOffset > 0.0) {
		correction = self.offsetAngle;
		CGFloat overshoot = fmodf(correction, self.degressPerCell);
		correction -= overshoot;
		if (fabsf(overshoot) >= (self.degressPerCell * snapPercentage))
			correction += -self.degressPerCell;
	}
	else if (self.dragOffset < 0.0f) {
		correction = self.offsetAngle;
		CGFloat overshoot = fmodf(correction, self.degressPerCell);
		correction -= overshoot;
		if (fabsf(overshoot) >= (self.degressPerCell * snapPercentage))
			correction += self.degressPerCell;
	}
	correction += self.angleAccumulator.floatValue;
	CGFloat newAngleAccumulator = self.angleAccumulator.floatValue + self.offsetAngle;
	
	//	NSLog(@"dragOffset %3.2f\nangleAccumulator %3.2f -> final angle %3.2f", dragOffset, newAngleAccumulator, correction );
	correction = MIN(0, correction);
	correction = MAX((numCells-1) * -self.degressPerCell, correction);
	
	self.angleAccumulator = [NSNumber numberWithFloat: newAngleAccumulator];
	
	self.offsetAngle = 0.0f;
	
	// detect small movements as touches
	if ((self.dragOffset < TOUCH_DETECT_DRAG_OFFSET_LIMIT) && [touch.view isKindOfClass:[IATCarouselTableViewCell class]]) {
	}
	
	[self updateDragOffset:location];
	[self finalizeAngle: correction];
	
	[self resetDragOffset];
	
	self.dragCellCountOffsetInteger = floorf(correction / -self.degressPerCell);
	
	[self setNeedsLayout];
}


#pragma mark - Orientation Changes

- (void)observeOrientationChanges
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(viewOrientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification
											   object:nil];
}

- (void)stopObservingOrientationChanges
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewOrientationChanged:(NSNotification *)note
{
}


#pragma mark - Cell Layout

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	IATCarouselData *data = [IATCarouselData shared];
	vector layoutCenter = [data layoutCenter];
	CGSize layoutAxisSizes = [data layoutAxisSizes];
	CGFloat layoutRotation = [[data.layoutData valueForKey:kLayoutRotation] floatValue];
	CGFloat layoutCentralAngle = [[data.layoutData valueForKey:kLayoutStartPositionAngleOffset] floatValue];
	CGFloat layoutMaxAngle = layoutCentralAngle * 2.0f;
	CGFloat cellTilt = [[data.panelData valueForKey:kPanelTilt] floatValue];
	
	CGFloat startingOffset = [[data.layoutData valueForKey:kLayoutStartPositionAngleOffset] floatValue];
	
	NSUInteger cellIdent = 0;
	
	IATIntRange visibleRange_ = [data initialVisibleCellRangeInt];
	NSRange dragRange = [self dragRange];
	NSUInteger dragRangeMax = NSMaxRange(dragRange);
	
	CGFloat minVisibleAngle = startingOffset + (visibleRange_.location * self.degressPerCell) - self.degressPerCell;
	NSInteger visibleRangeMax = IATMaxIntRange(visibleRange_) - 1;
	CGFloat maxVisibleAngle = startingOffset + (visibleRangeMax * self.degressPerCell) + self.degressPerCell;
	
	NSUInteger maxCellInterp = ((fabsf(self.angleAccumulator.floatValue) + self.offsetAngle) / self.degressPerCell) + 3;
	
	// Temp array of cells to remove at the end
	NSArray *cellsToRemove = [NSArray array];
	
	// Evaluating this value here because if it's done in the for loop
	// it gets reevaluated each iteration causeing an infinite loop
	NSUInteger maxCellIdent = MAX(dragRangeMax + 3, self.cells.count);
	maxCellIdent = MAX(maxCellIdent, maxCellInterp);
	
	for (cellIdent = 0; cellIdent < maxCellIdent ; cellIdent++) {
		id cell = nil;
		if (cellIdent+1 > self.cells.count) {
			cell = [NSNull null];
			[self.cells addObject:cell];
		}
		else
			cell = [self.cells objectAtIndex:cellIdent];
		
		CGFloat cellDegPos = self.degressPerCell * cellIdent;
		CGFloat cellAngle = floor( startingOffset + cellDegPos + self.offsetAngle + [self.angleAccumulator floatValue] );
		
		if (![cell isKindOfClass:IATCarouselTableViewCell.class]) {
			if ((cellAngle >= minVisibleAngle) && (cellAngle <= maxVisibleAngle)) {
				cell = [self addCellAtIndex:cellIdent];
				if (!cell)
					continue;
				
				[self.cells replaceObjectAtIndex:cellIdent withObject:cell];
			}
			else {
				continue;
			}
		}
		else if (cellAngle < minVisibleAngle) {
			cellsToRemove = [cellsToRemove arrayByAddingObject:cell];
			continue;
		}
		else if (cellAngle > maxVisibleAngle) {
			cellsToRemove = [cellsToRemove arrayByAddingObject:cell];
			continue;
		}
		
		IATCarouselTableViewCell *cellView = (IATCarouselTableViewCell *)cell;
		
		CGPoint vLoc1 = CGPointMake( layoutCenter.s_vector.x + 5.0f,
									layoutCenter.s_vector.z );
		CGPoint vLoc2 = CGPointMake( layoutCenter.s_vector.x,
									layoutCenter.s_vector.z );
		CGPoint vLoc3 = CGPointMake( layoutCenter.s_vector.x - 5,
									layoutCenter.s_vector.z );
		
		CGFloat cellPos3D[3];
		CGFloat tangentVector[3];
		CGFloat upVector[3] = { unitVectorY[0], unitVectorY[1], unitVectorY[2] };
		CATransform3D tangentMatrix;
		
		if (cellAngle == layoutCentralAngle)
		{			
			// NOTE: When no touch/drag event is happening angleAccumulator, and offsetAngle are nil objects
			CGPoint cellPosTan1 = [IATLayoutFunction2D pointOnVee: vLoc1
														  axis: layoutAxisSizes
													  position: cellAngle
												   veeRotation: layoutRotation ];
			CGFloat cellPos3D_A[3] = { cellPosTan1.x, layoutCenter.s_vector.y, cellPosTan1.y };
			
			CGPoint cellPos = [IATLayoutFunction2D pointOnVee: vLoc2
													  axis: layoutAxisSizes
												  position: cellAngle
											   veeRotation: layoutRotation];
			cellPos3D[0] = cellPos.x, cellPos3D[1] = layoutCenter.s_vector.y, cellPos3D[2] = cellPos.y;
			
			CGPoint cellPosTan2 = [IATLayoutFunction2D pointOnVee: vLoc3
														  axis:layoutAxisSizes
													  position:cellAngle
												   veeRotation:layoutRotation];
			CGFloat cellPos3D_B[3] = { cellPosTan2.x, layoutCenter.s_vector.y, cellPosTan2.y };
			
			vectorDifference(tangentVector, cellPos3D_A, cellPos3D_B);
			
			vectorNormalize(tangentVector);
			CGFloat tangentVectorInverted[3];
			vectorInvert(tangentVectorInverted, tangentVector);
			
#ifdef ENABLE_SHADOWS
			cellView.cellReflectionView.layer.anchorPoint = CGPointMake(0.5, 1.0f);
#endif
			
			// Shadow Transform
			tangentMatrix = CATransform3DConstructOrthogonalMatrixUsingVectorsXY(tangentVector, upVector);
			
			// Central anchor point location
			cellView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
		}
		else {
			CGPoint cellPos = [IATLayoutFunction2D pointOnVee: vLoc2
													  axis: layoutAxisSizes
												  position: cellAngle
											   veeRotation: layoutRotation];
			cellPos3D[0] = cellPos.x, cellPos3D[1] = layoutCenter.s_vector.y, cellPos3D[2] = cellPos.y;
			
			// angle reflected across 180 (layoutCentralAngle)
			// unitAngle is a value between -1 and 1 that allows a cell rotation
			// value to be calculated based on how near the outside edges of the
			// carousel the cell is located.
			CGFloat unitAngle = ((cellAngle - layoutCentralAngle) / layoutCentralAngle);
			BOOL carryNegSign = unitAngle < 0.0f ? -1.0f : 1.0f;
			CGFloat rotationUnit = unitAngle * unitAngle * carryNegSign;
			CGFloat cellAngle1 = rotationUnit * 85.0f;
			
			// Use unitAngle to gradually nudge the cells anchor point to its
			// outside edges based on how near to the outside edge of the
			// carousel that cell is located.  This causes the calle to "fold"
			// away on it's most forward edge as the cell goes off-screen.
#ifdef ENABLE_SHADOWS
			cellView.cellReflectionView.layer.anchorPoint = CGPointMake(0.5f + (unitAngle * 0.5f), 1.0f);
#endif
			cellView.layer.anchorPoint = CGPointMake(0.5f + (unitAngle * 0.5f), 0.5f);
			
			tangentMatrix = CATransform3DMakeRotation(DEGREES_TO_RADIANS(-cellAngle1), upVector[0], upVector[1], upVector[2]);
		}

#ifdef ENABLE_SHADOWS
		CATransform3D rot = CATransform3DMakeRotation(DEGREES_TO_RADIANS(-90.0), 1.0f, 0.0f, 0.0f);
		CATransform3D trans = CATransform3DMakeTranslation(cellPos3D[0],
														   cellPos3D[1] +
														   cellView.cellReflectionView.bounds.size.height*0.5f +
														   [[data.layoutData valueForKey:kLayoutCellReflectionOffset] floatValue],
														   cellPos3D[2]);
		CATransform3D shadowFlattenMtx = CATransform3DConcat( rot, tangentMatrix );
		
		CATransform3D shadowTransform = CATransform3DIdentity;
		shadowTransform = CATransform3DConcat( shadowFlattenMtx, trans );
		
		cellView.cellReflectionView.layer.transform = shadowTransform;
		cellView.cellReflectionView.layer.zPosition = -1;
#endif
		
		// Cell Transform
		CATransform3D rotationMat = CATransform3DRotate(tangentMatrix, DEGREES_TO_RADIANS(cellTilt), 1.0f, 0.0f, 0.0f);
		CATransform3D translationMat = CATransform3DMakeTranslation(cellPos3D[0], cellPos3D[1], cellPos3D[2]);
		CATransform3D newTrans = CATransform3DConcat(rotationMat, translationMat);
		
		cellView.layer.transform = newTrans;
		
		// Adjust opacity and user interaction
		if (cellAngle != layoutCentralAngle) {
			cellAngle = MAX(cellAngle, 0.0);
			cellAngle = MIN(cellAngle, layoutMaxAngle);
			cellAngle = fmodf(cellAngle, layoutMaxAngle);
			if (cellAngle < layoutCentralAngle)
				cellView.layer.opacity = 0.3 + 0.9 * fabsf(cellAngle / layoutCentralAngle);
			if (cellAngle > layoutCentralAngle)
				cellView.layer.opacity = 0.3 + 0.9 * fabsf((layoutMaxAngle - cellAngle) / layoutCentralAngle);
#ifdef ENABLE_SHADOWS
			cellView.cellReflectionView.layer.opacity = cellView.layer.opacity;
#endif
			[cell setUserInteractionEnabled:NO];
		}
		else {
			[cell setUserInteractionEnabled:YES];
			cellView.layer.opacity = 1.0f;
#ifdef ENABLE_SHADOWS
			cellView.cellReflectionView.layer.opacity = 1.0f;
#endif
		}
	}
	
	for (IATCarouselTableViewCell *cell in cellsToRemove) {
		NSUInteger cellIdx = [self.cells indexOfObject:cell];
		
		[self enqueCellForReuse:cell];
		[self.cells replaceObjectAtIndex:cellIdx withObject:[NSNull null]];
	}
	
//	NSLog(@"%@",self.cells);
}


#pragma mark - Public Interface Methods

- (void)enqueCellForReuse:(IATCarouselTableViewCell*)cell
{
	if (![cell isKindOfClass:IATCarouselTableViewCell.class])
		return;
	
	// remove all tracking of cells
	[cell removeFromSuperview];
#ifdef ENABLE_SHADOWS
	[cell.cellReflectionView removeFromSuperview];
#endif
	
	NSMutableArray * reuseArray = [self.cellReuseCache objectForKey:cell.reuseIdentifier];
	if (!reuseArray)
		reuseArray = [NSMutableArray arrayWithCapacity:self.cells.count];
	
	[reuseArray addObject:cell];
	
	if (!self.cellReuseCache)
		self.cellReuseCache = [NSMutableDictionary dictionaryWithCapacity:1];
	
	[self.cellReuseCache setObject:reuseArray forKey:cell.reuseIdentifier];
}

- (void)enqueAllCellsForReuse
{
	// remove all tracking of cells
	for (IATCarouselTableViewCell *cell in self.cells) {
		if ([cell isKindOfClass:IATCarouselTableViewCell.class])
			[self enqueCellForReuse:cell];
	}
	[self.cells removeAllObjects];
}

- (IATCarouselTableViewCell *)addCellAtIndex:(NSUInteger)idx
{
	NSIndexPath *ip = [NSIndexPath indexPathForRow:idx inSection:0];
	
	NSInteger sectionCellCount = [self.dataSource carouselView:self numberOfRowsInSection:ip.section];
	
	if (ip.row+1 > sectionCellCount)
		return nil;
	
	IATCarouselTableViewCell *cell = [self.dataSource carouselView:self cellForRowAtIndexPath:ip];
	
	if ([self.delegate respondsToSelector:@selector(carouselView:sizeForRowAtIndexPath:)]) {
		CGSize cellSize = [self.delegate carouselView:self sizeForRowAtIndexPath:ip];
		
		if ((cellSize.width > 0) && (cellSize.height > 0)) {
			CGRect curFrame = cell.frame;
			curFrame.size = cellSize;
			cell.frame = curFrame;
		}
	}
	
	if ([self.delegate respondsToSelector:@selector(carouselView:willDisplayCell:forRowAtIndexPath:)])
		[self.delegate carouselView:self willDisplayCell:cell forRowAtIndexPath:ip];
	
	IATCarouselTableViewCell *nextCell = nil;
	if (ip.row+1 > [self.containerView subviews].count) {
		
		NSArray *subviews = [self.containerView subviews];
		if (ip.row+1 < subviews.count)
			nextCell = [[self.containerView subviews] objectAtIndex:ip.row+1];
	}
	if (nextCell) {
		[self.containerView insertSubview:cell belowSubview:nextCell];
#ifdef ENABLE_SHADOWS
		UIView *nextShadow = nextCell.cellReflectionView;
		if (cell.cellReflectionView && nextShadow) {
			if (nextShadow)
				[self.shadowContainerView insertSubview:cell.cellReflectionView belowSubview:nextShadow];
			else
				[self.shadowContainerView addSubview:cell.cellReflectionView];
		}
#endif
	}
	else {
		[self.containerView addSubview:cell];
#ifdef ENABLE_SHADOWS
		[self.shadowContainerView addSubview:cell.cellReflectionView];
#endif
	}
	return cell;
}

- (void)reloadData
{
	NSLog(@"reloadData");
	
	[self registerPrototypeCells];
	
	NSUInteger numCells = [self.dataSource carouselView:self numberOfRowsInSection:0];
	
	[self enqueAllCellsForReuse];
	
	// Row display. Implementers should *always* try to reuse cells by setting each cell's
	// reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
	// Cell  gets various attributes set automatically based on table (separators) and
	// data source (accessory views, editing controls)
	if (numCells == 0) {
		
	}
	else {
		IATCarouselData *data = [IATCarouselData shared];
		NSUInteger visibleCells = [[data.layoutData valueForKey:kLayoutNumVisibleCells] unsignedIntegerValue];
		
		self.visibleRange = [data initialVisibleCellRange];
		
		self.degressPerCell = 360.0f / (visibleCells - 1);
		
		// NOTE: This will need to use an existing NSRange "window" of cells to
		// reload only currently visible cells, or construct the range from
		// scratch including only cells that are visible (but right now that
		// determination is hard)
		//		NSLog(@"reloadData %d", numCells);
		
		for (NSUInteger idx = 0; idx < numCells; idx++) {
			if (!NSLocationInRange(idx, self.visibleRange))
				continue;
			
			IATCarouselTableViewCell * cell = [self addCellAtIndex:idx];
			
			if (cell)
				[self.cells addObject:cell];
		}
	}
	
	[self setNeedsLayout];
	
	self.centralCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self enableCellAtIndexPath:self.centralCellIndexPath];
}

- (NSIndexPath *)indexPathForCell:(IATCarouselTableViewCell *)cell
{
	NSUInteger row = [self.cells indexOfObject:cell];
	// returns nil if cell is not visible
	return [NSIndexPath indexPathForRow:row inSection:0];
}

- (IATCarouselTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// returns nil if cell is not visible or index path is out of range
	if (indexPath.row >= self.cells.count)
		return nil;
	
	id cell = [self.cells objectAtIndex:indexPath.row];
	if (![cell isKindOfClass:IATCarouselTableViewCell.class])
		return nil;
	
	return cell;
}

- (NSArray *)indexPathsForVisibleRows
{
	NSArray *visCells = [NSArray array];
	for (IATCarouselTableViewCell *cell in self.cells)
	{
		if ([cell isKindOfClass:IATCarouselTableViewCell.class])
			visCells = [visCells arrayByAddingObject:[self indexPathForCell:cell]];
	}
	return visCells;
}

- (NSIndexPath *)indexPathForSelectedRow
{
	return self.centralCellIndexPath;
}

- (IATCarouselTableViewCell *)selectedCell
{
	return [self cellForRowAtIndexPath:[self indexPathForSelectedRow]];
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
	// Method to acquire an already allocated cell, in lieu of allocating a new one.
	
	NSMutableArray *reuseableCells = [self.cellReuseCache objectForKey:identifier];
	
	// If no cells are available for reuse
	if (!reuseableCells || (reuseableCells.count == 0)) {
		// Look for a prototype cell that has been archived
		NSData *cellArchive = [self.cellLookup objectForKey:identifier];
		if (!cellArchive) {
			// Look for a nib to load a new cell from
			UINib *identiefierNib = [self.cellNibLookup valueForKey:identifier];
			if (!identiefierNib)
				return nil;
			
			// FUTURE TODO: load nib and scan for IATCarouselTableViewCell objects that have the requested identifier.
			// This can only work if you set a User Defined Runtime Attribute named "reuseIdentifier"
			// on the IATCarouselTableViewCell view.
			return nil;
		}
		id cell = [NSKeyedUnarchiver unarchiveObjectWithData:cellArchive];
		//		NSLog(@"%@", NSString FromCGAffineTransform(cell.transform));
		return cell;
	}
	
	// Grab one of the cells ready for reuse
	id cell = [reuseableCells lastObject];
	
	// Remove that cell from the resuseable list
	if (cell) {
		[reuseableCells removeObject:cell];
		
//		NSData *cellArchive = [self.cellLookup objectForKey:identifier];
//		cell = [NSKeyedUnarchiver unarchiveObjectWithData:cellArchive];
//		return cell;
	}
	
	// reset the cell?
	[cell prepareForReuse];
	
	return cell;
}

// when a nib is registered, calls to dequeueReusableCellWithIdentifier: with the registered identifier will instantiate the cell from the nib if it is not already in the reuse queue
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
	if (!self.cellNibLookup) {
		self.cellNibLookup = [NSDictionary dictionaryWithObject:nib forKey:identifier];
	}
	else {
		[self.cellNibLookup setValue:nib forKey:identifier];
	}
}

- (void)registerPrototypeCells
{
	if (self.cellLookup)
		return;
	
	self.cellLookup = [NSMutableDictionary dictionaryWithCapacity: self.cellPrototypes.count];
	for (IATCarouselTableViewCell *cell in self.cellPrototypes) {
		NSData *cellArchive = [NSKeyedArchiver archivedDataWithRootObject:cell];
		[self.cellLookup setObject:cellArchive forKey: [cell valueForKey:@"reuseIdentifier"]];
		[cell removeFromSuperview];
	}
}

- (void)addVelocitySample:(CGFloat)velocitySample
{
	_currentDragVelocity *= previousVelocityWeight;
	_currentDragVelocity += (1 - previousVelocityWeight) * velocitySample;
}

- (void)enableCellAtIndexPath:(NSIndexPath*)activeCellIP
{
	if (activeCellIP.section != 0)
		return;
	
	NSArray *visCellIPs = [self indexPathsForVisibleRows];
	
	for (NSIndexPath *cellIP in visCellIPs)
	{
		IATCarouselTableViewCell *cell = [self.cells objectAtIndex:cellIP.row];
		if (activeCellIP.row == cellIP.row) {
			[cell setEnabled:YES];
		}
		else
			[cell setEnabled:NO];
	}
}

@end
