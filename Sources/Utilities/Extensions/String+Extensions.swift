//
//  String+Extensions.swift
//  Utilities
//
//  Created by Ahmed Yousef on 24/09/2025.
//

import Foundation

// MARK: - String Common Utilities

public extension String {
    // MARK: Trimming & Whitespace

    /// A new string made by removing leading and trailing whitespace and newlines.
    ///
    /// Example:
    /// ```swift
    /// "  Hello\n".trimmed // "Hello"
    /// ```
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Mutates the string by removing leading and trailing whitespace and newlines.
    ///
    /// Example:
    /// ```swift
    /// var name = "  Jane Doe  "
    /// name.trim() // name == "Jane Doe"
    /// ```
    mutating func trim() {
        self = self.trimmed
    }

    /// Indicates whether the string is empty or contains only whitespace/newlines.
    ///
    /// Example:
    /// ```swift
    /// "   \n".isBlank // true
    /// "text".isBlank  // false
    /// ```
    var isBlank: Bool { trimmed.isEmpty }

    /// Returns a new string made by removing the characters in a given character set.
    /// - Parameter characterSet: The set of characters to remove.
    /// - Returns: A new string with all characters from the set removed.
    ///
    /// Example:
    /// ```swift
    /// "a-b_c".removingCharacters(in: CharacterSet(charactersIn: "-_")) // "abc"
    /// ```
    func removingCharacters(in characterSet: CharacterSet) -> String {
        let scalars = unicodeScalars.filter { !characterSet.contains($0) }
        return String(String.UnicodeScalarView(scalars))
    }

    // MARK: - Validation

    /// Performs a lightweight email format validation suitable for client-side checks.
    ///
    /// - Note: This does not guarantee the address is deliverable, only that it appears well-formed.
    ///
    /// Example:
    /// ```swift
    /// "user@example.com".isValidEmail // true
    /// "invalid@".isValidEmail         // false
    /// ```
    var isValidEmail: Bool {
        // RFC 5322-inspired, pragmatic pattern commonly used in apps.
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return range(of: pattern, options: [.regularExpression]) != nil
    }

    /// Indicates whether the string is a valid URL using `URLComponents` and optional scheme restrictions.
    /// - Parameter schemes: Allowed URL schemes. Defaults to `{"http", "https"}`. Pass an empty set to allow any scheme.
    /// - Returns: `true` if the string forms a valid URL with a host (for web URLs), otherwise `false`.
    ///
    /// Example:
    /// ```swift
    /// "https://apple.com".isValidURL()                   // true
    /// "ftp://example.com".isValidURL(schemes: ["ftp"])   // true
    /// "apple.com".isValidURL()                            // false (no scheme)
    /// ```
    func isValidURL(schemes: Set<String> = ["http", "https"]) -> Bool {
        let candidate = trimmed
        guard let components = URLComponents(string: candidate) else { return false }
        if !schemes.isEmpty {
            guard let scheme = components.scheme, schemes.contains(scheme.lowercased()) else { return false }
        }
        // For web-style URLs, require a host. For custom schemes, host may be nil.
        if schemes.isEmpty || schemes.intersection(["http", "https"]).isEmpty == false {
            if let scheme = components.scheme?.lowercased(), scheme == "http" || scheme == "https" {
                return components.host != nil
            }
        }
        return true
    }

    // MARK: - Case & Capitalization

