//
//  IATCarouselViewController.h
//  IATBaseClasses
//
//  Created by Kurt Arnlund on 7/3/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IATCarouselTableView.h"
#import "IATCarouselTableViewCell.h"

@interface IATCarouselTableViewController : UIViewController <IATCarouselViewDelegate, IATCarouselViewDataSource>
@property (weak, nonatomic) IBOutlet IATCarouselTableView *carouselView;


@end
