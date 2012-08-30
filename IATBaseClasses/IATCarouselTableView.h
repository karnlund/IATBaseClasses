//
//  IATCarouselView.h
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/3/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IATPerspectiveView;
@class IATCarouselTableViewCell;

@protocol IATCarouselViewDataSource;
@protocol IATCarouselViewDelegate;

@interface IATCarouselTableView : UIView

@property (readwrite, nonatomic, weak)	IBOutlet id <IATCarouselViewDataSource> dataSource;
@property (readwrite, nonatomic, weak)	IBOutlet id <IATCarouselViewDelegate>   delegate;
@property (readwrite, nonatomic, strong) IBOutletCollection(id) NSArray	*cellPrototypes;
@property(nonatomic,getter=isScrollEnabled) BOOL	scrollEnabled;

- (void)reloadData;

//- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point;                         // returns nil if point is outside carousel
- (NSIndexPath *)indexPathForCell:(IATCarouselTableViewCell *)cell;                      // returns nil if cell is not visible
//- (NSArray *)indexPathsForRowsInRect:(CGRect)rect;                              // returns nil if rect not valid 

- (IATCarouselTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;            // returns nil if cell is not visible or index path is out of range
- (NSArray *)visibleCells;
- (NSArray *)indexPathsForVisibleRows;

//- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
//- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (NSIndexPath *)indexPathForSelectedRow;                                                // returns nil or index path representing section and row of selection.

//- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
//- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;  // Used by the delegate to acquire an already allocated cell, in lieu of allocating a new one.

// when a nib is registered, calls to dequeueReusableCellWithIdentifier: with the registered identifier will instantiate the cell from the nib if it is not already in the reuse queue
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;

@end


#pragma mark - Delegate Protocol

@protocol IATCarouselViewDelegate <NSObject, UIScrollViewDelegate>

@optional

// Display customization

- (void)carouselView:(IATCarouselTableView *)carouselView willDisplayCell:(IATCarouselTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)carouselViewWillSroll:(IATCarouselTableView *)carouselView;
- (void)carouselWillStopSroll:(IATCarouselTableView *)carouselView onCellAtIndexPath:(NSIndexPath*)ip;
- (void)carouselDidStopSroll:(IATCarouselTableView *)carouselView onCellAtIndexPath:(NSIndexPath*)ip;
- (void)carousel:(IATCarouselTableView *)carouselView cellAtIndexPathBecomedFrontmost:(NSIndexPath*)ip;

// Variable height support

- (CGSize)carouselView:(IATCarouselTableView *)carouselView sizeForRowAtIndexPath:(NSIndexPath *)indexPath;

// Selection

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)carouselView:(IATCarouselTableView *)carouselView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)carouselView:(IATCarouselTableView *)carouselView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
// Called after the user changes the selection.
- (void)carouselView:(IATCarouselTableView *)carouselView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)carouselView:(IATCarouselTableView *)carouselView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

@end


#pragma mark - Data Source Protocol

@protocol IATCarouselViewDataSource <NSObject>

@required

- (NSInteger)carouselView:(IATCarouselTableView *)carouselView numberOfRowsInSection:(NSInteger)section;

// Row display. Implementers should *always* try to reuse cells by setting each cell's 
// reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and 
// data source (accessory views, editing controls)

- (IATCarouselTableViewCell *)carouselView:(IATCarouselTableView *)carouselView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end



