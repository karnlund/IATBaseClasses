//
//  IATCarouselViewController.m
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/3/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATCarouselTableViewController.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_CELL_SIZE		CGSizeMake(480.0f, 320.0f)


@interface IATCarouselTableViewController ()

@end



@implementation IATCarouselTableViewController
@synthesize carouselView;

- (void)viewDidLoad
{
	self.carouselView.delegate = self;
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.carouselView = nil;
    [super viewDidUnload];
}


#pragma mark - Carousel Delegate Protocol

// Display customization

- (void)carouselView:(IATCarouselTableView *)carousel willDisplayCell:(IATCarouselTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//	NSLog(@"carousel %p displaying cell %p %@, %@", carousel, cell, indexPath, NSStringFromCGRect(cell.frame));
}

// Variable height support

//- (CGSize)carouselView:(IATCarouselView *)carousel sizeForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return DEFAULT_CELL_SIZE;
//}

// Selection

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)carouselView:(IATCarouselTableView *)carousel willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (NSIndexPath *)carouselView:(IATCarouselTableView *)carousel willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

// Called after the user changes the selection.

- (void)carouselView:(IATCarouselTableView *)carousel didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (void)carouselView:(IATCarouselTableView *)carousel didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark - Data Source Protocol

- (NSInteger)carouselView:(IATCarouselTableView *)carousel numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's 
// reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and 
// data source (accessory views, editing controls)

- (IATCarouselTableViewCell *)carouselView:(IATCarouselTableView *)carousel cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}


@end
