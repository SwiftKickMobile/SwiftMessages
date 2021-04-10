//
//  BoundaryInsets.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 2/13/21.
//  Copyright © 2021 SwiftKick Mobile. All rights reserved.
//

import UIKit

public protocol MessageSizeable {
    var messageSize: MessageSize { get }
    var messageInsets: MessageInsets { get }
}

public enum MessageBoundary {
    case superview
    case safeArea
    case margin
}

/// Insets used for specifying view sizing options in terms of insets from the containing superview or safe area.
public struct MessageInsets {

    public enum Dimension {

        /// Dimension should maintain an absolute margin to the given container boundary.
        case absoluteMargin(CGFloat, from: MessageBoundary)

        /// Dimension should maintain a relative margin to the given container boundary.
        case relativeMargin(CGFloat, from: MessageBoundary)
    }

    public var top: Dimension?
    public var bottom: Dimension?
    public var leading: Dimension?
    public var trailing: Dimension?
}

public struct MessageSize {

    public enum Dimension {

        /// Dimensions should be an absolute length
        case absolute(CGFloat)

        /// Dimension should maintain an absolute length to the given container boundary.
        case absoluteMargin(CGFloat, from: MessageBoundary)

        /// Dimension should maintain a relative margin to the given boundary.
        case relative(CGFloat, from: MessageBoundary)
    }

    public var width: Dimension?
    public var height: Dimension?
}

extension MessageInsets.Dimension {
    var boundary: MessageBoundary {
        switch self {
        case .absoluteMargin(_, let boundary): return boundary
        case .relativeMargin(_, let boundary): return boundary
        }
    }
}
