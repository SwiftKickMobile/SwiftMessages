# View Controllers

`SwiftMessagesSegue` is a configurable subclass of `UIStoryboardSegue` that presents and dismisses modal view controllers by acting as the presenting view controller's `transitioningDelegate` and utilizing SwiftMessages' `show()` and `hide()` methods on the destination view controller's view.

## Installation

`SwiftMessagesSegue` is included in the SwiftMessages installation and provides all of the functionality needed for modal view controller presentation. However, to achieve specific layouts and optional behaviors, the segue will generally need to be configured. To help with this, the SwiftMessagesSegueExtras framework provides a number of pre-configured layouts in the form of `SwiftMessagesSegue` sub-classes. These classes roughly mirror the layout options found in `MessageView.Layout`:

<table>
  <tr><td><code>TopMessageSegue</code></td></tr>
  <tr><td><code>BottomMessageSegue</code></td></tr>
  <tr><td><code>TopCardSegue</code></td></tr>
  <tr><td><code>BottomCardSegue</code></td></tr>
  <tr><td><code>TopTabSegue</code></td></tr>
  <tr><td><code>BottomTabSegue</code></td></tr>
  <tr><td><code>CenteredSegue</code></td></tr>
</table>

With SwiftMessagesSegueExtras installed, these options will automatically appear in the Segue Type dialog when creating a segue in Interface Builder. SwiftMessagesSegueExtras is optional and must be explicitly installed to avoid cluttering the dialog by default:

### CocoaPods

Add the following line to your Podfile and do `pod install`:

````ruby
pod 'SwiftMessages/SegueExtras'
````

### Carthage

Add `SwiftMessagesSegueExtras.framework` to your project alongside `SwiftMessages.framework`.

### Manual

1. Install SwiftMessages
1. On your app's target, add `SwiftMessagesSegueExtras.framework`:
   1. as an embedded binary on the General tab.
   1. as a target dependency on the Build Phases tab.

## Usage

### Interface Builder

First, create a segue by control-dragging from the sender element to the destination view controller. Then select "swift messages" (or the name of a `SwiftMessagesSegue` subclass) in the Segue Type prompt. In the image below, we've created a segue using the `VeryNiceSegue` subclass by selecting "very nice" from the prompt.

<p align="center">
  <img src="./Design/SwiftMessagesSegueCreate.png" />
</p>

### Programatic

`SwiftMessagesSegue` can be used without an associated storyboard or segue by doing the following in the presenting view controller.

````swift
let destinationVC = ... // make a reference to a destination view controller
let segue = SwiftMessagesSegue(identifier: nil, source: self, destination: destinationVC)
... // do any configuration here
segue.perform()
````

To dismiss, call the UIKit API on the presenting view controller:

````swift
dismiss(animated: true, completion: nil)
````

It is not necessary to retain `segue` because it retains itself until dismissal. However, you can retain it if you plan to `perform()` more than once.

### Configuration

`SwiftMessagesSegue` generally requires configuration to achieve specific layouts and optional behaviors. There are a few good ways to do this:

  1. __(Recommended)__ Subclass `SwiftMessagesSegue` and apply configurations in `init(identifier:source:destination:)`. Subclasses will automatically appear in the Segue Type dialog using an auto-generated name. For example, the name for "VeryNiceSegue" would be "very nice".
  1. Apply configurations in `prepare(for:sender:)` of the presenting view controller after down-casting the segue to `SwiftMessagesSegue`.
  1. Install the SwiftMessagesSegueExtras framework as outlined in the Installation section and select from the pre-configured subclasses.

The `configure(layout:)` method is a shortcut for configuring some basic layout and animation options that roughly mirror the options in `SwiftMessages.Layout`:

````swift
// Configure a bottom card-style presentation
segue.configure(layout: .bottomCard)
````

The `messageView` property provides access to an instance of `BaseView` (the superclass of `MessageView`), which the view controller's view is installed into. There are some useful options on `BaseView`:

````swift
// Indicate that the view controller's view should be installed
// as the `backgroundView` of `messageView`.
segue.containment = .background

// Increase the internal layout margins. With the `.background` containment option,
// the margin additions specify the outer margins around `messageView.backgroundView`.
segue.messageView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

// Collapse layout margin edges that encroach on non-zero safe area insets.
messageView.collapseLayoutMarginAdditions = true

// Add a default drop shadow.
segue.messageView.configureDropShadow()
````

The view controller's view is embedded in an instance of `ViewControllerContainerView`, which provides corner rounding options:

````swift
// Change the corner radius
segue.containerView.cornerRadius = 20
````

The `SwiftMessages.Config` options relevant for view controller presentation are also available:

````swift
// Turn off interactive dismiss
segue.interactiveHide = false

// Enable dimmed background with tap-to-dismiss
segue.dimMode = .gray(interactive: true)

// Specify the animation and positioning
segue.presentationStyle = .bottom
````

See [`SwiftMessagesSegue`](./SwiftMessages/SwiftMessagesSegue.swift) for additional documentation and technical details.
