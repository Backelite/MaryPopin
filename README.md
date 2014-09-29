MaryPopin
=========
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/Backelite/MaryPopin/blob/master/LICENSE)
[![Release](http://img.shields.io/github/release/Backelite/MaryPopin.svg)](https://github.com/Backelite/MaryPopin)
[![CocoaPods](http://img.shields.io/cocoapods/v/MaryPopin.svg)](https://github.com/Backelite/MaryPopin)

MaryPopin is a category on `UIViewController` to present modal like controller with more flexibility.

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
* iOS5/6/7 support

Yes, you can say it, it is Supercalifragilisticexpialidocious!

*- Okay. But why MaryPopin?*
Popin, popup, modal may look similar, but in reality, there are some slight differences. Here, the controller view is presented inside its parent controller 
that is why we name it a popin controller. And as it is implemented as a category, it is as nice and magic as the famous nanny.

![MaryPopin demo](https://github.com/Backelite/MaryPopin/raw/master/MaryPopin.gif "Sample project animation")

=========

## Changes

v1.4.2
* Fixed an issue when dismissing chained popins

v1.4.1
* Warning and minor bug fixing (thanks to @Mazyod)

v1.4
* Added an option to configure blur background
* Fixed a crash with iOS 5.x
* Fixed an unused variable warning

v 1.3.1
* Fixed an issue with default alignment option

v 1.3
* Added on option to have a blurry background view
* Added an option to change popin alignment in parent (thanks to @leverdeterre)
* Added a custom block to define custom in and out animations (thanks to @jonasman)
* Fixed an issue with appearance event forwarding

v 1.2

* Added an option to remove coupling between background view and auto-dismiss option
* Fixed an issue causing background view to disappear when chaining multiple popins

v 1.1.1

* Code refactoring

v 1.1

* Support for iOS 5 & 6

v 1.0

* First public release

## Getting started
### The Pod way
Just add the following line in your podfile

	pod 'MaryPopin'

### The old school way
Drag and drop the category files in your project and you are done.

### Using MaryPopin
The full documentation is available [on CocoaDocs](http://cocoadocs.org/docsets/MaryPopin/).

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
By default, popin is centered in the parent controller view. But you can provide a `CGRect` in which the popin should be centered. Note that the `CGRect` must be included in the parent controller view bounds, otherwise it may lead to unexpected behaviors.

```Objective-C

	BKTPopinControllerViewController *popin = [[BKTPopinControllerViewController alloc] init];
    [popin setPopinTransitionStyle:BKTPopinTransitionStyleCrossDissolve];
    [popin setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    
    CGRect presentationRect = CGRectOffset(CGRectInset(self.view.bounds, 0.0, 100.0), 0.0, 200.0);
    [self.navigationController presentPopinController:popin fromRect:presentationRect animated:YES completion:^{
        NSLog(@"Popin presented !");
    }];
```

### Sample project
The sample project show how to present and dismiss a popin with different transition styles. 

If you are using CocoaPods in version 0.29 or better, you can quickly run the demo project with the following command line :

	pod try MaryPopin

## Requirements
MaryPopin requires Xcode 5 as it uses (optionally) UIKit Dynamics and motion effects. You can use iOS 5 as a target deployment version. Note that some transition styles are not supported under iOS 7 and will be replaced by the default transition style.

### ARC
MaryPopin uses ARC.  
If you are using MaryPopin in a non-arc project, you will need to set a `-fobjc-arc` compiler flag on every MaryPopin source files.  
To set a compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Then select MaryPopin source files, press Enter, insert -fobjc-arc and then "Done" to enable ARC for MaryPopin.

## Contributing
Contributions for bug fixing or improvements are welcomed. Feel free to submit a pull request.

## Licence
MaryPopin is available under the MIT license. See the LICENSE file for more info.

[![Analytics](https://ga-beacon.appspot.com/UA-44164731-1/mary-popin/readme?pixel)](https://github.com/igrigorik/ga-beacon)
