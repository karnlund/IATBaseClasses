#IATBaseClasses#

##INFORMATION:##

`IATBaseClasses` is a collection of objects that I use in my development of iOS apps.  These are utilities that have been hardened over time to provide great convenience without creating a demand to include a lot of unnecessary code.

The primary feature here will probably be the objects that provide a **3D Carousel View** that is highly based on the iOS UITableView and it's related classes.  These classes and their related iOS components are:

`IATCarouselTableViewCell`   =>	`UITableViewCell`

`IATCarouselTableView`		=>  	`UITableView` 

`IATCarouselTableViewController`	=>	`UITableViewController`

You will find the headers of these classes to be remarkably similar to the `UITableView` classes and the functionality should be mirror quite well.  The table view presents a series of cells, all of which can be interacted with at any time, and the carousel presents a series of cells where only the foremost cell is intended to be interacted with.  Because of this difference, you will find there are a few methods that have been removed from the carousel where they make less sense.

`IATCarouselDataViewController` is an optional view controller that allows you to configure the data that controls the layout of the carousel.

`IATCarouselData` is a required object that simply manages the layout specifications for the carousel.  `IATCarouselTableView` uses this data to generate the cell layout.

One of the key features of these carousel objects is that it's pretty easy to configure the layout of the carousel.  Currently the code uses a V shaped layout, but using a oval, or a circle, or a half circle, or even a bezier path should be quite easy.  I've already switched between these numerous times with little difficulty.  For simplicity the code assumes cell positions as if they were on a circle.  So angles in the range of 0 to 360 are used to position all cells on whatever layout function it used.  Some 3D skills may be needed to calculate effective positions and orientations for each cell, but quite a few tricks with the layout functions (`IATLayoutFunction2d.h`) are available to simplify this.

The carousel makes use of Michael Tyson's (Tasty Pixel) `TPPropertyAnimation`, with additional modifications from myself that add momentum-based animations.  Any time a finger is lifted, the cells reposition to their final resting position using this animation object.


_Some other interesting objects and their purposes_:

`IATPerspectiveView` : This view gives 3D perspective to it's subviews

`IATViewFader` :	An object that controls the opacity of a view

`IATViewSizer` : 		An object that controls the size of a view.  Optionally, this object also is intended to resize another view that is tied to the size of the main view.

`IATViewHider` : 	An object that controls the position of a view using one of it's edges as a hint to direction and offset (mostly hiding the view underneath another view).  Optionally, this object also is intended to resize another view that is tied to an edge of the main view.  As the main view moves, the subordinate view resizes to take up the space.

`CATransformUtilities` :	Printing CATransform3D

`CAVectorUtilties` : 		3D vectors and associated utility functions

`CGRectUtilities` :		Useful CGRect functions


##LICENSING:##

**Copyright (c) 2012 Ingenious Arts and Technologies LLC**

This source code is licensed under The MIT License.  Please see the License.rtf file for licensing information and required attribution.  But to summarize, just include the above copyright statement in your application and we are all good.


[http://www.IngeniousArtsAndTechnologies.com]
