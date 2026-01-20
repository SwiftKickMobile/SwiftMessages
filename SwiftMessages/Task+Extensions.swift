//
//  Task+Extensions.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 12/3/23.
//  Copyright © 2023 SwiftKick Mobile. All rights reserved.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async throws {
        try await sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
