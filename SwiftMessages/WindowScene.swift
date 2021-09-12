import Foundation
import UIKit

public protocol WindowScene {
    var coordinateSpace: UICoordinateSpace { get }
}

@available(iOS 13.0, *)
extension UIWindowScene: WindowScene { }
