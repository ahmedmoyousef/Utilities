//
//  Double+Extensions.swift
//  Utilities
//
//  Created by Ahmed Yousef on 24/09/2025.
//

import Foundation

// MARK: - Double Common Utilities

public extension Double {
    // MARK: - Rounding

    /// Returns the value rounded to a specified number of decimal places.
    /// - Parameter places: The number of digits to keep after the decimal point (>= 0).
    /// - Returns: A new `Double` rounded to `places` digits.
    ///
    /// Example:
    /// ```swift
    /// 3.14159.rounded(to: 2) // 3.14
    /// ```
    func rounded(to places: Int) -> Double {
        guard places >= 0 else { return self }
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }

    // MARK: - Percentage

    /// Formats the value as a percentage string.
    /// - Parameters:
    ///   - places: Decimal places to include. Defaults to 0.
    ///   - locale: The locale to use. Defaults to `.current`.
    /// - Returns: A localized percentage string.
    ///
    /// Example:
    /// ```swift
    /// 0.256.toPercentageString(places: 1) // "25.6%"
    /// ```
    func toPercentageString(places: Int = 0, locale: Locale = .current) -> String {
        let formatter = _NumberFormatterCache.percent(locale: locale, fractionDigits: places)
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }

    // MARK: - Currency

    /// Formats the value as a currency string.
    /// - Parameters:
    ///   - code: The ISO 4217 currency code (e.g., "USD", "EUR"). If `nil`, uses the locale's default currency.
    ///   - locale: The locale to use. Defaults to `.current`.
    ///   - fractionDigits: Optional override for minimum/maximum fraction digits.
    /// - Returns: A localized currency string, or a plain string fallback.
    ///
    /// Example:
    /// ```swift
    /// 1234.5.toCurrencyString(code: "USD") // "$1,234.50" (en_US)
    /// ```
    func toCurrencyString(code: String? = nil, locale: Locale = .current, fractionDigits: Int? = nil) -> String {
        let formatter = _NumberFormatterCache.currency(locale: locale, code: code, fractionDigits: fractionDigits)
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }

    // MARK: - Conversion

    /// Converts the value to an `Int` by rounding to the nearest integer.
    /// - Returns: An `Int` produced by `rounded()`.
    ///
    /// Example:
    /// ```swift
    /// 3.6.toInt() // 4
    /// ```
    func toInt() -> Int { Int(self.rounded()) }

    // MARK: - Clamping

    /// Returns the value clamped to the given closed range.
    /// - Parameter range: The inclusive range to clamp into.
    /// - Returns: `lowerBound` if the value is less than `lowerBound`, `upperBound` if greater than `upperBound`, otherwise `self`.
    ///
    /// Example:
    /// ```swift
    /// (1.5).clamped(to: 0.0...1.0) // 1.0
    /// ```
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }

    /// Mutates the value by clamping it to the given closed range.
    /// - Parameter range: The inclusive range to clamp into.
    ///
    /// Example:
    /// ```swift
    /// var x = 1.5
    /// x.clamp(to: 0.0...1.0) // x == 1.0
    /// ```
    mutating func clamp(to range: ClosedRange<Double>) {
        self = clamped(to: range)
    }

    // MARK: - Time Formatting

    /// Converts the value (interpreted as seconds) into an "h:mm:ss" string.
    /// - Returns: A string formatted as hours:minutes:seconds. Hours are not zero-padded; minutes/seconds are zero-padded to 2 digits.
    ///
    /// Example:
    /// ```swift
    /// 3661.0.asHMS // "1:01:01"
    /// 59.0.asHMS   // "0:00:59"
    /// ```
    var asHMS: String {
        let total = max(0, Int(self))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - Private: NumberFormatter Cache

private enum _NumberFormatterCache {
    nonisolated(unsafe) private static let percentCache = NSCache<NSString, NumberFormatter>()
    nonisolated(unsafe) private static let currencyCache = NSCache<NSString, NumberFormatter>()

    static func percent(locale: Locale, fractionDigits: Int) -> NumberFormatter {
        let key = "percent|\(locale.identifier)|\(fractionDigits)" as NSString
        if let cached = percentCache.object(forKey: key) { return cached }
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .percent
        f.minimumFractionDigits = fractionDigits
        f.maximumFractionDigits = fractionDigits
        percentCache.setObject(f, forKey: key)
        return f
    }

    static func currency(locale: Locale, code: String?, fractionDigits: Int?) -> NumberFormatter {
        let codeKey = code ?? "auto"
        let fracKey = fractionDigits.map(String.init) ?? "auto"
        let key = "currency|\(locale.identifier)|\(codeKey)|\(fracKey)" as NSString
        if let cached = currencyCache.object(forKey: key) { return cached }
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .currency
        if let code { f.currencyCode = code }
        if let digits = fractionDigits {
            f.minimumFractionDigits = digits
            f.maximumFractionDigits = digits
        }
        currencyCache.setObject(f, forKey: key)
        return f
    }
}

// MARK: - Usage Examples

/*
Usage examples:

let pi = 3.14159
let r2 = pi.rounded(to: 2)                      // 3.14
let p = 0.256.toPercentageString(places: 1)     // "25.6%"
let usd = 1234.5.toCurrencyString(code: "USD")  // "$1,234.50"
let i = 3.6.toInt()                             // 4
let clamped = (1.5).clamped(to: 0.0...1.0)      // 1.0
let hms = 3661.0.asHMS                          // "1:01:01"
*/
