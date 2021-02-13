//
//  BoundaryInsets.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 2/13/21.
//  Copyright © 2021 SwiftKick Mobile. All rights reserved.
//

import QuartzCore

public protocol HasBoundaryInsets {
    var boundaryInsets: BoundaryInsets { get }
}

/// Insets used for specifying view sizing options in terms of insets from the containing superview or safe area.
public struct BoundaryInsets {

    public enum Boundary {
        case superview
        case safeArea
        case margin
    }

    /// An abstract dimension used for specifying the message view's size
    public enum Dimension {

        /// Dimensions should be determined automatically
        case automatic

        /// Dimension should maintain an absolute margin to the given boundary.
        case absoluteMargin(CGFloat, with: Boundary)

        /// Dimension should maintain a relative margin to the given boundary.
        case relativeMargin(CGFloat, with: Boundary)
    }

    public var top: Dimension = .automatic
    public var bottom: Dimension = .automatic
    public var leading: Dimension = .automatic
    public var trailing: Dimension = .automatic
}
