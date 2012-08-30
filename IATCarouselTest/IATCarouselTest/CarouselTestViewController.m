//
//  CarouselTestViewController.m
//  IATCarouselTest
//
//  Created by Kurt Arnlund on 8/28/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "CarouselTestViewController.h"

@interface CarouselTestViewController ()

@end

@implementation CarouselTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


// ADDED HERE

- (NSInteger)carouselView:(IATCarouselTableView *)carouselView numberOfRowsInSection:(NSInteger)section
{
	return 500;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's
// reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and
// data source (accessory views, editing controls)

- (IATCarouselTableViewCell *)carouselView:(IATCarouselTableView *)carouselView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// return IB-defined cells that require no configuration
	return [carouselView dequeueReusableCellWithIdentifier:@"myCustomCell"];
}



@end
