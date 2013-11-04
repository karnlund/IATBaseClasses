#IATBaseClasses#

##INFORMATION:##

`IATBaseClasses` is a collection of objects that I use in my development of iOS apps.  These are utilities that have been developed over the past few years to provide convenience without creating a demand to include a lot of unnecessary code.  I've also been quite keen on not doing anything that I consider to be too perverse or evil.  That means no method swizzling, or dynamic property additions to other objects.  Those things may have a place, but they have no place anywhere here.

The primary objects of interest here will probably the ones the provide a **3D Carousel View**, and the utility methods that facilitate that view. The carousel is based on UITableView and it's related classes and protocols.

##Here is how my carousel classes relate to the classes in UIKit:

    IATCarouselTableViewCell        =>  UITableViewCell
    IATCarouselTableView            =>  UITableView
    IATCarouselTableViewController  =>  UITableViewController

A UITableView presents a series of cells, all of which can be interacted with at any time, and the carousel presents a series of cells where only the foremost cell is intended to be interacted with. Because of this difference, you will find there are a few methods that have been removed from the carousel where they make less sense.

##Other Classes
**`IATCarouselDataViewController`** is an optional view controller that allows you to configure the way the carousel looks.  You can present this view controller however you like.  I usually trigger it with a UIGestureRecognizer.

**`IATCarouselData`** is a required object that simply manages the layout specifications for the carousel.  

Then **`IATCarouselTableView`** uses this data to generate the cell layout.

One of the key features of these carousel objects is that it's pretty easy to configure the layout of the carousel. Currently the code uses a V shaped layout, but using a oval, or a circle, or a half circle, or even a bezier path should be quite easy. I've already switched between these numerous times with little difficulty. For simplicity the code assumes cell positions as if they were on a circle. So angles in the range of 0 to 360 are used to position all cells on whatever layout function it used. **Note:** Some 3D skills may be needed to calculate effective positions and orientations for each cell, but quite a few tricks with the layout functions (`IATLayoutFunction2d.h`) are available to simplify this.

##Dependencies
The carousel makes use of [Michael Tyson's (Tasty Pixel)](http://atastypixel.com/blog/ "Tasty Pixel") `TPPropertyAnimation`, with additional modifications from myself that add momentum-based animations. Any time a finger is lifted, the cells reposition to their final resting position using this animation object.

##Some other interesting objects and their purposes##

**`IATPerspectiveView`** 
*  This view gives 3D perspective to it's subviews

**`IATViewFader`**
*  An object that controls the opacity of a view

**`IATViewSizer`** : 		An object that controls the size of a view.  Optionally, this object also is intended to resize another view that is tied to the size of the main view.

**`IATViewHider`** : 	An object that controls the position of a view using one of it's edges as a hint to direction and offset (mostly hiding the view underneath another view).  Optionally, this object also is intended to resize another view that is tied to an edge of the main view.  As the main view moves, the subordinate view resizes to take up the space.

**`CATransformUtilities`** :	Printing CATransform3D

**`CAVectorUtilties`** : 		3D vectors and associated utility functions

**`CGRectUtilities`** :		Useful CGRect functions


##LICENSING:##

**Copyright (c) 2012 Ingenious Arts and Technologies LLC**

This source code is licensed under The MIT License.  I want you to be able to use this free of charge, with no obligation to me, other than a small attribution somewhere in your app or settings.  Please see the License.rtf file for licensing information and required attribution.  But to summarize, just include the above copyright statement in your application and we are all good.

Kurt Arnlund
[Ingenious Arts and Technologies LLC](http://www.iatapps.com>)
