# View Controllers

`SwiftMessagesSegue` is a configurable subclass of `UIStoryboardSegue` that utilizes SwiftMessages to present and dismiss modal view controllers. It performs these transitions by becoming your view controller's `transitioningDelegate` and calling SwiftMessage's `show()` and `hide()` under the hood.

## Installation

The `SwiftMessagesSegue` class is included when you install SwiftMessages and this provides all of the functionality. However, a number subclasses are contained in the SwiftMessagesSegueExtras framework, providing pre-configured layouts that roughly mirror the options in `MessageView.Layout`:

| `TopMessageSegue`    | Edge-to-edge from the top
| `BottomMessageSegue` | Edge-to-edge from the bottom
| `TopCardSegue`       | Card-style from the top
| `BottomCardSegue`    | Card-style from the bottom
| `TopTabSegue`        | Tab-style from the top
| `BottomTabSegue`     | Tab-style from the bottom
| `CenteredSegue`      | Centered with physics-based dismissal


These classes are not included in the SwiftMessages to avoid cluttering the Interface Builder segue type dialog by default. Therefore, SwiftMessagesSegueExtras must be explicitly added to the project as follows.
 
Add the following line to your Podfile and do `pod install`:

````ruby
pod 'SwiftMessages/SegueExtras'
````

### Carthage

After building SwiftMessages, add the SwiftMessagesSegueExtras framework to your project alongside SwiftMessages.

### Manual

1. Install SwiftMessages
1. On your app's target, add `SwiftMessagesSegueExtras.framework`:
   1. as an embedded binary on the General tab.
   1. as a target dependency on the Build Phases tab.

## Usage

To use `SwiftMessagesSegue` with Interface Builder, control-drag a segue, as you would with any other segue, from the sender to the destination. Then select "swift messages" that Interface Builder has conveniently added to the segue type prompt.

<p align="center">
  <img src="./Design/SwiftMessagesSegueCreate.png" />
</p>

This configures a default transition. There are two ways to further configure the transition by setting configuration options on `SwiftMessagesSegue`.

  * __Option #1__ you may override `prepare(for:sender:)` in the presenting view controller and down-cast the segue to `SwiftMessagesSegue`.
  * __Option #2__ (recommended) you may subclass `SwiftMessagesSegue` and override `init(identifier:source:destination:)`. Subclasses will automatically appear in the segue type dialog using an auto-generated name (for example, the name for "VeryNiceSegue" would be "very nice").
  
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