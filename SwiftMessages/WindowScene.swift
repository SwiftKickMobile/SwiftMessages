import Foundation
import UIKit

/// A workaround for the change in Xcode 13 that prevents using `@availability` attribute
/// with `enum` cases containing associated values.
public protocol WindowScene {}

@available(iOS 13.0, *)
extension UIWindowScene: WindowScene {}
