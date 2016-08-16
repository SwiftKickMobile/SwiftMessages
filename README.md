# SwiftMessages

SwiftMessages is a library for displaying temporary status messages on iOS.

In addition to providing numerous layouts, themes and configuration options, SwiftMessages allows complete control over the design of your message:

* Copy one of the included nib files into your project and modify it.
* Subclass `MessageView` to add elements, etc.
* Or just supply an arbitrary view.

Try exploring [the demo app](./Demo/Demo.xcworkspace) to get a feel for the extensive configurability of SwiftMessages.

## Installation

### CocoaPods

Add the following line to your Podfile:

````
pod 'SwiftMessages'
````

### Carthage

Todo

## Usage

````swift
// A type-safe factory method for one of the
// provided nib-based layouts. The main bundle is always
// searched first, so you can easily copy the nib file
// into your project and modify it.
let view = MessageView.viewFromNib(layout: .MessageView)

// One of several convenience methods for theming 
// message elements.
view.configureWarningTheme()


view.configureContent(title: "Warning", body: "Consider yourself warned.", iconText: "🤔")
SwiftMessages.show(view: view)
````

````swift
SwiftMessages.show {
    let view = MessageView.viewFromNib(layout: .MessageView)
    ...
    return view
}
````

````swift
var config = SwiftMessages.Config()

config.presentationStyle = .Bottom // Slide up from the bottom
config.presentationContext = .Window(windowLevel: UIWindowLevelNormal) // Display over key window
config.duration = .Forever // Disable auto-hiding
config.dimMode = .Automatic(interactive: true) // Dim the background (like a popover view)
config.interactiveHide = false // Disable the interactive hide gesture
config.preferredStatusBarStyle = .LightContent // Specify a matching status bar style

SwiftMessages.show(config: config) { ... }
````

## License