//
//  IATViewController.m
//  IATCarouselTest
//
//  Created by Kurt Arnlund on 8/28/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import "IATViewController.h"

@interface IATViewController ()

@end

@implementation IATViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

@end
