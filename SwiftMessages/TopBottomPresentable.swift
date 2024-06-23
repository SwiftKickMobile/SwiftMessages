//
//  File.swift
//  
//
//  Created by Julien Di Marco on 23/04/2024.
//

import Foundation

// MARK: - TopBottom Presentable Definition

@MainActor
protocol TopBottomPresentable {
    var topBottomStyle: TopBottomAnimationStyle? { get }
}

// MARK: - TopBottom Presentable Conformances

extension TopBottomAnimation: TopBottomPresentable {
    var topBottomStyle: TopBottomAnimationStyle? { return style }
}

extension PhysicsAnimation: TopBottomPresentable {
    var topBottomStyle: TopBottomAnimationStyle? {
        switch placement {
        case .top: return .top
        case .bottom: return .bottom
        default: return nil
        }
    }
}

// MARK: - Presentation Style Convenience

extension SwiftMessages.PresentationStyle {
    /// A temporary workaround to allow custom presentation contexts using `TopBottomAnimation`
    /// to display properly behind bars. THe long term solution is to refactor all of the
    /// presentation context logic to work with safe area insets.
    @MainActor
    var topBottomStyle: TopBottomAnimationStyle? {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .custom(let animator as TopBottomPresentable): return animator.topBottomStyle
        case .center: return nil
        default: return nil
        }
    }
}
