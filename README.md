MaryPopin
=========

MaryPopin is a category on UIViewController to present modal like controller with more flexibility.

*- Wait, what? There are tons of similar projects on the web to do that!*

Well, your are right, but here are some strengths of this project :

* No subclassing is required, you can use it on your existing view controllers like you do with modal controllers,
* No `UIWindow` manipulation, MaryPopin uses `UIViewControllers` containment, so rotation is properly handled,
* Auto-dismiss when touching outside of the popin
* Controller presentation size can be customized
* Larger choice of transition styles and directions
* Subtle paralax effect to fit well with iOS 7 guidelines
* Automatic moves to respond to keyboard events
* Completion blocks on present and dismiss transitions

Yes, you can say it, it is Supercalifragilisticexpialidocious!

*- Okay. But why MaryPopin?*
Popin, popup, modal may look similar, but in reality, there are some slight differences. Here, the controller view is presented inside its parent controller 
that is why we name it a popin controller. And as it is implemented as a category, it is as nice and magic as the famous nanny.

![MaryPopin demo](https://github.com/Backelite/MaryPopin/raw/master/MaryPopin.gif "Sample project animation")

=========

## Changes

v 1.0

* First public release

## Getting started
### The Pod way
Just add the following line in your podfile

	pod 'MaryPopin'

### The old school way
Drag and drop the category files in your project and you are done.

### Using MaryPopin

#### Basic usage

First, import `UIViewController+MaryPopin.h` header.

In your current view controller, you can create a view controller and present it as a popin.

```Objective-C

	//Create the popin view controller
	UIViewController *popin = [[UIViewController alloc] initWithNibName:@"NibName" bundle:@"Bundle"];
	//Customize transition if needed
	    [popin setPopinTransitionStyle:BKTPopinTransitionStyleSlide];
	    
		//Add options
		[popin setPopinOptions:BKTPopinDisableAutoDismiss];
		
		//Customize transition direction if needed
	    [popin setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
		
		//Present popin on the desired controller
		//Note that if you are using a UINavigationController, the navigation bar will be active if you present
		// the popin on the visible controller instead of presenting it on the navigation controller
	    [self presentPopinController:popin animated:YES completion:^{
	        NSLog(@"Popin presented !");
	    }];
```

Respectively, to dismiss the popin from your current view controller

```Objective-C

	[self dismissCurrentPopinControllerAnimated:YES completion:^{
        NSLog(@"Popin dismissed !");
    }];
```
#### Advanced usage
Todo.

### Sample project
The sample project show how to present and dismiss a popin with different transition styles.

## <a name="requirements"></a> Requirements
MaryPopin requires iOS 7.0 and Xcode 5 as it uses UIKit Dynamics and motion effects.

### ARC
MaryPopin uses ARC.  
If you are using MaryPopin in a non-arc project, you will need to set a `-fobjc-arc` compiler flag on every MaryPopin source files.  
To set a compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Then select MaryPopin source files, press Enter, insert -fobjc-arc and then "Done" to enable ARC for MaryPopin.

## Contributing
If you want to contribute to this project, please submit a pull request. 

## Licence
MaryPopin is available under the MIT license. See the LICENSE file for more info.
