# View Controllers

`SwiftMessagesSegue` is a configurable subclass of `UIStoryboardSegue` that utilizes SwiftMessages to present and dismiss modal view controllers. It performs these transitions by becoming your view controller's `transitioningDelegate`, calling SwiftMessage's `show()` and `hide()` under the hood.

## Installation

The `SwiftMessagesSegue` base class is included with the SwiftMessages installation and provides all of the functionality needed for view controller presentation. But to achieve specific layouts and optional behaviors, it generally requires configuration. To help with this, the SwiftMessagesSegueExtras framework provides a number of pre-configured layouts in the form of `SwiftMessagesSegue` sub-classes. These classes roughly mirror the layout options found in `MessageView.Layout`:

<table>
  <tr><td><code>TopMessageSegue</code></td></tr>
  <tr><td><code>BottomMessageSegue</code></td></tr>
  <tr><td><code>TopCardSegue</code></td></tr>
  <tr><td><code>BottomCardSegue</code></td></tr>
  <tr><td><code>TopTabSegue</code></td></tr>
  <tr><td><code>BottomTabSegue</code></td></tr>
  <tr><td><code>CenteredSegue</code></td></tr>
</table>

When SwiftMessagesSegueExtras is installed, these options will automatically appear in the Interface Builder Segue Type dialog. To avoid cluttering the dialog by default, SwiftMessagesSegueExtras must be installed explicitly:

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

Create a segue by control-dragging from the sender to the destination. Then select "swift messages" (or the auto-generated name of a `SwiftMessagesSegue` subclass) in the Segue Type prompt. In the image below, we've created a segue using the `VeryNiceSegue` subclass of `SwiftMessagesSegue` by selecting "very nice".

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

  1. __(Recommended)__ Subclass `SwiftMessagesSegue` and override `init(identifier:source:destination:)` to apply configuration. Subclasses will automatically appear in the segue type dialog using an auto-generated name (for example, the name for "VeryNiceSegue" would be "very nice").
  1. Override `prepare(for:sender:)` in the presenting view controller, down-cast the segue to `SwiftMessagesSegue`, and apply configuration steps to the instance.
  1. Install the SwiftMessagesSegueExtras framework as outlined in the Installation section and select from the pre-configured subclasses.

The `configure(layout:)` method is a shortcut for configuring some basic layout and animation options that roughly mirror the options in `SwiftMessages.Layout`:

````swift
// Configure a bottom card-style presentation
segue.configure(layout: .bottomCard)
````

The `messageView` property provides access to the instance of `BaseView` that the view controller's view is installed into. It provides some configuration options:

````swift
// Install the view controller's view as the `backgroundView` of `messageView`
segue.containment = .background

// Increase the padding to 20pt
segue.messageView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

// Collapse the layout margin edge when the safe area inset is greater than zero.
messageView.collapseLayoutMarginAdditions = true

// Add a default drop shadow.
segue.messageView.configureDropShadow()
````

The view controller's view is wrapped in an instance of `ViewControllerContainerView`, which exposes configurable corner rounding options:

````swift
// Change the corner radius to 20pt
segue.containerView.cornerRadius = 20
````

Some options from `SwiftMessages.Config` are accessible:

````swift
// Turn off interactive dismiss
segue.interactiveHide = false

// Enable dimmed background with tap-to-dismiss
segue.dimMode = .gray(interactive: true)

// Set the animation and adjust the spring damping
segue.presentationStyle = .bottom
````

See [`SwiftMessagesSegue`](./SwiftMessages/SwiftMessagesSegue.swift) for additional documentation and technical details.