    /// Returns a new string with only the first character uppercased.
    /// - Note: Respects extended grapheme clusters.
    ///
    /// Example:
    /// ```swift
    /// "hello".withCapitalizedFirstLetter // "Hello"
    /// ```
    var withCapitalizedFirstLetter: String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst()
    }

    /// Mutates the string by capitalizing only the first character.
    ///
    /// Example:
    /// ```swift
    /// var title = "swift"
    /// title.capitalizeFirstLetter() // title == "Swift"
    /// ```
    mutating func capitalizeFirstLetter() {
        self = withCapitalizedFirstLetter
    }

    // MARK: - Conversions

    /// Attempts to parse the string as an `Int`.
    /// - Parameter locale: The locale to use when parsing. Defaults to `.current`.
    /// - Returns: An `Int` if parsing succeeds; otherwise `nil`.
    ///
    /// Example:
    /// ```swift
    /// "42".toInt()   // 42
    /// "4.2".toInt()  // nil
    /// ```
    func toInt(locale: Locale = .current) -> Int? {
        // Use NumberFormatter to respect locale, then fall back to direct parse.
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        if let n = formatter.number(from: trimmed) { return n.intValue }
        return Int(trimmed)
    }

    /// Attempts to parse the string as a `Double`.
    /// - Parameter locale: The locale to use when parsing. Defaults to `.current`.
    /// - Returns: A `Double` if parsing succeeds; otherwise `nil`.
    ///
    /// Example:
    /// ```swift
    /// "3.14".toDouble() // 3.14
    /// "abc".toDouble()  // nil
    /// ```
    func toDouble(locale: Locale = .current) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        if let n = formatter.number(from: trimmed) { return n.doubleValue }
        return Double(trimmed)
    }

    /// Attempts to interpret common textual booleans.
    /// - Returns: `true` for "true", "1", "yes", "y"; `false` for "false", "0", "no", "n" (case-insensitive). Otherwise `nil`.
    ///
    /// Example:
    /// ```swift
    /// "YES".toBool()   // true
    /// "0".toBool()     // false
    /// "maybe".toBool() // nil
    /// ```
    func toBool() -> Bool? {
        switch trimmed.lowercased() {
        case "true", "1", "yes", "y": return true
        case "false", "0", "no", "n": return false
        default: return nil
        }
    }

    // MARK: - Localization

    /// Returns the localized version of the string using `NSLocalizedString`.
    /// - Parameter comment: A developer-facing comment to provide context for translators.
    /// - Returns: The localized string.
    ///
    /// Example:
    /// ```swift
    /// let title = "home_title".localized()
    /// ```
    func localized(comment: String = "") -> String {
        NSLocalizedString(self, comment: comment)
    }

    // MARK: - Safe Substrings (Indexing by Int)

    /// Returns a substring starting at the given character offset (safely clamped to bounds).
    /// - Parameter index: The starting character offset. Values out of range are clamped.
    /// - Returns: The substring from the clamped start to the end of the string.
    ///
    /// Example:
    /// ```swift
    /// "abcdef".substring(from: 2) // "cdef"
    /// ```
    func substring(from index: Int) -> String {
        let start = safeIndex(at: index)
        return String(self[start...])
    }

    /// Returns a substring ending just before the given character offset (safely clamped).
    /// - Parameter index: The ending character offset (non-inclusive). Values out of range are clamped.
    /// - Returns: The substring from the beginning to the clamped end.
    ///
    /// Example:
    /// ```swift
    /// "abcdef".substring(to: 3) // "abc"
    /// ```
    func substring(to index: Int) -> String {
        let end = safeIndex(at: index)
        return String(self[..<end])
    }

    /// Returns a substring for the given character range (safely clamped to bounds).
    /// - Parameter range: A `Range<Int>` of character offsets.
    /// - Returns: The substring for the clamped range.
    ///
    /// Example:
    /// ```swift
    /// "abcdef".substring(with: 1..<4) // "bcd"
    /// ```
    func substring(with range: Range<Int>) -> String {
        let lower = safeIndex(at: range.lowerBound)
        let upper = safeIndex(at: range.upperBound)
        guard lower <= upper else { return "" }
        return String(self[lower..<upper])
    }

    /// Returns a substring for the given character range using subscript sugar.
    /// - Parameter range: A `Range<Int>` of character offsets.
    /// - Returns: The substring for the clamped range.
    ///
    /// Example:
    /// ```swift
    /// let s = "abcdef"
    /// let mid = s[1..<4] // "bcd"
    /// ```
    subscript(_ range: Range<Int>) -> String { substring(with: range) }

    // MARK: - Removing Special Characters

    /// Returns a new string containing only alphanumeric characters.
    /// - Parameter keepSpaces: When `true`, spaces are preserved; otherwise removed. Defaults to `false`.
    /// - Returns: A string with non-alphanumeric characters removed (optionally keeping spaces).
    ///
    /// Example:
    /// ```swift
    /// "Hello, World!".removingNonAlphanumerics()            // "HelloWorld"
    /// "Hello, World!".removingNonAlphanumerics(keepSpaces: true) // "Hello World"
    /// ```
    func removingNonAlphanumerics(keepSpaces: Bool = false) -> String {
        unicodeScalars
            .filter { CharacterSet.alphanumerics.contains($0) || (keepSpaces && CharacterSet.whitespaces.contains($0)) }
            .map(Character.init)
            .reduce(into: "", { $0.append($1) })
    }

    // MARK: - Regex Helpers (NSRegularExpression)

    /// Indicates whether the string matches the given regular expression pattern at least once.
    /// - Parameters:
    ///   - pattern: The regular expression pattern.
    ///   - options: Options for the regex compilation. Defaults to `[]`.
    /// - Returns: `true` if a match is found; otherwise `false`.
    ///
    /// Example:
    /// ```swift
    /// "abc123".matches(regex: "[a-z]+\\d+") // true
    /// ```
    func matches(regex pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return false }
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }

    /// Returns the first substring that matches the given regular expression pattern.
    /// - Parameters:
    ///   - pattern: The regular expression pattern.
    ///   - options: Options for the regex compilation. Defaults to `[]`.
    /// - Returns: The first matching substring, or `nil` if none.
    ///
    /// Example:
    /// ```swift
    /// "Order #12345".firstMatch(regex: "#\\d+") // "#12345"
    /// ```
    func firstMatch(regex pattern: String, options: NSRegularExpression.Options = []) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        let range = NSRange(location: 0, length: utf16.count)
        guard let match = regex.firstMatch(in: self, options: [], range: range), let r = Range(match.range, in: self) else { return nil }
        return String(self[r])
    }

    /// Returns a new string made by replacing regex matches with the given template.
    /// - Parameters:
    ///   - pattern: The regular expression pattern.
    ///   - template: The replacement template (supports capture groups like `$1`).
    ///   - options: Options for the regex compilation. Defaults to `[]`.
    /// - Returns: The new string with replacements applied.
    ///
    /// Example:
    /// ```swift
    /// "abc123".replacing(regex: "\\d+", with: "#") // "abc#"
    /// ```
    func replacing(regex pattern: String, with template: String, options: NSRegularExpression.Options = []) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return self }
        let range = NSRange(location: 0, length: utf16.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
    }

    // MARK: - Base64

    /// Returns the Base64-encoded representation of the string (UTF-8).
    /// - Returns: A Base64 string, or `nil` if encoding fails.
    ///
    /// Example:
    /// ```swift
    /// "Hello".base64Encoded // "SGVsbG8="
    /// ```
    var base64Encoded: String? {
        data(using: .utf8)?.base64EncodedString()
    }

    /// Decodes a Base64 string into a UTF-8 string.
    /// - Returns: The decoded string, or `nil` if decoding fails.
    ///
    /// Example:
    /// ```swift
    /// "SGVsbG8=".base64Decoded // "Hello"
    /// ```
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Slug / Identifier

    /// Produces a URL-friendly, lowercase slug.
    ///
    /// Steps:
    /// 1. Trim and lowercase.
    /// 2. Remove diacritics (accents).
    /// 3. Replace non-alphanumeric characters with `-`.
    /// 4. Collapse multiple `-` and trim leading/trailing `-`.
    ///
    /// Example:
    /// ```swift
    /// "Hello, World!".slugified // "hello-world"
    /// ```
    var slugified: String {
        let base = self.trimmed.lowercased().folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let replaced = base.unicodeScalars.map { CharacterSet.alphanumerics.contains($0) ? Character($0) : "-" }
        var slug = String(replaced)
        while slug.contains("--") { slug = slug.replacingOccurrences(of: "--", with: "-") }
        return slug.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    // MARK: - Case Style Conversion

    /// Returns a snake_case version of the string.
    ///
    /// Handles:
    /// - camelCase to snake_case
    /// - PascalCase to snake_case
    /// - Replaces spaces and dashes with underscores
    /// - Collapses multiple underscores
    ///
    /// Example:
    /// ```swift
    /// "userIDNumber".snakeCased // "user_id_number"
    /// "User Name".snakeCased    // "user_name"
    /// ```
    var snakeCased: String {
        // Insert underscore between acronym-lower and lower-upper boundaries
        var s = self
            .replacing(regex: "([A-Z]+)([A-Z][a-z])", with: "$1_$2")
            .replacing(regex: "([a-z0-9])([A-Z])", with: "$1_$2")
        // Replace non-alphanumerics with underscore
        s = s.replacing(regex: "[^A-Za-z0-9]+", with: "_")
        // Collapse underscores and lowercase
        while s.contains("__") { s = s.replacingOccurrences(of: "__", with: "_") }
        return s.trimmingCharacters(in: CharacterSet(charactersIn: "_")).lowercased()
    }

    /// Returns a camelCase version of the string.
    ///
    /// Handles:
    /// - snake_case, kebab-case, and space-separated words
    /// - Removes non-alphanumeric separators
    /// - Keeps the first word lowercase and capitalizes subsequent words
    ///
    /// Example:
    /// ```swift
    /// "user_id_number".camelCased // "userIdNumber"
    /// "User name".camelCased      // "userName"
    /// ```
    var camelCased: String {
        // Split on non-alphanumerics
        let parts = self
            .replacing(regex: "[^A-Za-z0-9]+", with: " ")
            .split(separator: " ")
            .map(String.init)
        guard !parts.isEmpty else { return "" }
        let head = parts[0].lowercased()
        let tail = parts.dropFirst().map { $0.lowercased().withCapitalizedFirstLetter }
        return ([head] + tail).joined()
    }
}

