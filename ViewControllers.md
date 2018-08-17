# View Controllers

`SwiftMessagesSegue` is a configurable subclass of `UIStoryboardSegue` that utilizes SwiftMessages to present and dismiss modal view controllers. It performs these transitions by becoming your view controller's `transitioningDelegate` and calling SwiftMessage's `show()` and `hide()` under the hood.

## Installation

The SwiftMessages framework includes the `SwiftMessagesSegue` base class, which provides all of the functionality needed for view controller presentation. But it requires configuration. The SwiftMessagesSegueExtras framework contains a number of pre-configured layouts in the form of `SwiftMessagesSegue` sub-classes. These classes roughly mirror the layout options in `MessageView.Layout`:

<table>
  <tr><td><code>TopMessageSegue</code></td></tr>
  <tr><td><code>BottomMessageSegue</code></td></tr>
  <tr><td><code>TopCardSegue</code></td></tr>
  <tr><td><code>BottomCardSegue</code></td></tr>
  <tr><td><code>TopTabSegue</code></td></tr>
  <tr><td><code>BottomTabSegue</code></td></tr>
  <tr><td><code>CenteredSegue</code></td></tr>
</table>

SwiftMessagesSegueExtras is not installed by default in order to avoid cluttering the Interface Builder Segue Type dialog with these options. To install SwiftMessagesSegueExtras:

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

To use `SwiftMessagesSegue`, control-drag a segue in Interface Builder from the sender to the destination. Then select "swift messages" in the Segue Type prompt.

<p align="center">
  <img src="./Design/SwiftMessagesSegueCreate.png" />
</p>

This configures the default transition. There a few good ways to configure the transition to suit your needs by setting options on `SwiftMessagesSegue`:

  * __Option #1__ (recommended) you may subclass `SwiftMessagesSegue` and override `init(identifier:source:destination:)`. Subclasses will automatically appear in the segue type dialog using an auto-generated name (for example, the name for "VeryNiceSegue" would be "very nice").
  * __Option #2__ Override `prepare(for:sender:)` in the presenting view controller and down-cast the segue to `SwiftMessagesSegue`.
  * __Option #3__ Install the SwiftMessagesSegueExtras framework as outlined in the Installation section and select from the pre-configured subclasses.
  
There are quite a few configuration options, may of which are borrowed from `SwiftMessages.Config`:

````swift
// Configure a bottom card-style presentation
segue.configure(layout: .bottomCard)

// Add a default drop shadow
segue.messageView.configureDropShadow()

// Turn off interactive dismiss
segue.interactiveHide = false

// Enable dimmed background with tap-to-dismiss
segue.dimMode = .gray(interactive: true)
````

The `SwiftMessagesSegue.configure(layout:)` method is a convenience function that combines several settings, which you can modify directly:

````swift
// Install the view controller's view as the `backgroundView` of `messageView`
containment = .background

// Set the layout margin additions to inset the view controller's
// view by 10pt for a card-style look.
messageView.layoutMarginAdditions = UIEdgeInsetsMake(10, 10, 10, 10)


// Collapse the layout margin edge when the safe area inset is greater than zero.
messageView.collapseLayoutMarginAdditions = true

// Set the corner radius for the view controller's view's container view.
containerView.cornerRadius = 15

// Set the animation and adjust the spring damping
presentationStyle = .bottom

````

See [`SwiftMessagesSegue`](./SwiftMessages/SwiftMessagesSegue.swift) for additional documentation and technical details.
