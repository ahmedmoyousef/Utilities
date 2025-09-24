//
//  Int+Extensions.swift
//  Utilities
//
//  Created by Ahmed Yousef on 24/09/2025.
//

import Foundation

// MARK: - Int Common Utilities

public extension Int {
    // MARK: - Formatting

    /// Formats the integer using the locale's grouping separator (commas in many locales).
    /// - Parameter locale: The locale to use. Defaults to `.current`.
    /// - Returns: A localized string with grouping separators.
    ///
    /// Example:
    /// ```swift
    /// 1_000_000.formattedWithCommas() // "1,000,000" (en_US)
    /// ```
    func formattedWithCommas(locale: Locale = .current) -> String {
        let formatter = _NumberFormatterCache.decimal(locale: locale)
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }

    /// Converts the integer (interpreted as seconds) to a "m:ss" string.
    /// - Returns: A string in minutes:seconds format. Seconds are zero-padded to 2 digits.
    ///
    /// Example:
    /// ```swift
    /// 125.asMinutesSeconds // "2:05"
    /// 59.asMinutesSeconds  // "0:59"
    /// ```
    var asMinutesSeconds: String {
        let total = Swift.max(0, self)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Random

    /// Generates a random integer within the given closed range.
    /// - Parameter range: The inclusive range to sample from.
    /// - Returns: A random integer in `range`.
    ///
    /// Example:
    /// ```swift
    /// let r = Int.randomIn(1...10)
    /// ```
    static func randomIn(_ range: ClosedRange<Int>) -> Int { Int.random(in: range) }

    // MARK: - Conversion

    /// Converts the integer to a string.
    /// - Returns: `String(self)`.
    ///
    /// Example:
    /// ```swift
    /// 42.toString() // "42"
    /// ```
    func toString() -> String { String(self) }

    // MARK: - Parity

    /// Indicates whether the integer is even.
    ///
    /// Example:
    /// ```swift
    /// 4.isEven // true
    /// 3.isEven // false
    /// ```
    var isEven: Bool { self % 2 == 0 }

    /// Indicates whether the integer is odd.
    ///
    /// Example:
    /// ```swift
    /// 3.isOdd // true
    /// 4.isOdd // false
    /// ```
    var isOdd: Bool { !isEven }

    // MARK: - Clamping

    /// Returns the value clamped to the given closed range.
    /// - Parameter range: The inclusive range to clamp into.
    /// - Returns: `lowerBound` if the value is less than `lowerBound`, `upperBound` if greater than `upperBound`, otherwise `self`.
    ///
    /// Example:
    /// ```swift
    /// 15.clamped(to: 0...10) // 10
    /// (-2).clamped(to: 0...10) // 0
    /// ```
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }

    /// Mutates the value by clamping it to the given closed range.
    /// - Parameter range: The inclusive range to clamp into.
    ///
    /// Example:
    /// ```swift
    /// var x = 15
    /// x.clamp(to: 0...10) // x == 10
    /// ```
    mutating func clamp(to range: ClosedRange<Int>) {
        self = clamped(to: range)
    }
}

// MARK: - Private: NumberFormatter Cache

private enum _NumberFormatterCache {
    nonisolated(unsafe) private static let decimalCache = NSCache<NSString, NumberFormatter>()

    static func decimal(locale: Locale) -> NumberFormatter {
        let key = "decimal|\(locale.identifier)" as NSString
        if let cached = decimalCache.object(forKey: key) { return cached }
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        decimalCache.setObject(f, forKey: key)
        return f
    }
}

// MARK: - Usage Examples

/*
Usage examples:

let seconds = 125
let mmss = seconds.asMinutesSeconds                // "2:05"
let grouped = 1_000_000.formattedWithCommas()      // "1,000,000" (en_US)
let r = Int.randomIn(1...6)                         // e.g., 4
let s = 42.toString()                               // "42"
let even = 4.isEven                                 // true
let odd = 5.isOdd                                   // true
let clamped = 15.clamped(to: 0...10)                // 10
*/