// MARK: - Private helpers

private extension String {
    /// Returns a String.Index that is safely clamped within the string's bounds.
    /// - Parameter offset: The character offset from `startIndex`.
    /// - Returns: A valid index within `startIndex...endIndex`.
    func safeIndex(at offset: Int) -> String.Index {
        if offset <= 0 { return startIndex }
        if let idx = index(startIndex, offsetBy: offset, limitedBy: endIndex) {
            return idx
        }
        return endIndex
    }
}

// MARK: - Usage Examples

/*
Usage examples:

// Trimming & blank check
let name = "  Ahmed Yousef  \n".trimmed            // "Ahmed Yousef"
let isEmpty = "  \n".isBlank                  // true

// Validation
"user@example.com".isValidEmail          // true
"https://apple.com".isValidURL()         // true

// Capitalization
var title = "swift"
title.capitalizeFirstLetter()             // "Swift"

// Conversions
let n = "42".toInt()                      // 42
let d = "3.14".toDouble()                 // 3.14
let b = "yes".toBool()                    // true

// Localization
let homeTitle = "home_title".localized()

// Safe substrings
let s = "abcdef"
let part1 = s.substring(from: 2)          // "cdef"
let part2 = s.substring(to: 3)            // "abc"
let part3 = s[1..<4]                      // "bcd"

// Removing special characters
"Hello, World!".removingNonAlphanumerics()            // "HelloWorld"
"Hello, World!".removingNonAlphanumerics(keepSpaces: true) // "Hello World"

// Regex helpers
"abc123".matches(regex: "[a-z]+\\d+")    // true
"Order #12345".firstMatch(regex: "#\\d+") // "#12345"
"abc123".replacing(regex: "\\d+", with: "#") // "abc#"

// Base64
"Hello".base64Encoded                     // "SGVsbG8="
"SGVsbG8=".base64Decoded                 // "Hello"

// Slugify
"Hello, World!".slugified                 // "hello-world"

// Case style conversion
"userIDNumber".snakeCased                 // "user_id_number"
"user_id_number".camelCased               // "userIdNumber"
*/

