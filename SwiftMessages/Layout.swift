//
//  BoundaryInsets.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 2/13/21.
//  Copyright © 2021 SwiftKick Mobile. All rights reserved.
//

import UIKit

public protocol LayoutDefining {
    var layout: Layout { get }
}

public protocol LayoutInstalling {
    func install(layoutDefiningView: LayoutDefining & UIView)
}

public struct Layout {

    public var size = Size()
    public var insets = Insets()
    public var center = Center()
    public var min = Layout()
    public var max = Layout()

    public enum Boundary {
        case superview
        case safeArea
        case margin
    }

    public struct Size {

        public enum Dimension {
            case absolute(CGFloat)
            case relative(CGFloat, to: Boundary)
        }

        public var width: Dimension?
        public var height: Dimension?
    }

    public struct Insets {

        public enum Dimension {
            case absolute(CGFloat, from: Boundary)
            case relative(CGFloat, from: Boundary)
        }

        public var top: Dimension?
        public var bottom: Dimension?
        public var leading: Dimension?
        public var trailing: Dimension?
    }

    public struct Center {

        public enum Dimension {
            case absolute(CGFloat, in: Boundary)
            case relative(CGFloat, in: Boundary)
        }

        public var x: Dimension?
        public var y: Dimension?
    }

    public struct Layout {
        public var size = Size()
        public var insets = Insets()
        public var center = Center()
    }
}

extension Layout.Insets.Dimension {
    var boundary: Layout.Boundary {
        switch self {
        case .absolute(_, let boundary): return boundary
        case .relative(_, let boundary): return boundary
        }
    }
}

extension Layout.Center.Dimension {
    var boundary: Layout.Boundary {
        switch self {
        case .absolute(_, let boundary): return boundary
        case .relative(_, let boundary): return boundary
        }
    }
}
