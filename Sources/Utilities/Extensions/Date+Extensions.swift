//
//  Date+Extensions.swift
//  Utilities
//
//  Created by Ahmed Yousef on 24/09/2025.
//

import Foundation

// MARK: - Date Common Utilities

public extension Date {
    // MARK: Formatting & Parsing

    /// Formats the date into a string using a custom date format.
    /// - Parameters:
    ///   - format: A date format string (e.g., `"yyyy-MM-dd HH:mm"`).
    ///   - locale: The locale to use. Defaults to `.current`.
    ///   - timeZone: The time zone to use. Defaults to `.current` if `nil`.
    /// - Returns: A formatted date string.
    ///
    /// Example:
    /// ```swift
    /// let now = Date()
    /// let s = now.string(withFormat: "yyyy-MM-dd HH:mm")
    /// ```
    func string(withFormat format: String, locale: Locale = .current, timeZone: TimeZone? = nil) -> String {
        let tz = timeZone ?? .current
        let formatter = _DateFormatterCache.formatter(format: format, locale: locale, timeZone: tz)
        return formatter.string(from: self)
    }

    /// Parses a date from a string using the specified format.
    /// - Parameters:
    ///   - string: The input string to parse.
    ///   - format: A date format string (e.g., `"yyyy-MM-dd"`).
    ///   - locale: The locale to use. Defaults to `.current`.
    ///   - timeZone: The time zone to use. Defaults to `.current` if `nil`.
    /// - Returns: A `Date` if parsing succeeds; otherwise `nil`.
    ///
    /// Example:
    /// ```swift
    /// let birthday = Date.from("1990-05-12", format: "yyyy-MM-dd")
    /// ```
    static func from(_ string: String, format: String, locale: Locale = .current, timeZone: TimeZone? = nil) -> Date? {
        let tz = timeZone ?? .current
        let formatter = _DateFormatterCache.formatter(format: format, locale: locale, timeZone: tz)
        return formatter.date(from: string)
    }

    /// Creates a `Date` by parsing a string using the specified format.
    /// - Parameters:
    ///   - string: The input string to parse.
    ///   - format: A date format string (e.g., `"yyyy-MM-dd"`).
    ///   - locale: The locale to use. Defaults to `.current`.
    ///   - timeZone: The time zone to use. Defaults to `.current` if `nil`.
    ///
    /// Example:
    /// ```swift
    /// let d = Date(string: "2025-09-24", format: "yyyy-MM-dd")
    /// ```
    init?(string: String, format: String, locale: Locale = .current, timeZone: TimeZone? = nil) {
        guard let date = Date.from(string, format: format, locale: locale, timeZone: timeZone) else { return nil }
        self = date
    }

    // MARK: Components

    /// The year component of the date in the current calendar.
    ///
    /// Example:
    /// ```swift
    /// let y = Date().year
    /// ```
    var year: Int { Calendar.current.component(.year, from: self) }

    /// The month component of the date in the current calendar.
    var month: Int { Calendar.current.component(.month, from: self) }

    /// The day component of the date in the current calendar.
    var day: Int { Calendar.current.component(.day, from: self) }

    /// The hour component of the date in the current calendar.
    var hour: Int { Calendar.current.component(.hour, from: self) }

    /// The minute component of the date in the current calendar.
    var minute: Int { Calendar.current.component(.minute, from: self) }

    /// The second component of the date in the current calendar.
    var second: Int { Calendar.current.component(.second, from: self) }

    // MARK: Arithmetic (Adding)

    /// Returns a new date by adding a number of days.
    /// - Parameters:
    ///   - days: The number of days to add (negative to subtract).
    ///   - calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The resulting date. Falls back to `self` if the operation fails (e.g., DST edge cases).
    ///
    /// Example:
    /// ```swift
    /// let nextWeek = Date().addingDays(7)
    /// ```
    func addingDays(_ days: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Returns a new date by adding a number of months.
    /// - Parameters:
    ///   - months: The number of months to add (negative to subtract).
    ///   - calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The resulting date. Falls back to `self` if the operation fails.
    ///
    /// Example:
    /// ```swift
    /// let nextMonth = Date().addingMonths(1)
    /// ```
    func addingMonths(_ months: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .month, value: months, to: self) ?? self
    }

    /// Returns a new date by adding a number of years.
    /// - Parameters:
    ///   - years: The number of years to add (negative to subtract).
    ///   - calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The resulting date. Falls back to `self` if the operation fails.
    ///
    /// Example:
    /// ```swift
    /// let nextYear = Date().addingYears(1)
    /// ```
    func addingYears(_ years: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .year, value: years, to: self) ?? self
    }

    // MARK: Relative Checks

    /// Indicates whether the date is today in the current calendar.
    var isToday: Bool { Calendar.current.isDateInToday(self) }

    /// Indicates whether the date is yesterday in the current calendar.
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }

    /// Indicates whether the date is tomorrow in the current calendar.
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }

    /// Indicates whether the date is in the past relative to now.
    var isPast: Bool { self < Date() }

    /// Indicates whether the date is in the future relative to now.
    var isFuture: Bool { self > Date() }

    // MARK: Day/Week/Month Boundaries

    /// The start of the day for the date in the given calendar.
    /// - Parameter calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The start-of-day date.
    ///
    /// Example:
    /// ```swift
    /// let start = Date().startOfDay()
    /// ```
    func startOfDay(calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    /// The end of the day for the date in the given calendar.
    /// - Parameter calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The end-of-day date (one second before the next day's start).
    ///
    /// Example:
    /// ```swift
    /// let end = Date().endOfDay()
    /// ```
    func endOfDay(calendar: Calendar = .current) -> Date {
        if let interval = calendar.dateInterval(of: .day, for: self) {
            return interval.end.addingTimeInterval(-1)
        }
        // Fallback: 1 day minus 1 second from startOfDay
        return startOfDay(calendar: calendar).addingTimeInterval(86_400 - 1)
    }

    /// The start of the week that contains the date.
    /// - Parameter calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The start-of-week date, or `nil` if it cannot be computed.
    ///
    /// Example:
    /// ```swift
    /// let start = Date().startOfWeek()
    /// ```
    func startOfWeek(calendar: Calendar = .current) -> Date? {
        calendar.dateInterval(of: .weekOfYear, for: self)?.start
    }

    /// The end of the week that contains the date.
    /// - Parameter calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The end-of-week date (one second before the next week's start), or `nil` if it cannot be computed.
    ///
    /// Example:
    /// ```swift
    /// let end = Date().endOfWeek()
    /// ```
    func endOfWeek(calendar: Calendar = .current) -> Date? {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: self) else { return nil }
        return interval.end.addingTimeInterval(-1)
    }

    /// The start of the month that contains the date.
    /// - Parameter calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The start-of-month date, or `nil` if it cannot be computed.
    ///
    /// Example:
    /// ```swift
    /// let start = Date().startOfMonth()
    /// ```
    func startOfMonth(calendar: Calendar = .current) -> Date? {
        calendar.dateInterval(of: .month, for: self)?.start
    }

    /// The end of the month that contains the date.
    /// - Parameter calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The end-of-month date (one second before the next month's start), or `nil` if it cannot be computed.
    ///
    /// Example:
    /// ```swift
    /// let end = Date().endOfMonth()
    /// ```
    func endOfMonth(calendar: Calendar = .current) -> Date? {
        guard let interval = calendar.dateInterval(of: .month, for: self) else { return nil }
        return interval.end.addingTimeInterval(-1)
    }

    // MARK: Differences

    /// Returns the whole number of minutes between this date and another date.
    /// - Parameter date: The other date.
    /// - Returns: The signed number of minutes (positive if `self` is later than `date`).
    ///
    /// Example:
    /// ```swift
    /// let mins = Date().minutes(since: Date().addingTimeInterval(-3600)) // ~60
    /// ```
    func minutes(since date: Date) -> Int {
        Int((timeIntervalSince(date)) / 60.0)
    }

    /// Returns the whole number of hours between this date and another date.
    /// - Parameter date: The other date.
    /// - Returns: The signed number of hours (positive if `self` is later than `date`).
    ///
    /// Example:
    /// ```swift
    /// let hours = Date().hours(since: Date().addingTimeInterval(-7200)) // ~2
    /// ```
    func hours(since date: Date) -> Int {
        Int((timeIntervalSince(date)) / 3_600.0)
    }

    /// Returns the whole number of days between this date and another date.
    /// - Parameter date: The other date.
    /// - Returns: The signed number of days (positive if `self` is later than `date`).
    ///
    /// Example:
    /// ```swift
    /// let days = Date().days(since: Date().addingTimeInterval(-172800)) // ~2
    /// ```
    func days(since date: Date) -> Int {
        Int((timeIntervalSince(date)) / 86_400.0)
    }

    // MARK: Time Zone Conversion

    /// Converts a UTC date to the equivalent local time by applying the time zone offset.
    /// - Parameter timeZone: The local time zone to convert to. Defaults to `.current`.
    /// - Returns: A date adjusted by the time zone's offset, preserving wall-clock components.
    ///
    /// - Important: `Date` represents an absolute point in time and is time zone–agnostic. This helper is useful
    ///   when you have a date interpreted as UTC and want a date that, when formatted in `timeZone`, shows the same
    ///   clock components.
    ///
    /// Example:
    /// ```swift
    /// let utcNoon = Date.from("2025-09-24 12:00", format: "yyyy-MM-dd HH:mm", timeZone: TimeZone(secondsFromGMT: 0))!
    /// let localNoon = utcNoon.toLocalTime() // Adjusted to local zone
    /// ```
    func toLocalTime(timeZone: TimeZone = .current) -> Date {
        let seconds = timeZone.secondsFromGMT(for: self)
        return addingTimeInterval(TimeInterval(seconds))
    }

    /// Converts a local date (interpreted in a specific time zone) to UTC by removing the time zone offset.
    /// - Parameter timeZone: The source local time zone. Defaults to `.current`.
    /// - Returns: A date adjusted to UTC, preserving wall-clock components.
    ///
    /// - Important: `Date` is absolute; this helper is useful when you need a date that, when formatted in UTC,
    ///   shows the same clock components as `self` formatted in `timeZone`.
    ///
    /// Example:
    /// ```swift
    /// let localNoon = Date.from("2025-09-24 12:00", format: "yyyy-MM-dd HH:mm")!
    /// let utcNoon = localNoon.toUTC() // Adjusted to UTC
    /// ```
    func toUTC(from timeZone: TimeZone = .current) -> Date {
        let seconds = timeZone.secondsFromGMT(for: self)
        return addingTimeInterval(TimeInterval(-seconds))
    }

    // MARK: Age

    /// Calculates age in full years from a birth date to a given date.
    /// - Parameters:
    ///   - asOf: The reference date (defaults to `Date()`).
    ///   - calendar: The calendar to use. Defaults to `.current`.
    /// - Returns: The age in completed years (never negative; clamped to 0).
    ///
    /// Example:
    /// ```swift
    /// let birth = Date.from("1990-05-12", format: "yyyy-MM-dd")!
    /// let years = birth.age() // e.g., 35
    /// ```
    func age(asOf: Date = Date(), calendar: Calendar = .current) -> Int {
        let comps = calendar.dateComponents([.year], from: self, to: asOf)
        return max(0, comps.year ?? 0)
    }
}

// MARK: - Private: DateFormatter Cache

private enum _DateFormatterCache {
    nonisolated(unsafe) private static let cache = NSCache<NSString, DateFormatter>()

    static func formatter(format: String, locale: Locale, timeZone: TimeZone) -> DateFormatter {
        let key = "\(format)|\(locale.identifier)|\(timeZone.identifier)" as NSString
        if let cached = cache.object(forKey: key) { return cached }
        let df = DateFormatter()
        df.locale = locale
        df.timeZone = timeZone
        df.dateFormat = format
        cache.setObject(df, forKey: key)
        return df
    }
}

// MARK: - Usage Examples

/*
Usage examples:

// Formatting & parsing
let now = Date()
let s = now.string(withFormat: "yyyy-MM-dd HH:mm")
let parsed = Date.from("2025-09-24", format: "yyyy-MM-dd")

// Components
_ = now.year; _ = now.month; _ = now.day
_ = now.hour; _ = now.minute; _ = now.second

// Arithmetic
let nextWeek = now.addingDays(7)
let nextMonth = now.addingMonths(1)
let nextYear = now.addingYears(1)

// Relative checks
_ = now.isToday
_ = now.isYesterday
_ = now.isTomorrow
_ = now.isPast
_ = now.isFuture

// Boundaries
let startDay = now.startOfDay()
let endDay = now.endOfDay()
let startWeek = now.startOfWeek()
let endWeek = now.endOfWeek()
let startMonth = now.startOfMonth()
let endMonth = now.endOfMonth()

// Differences
let mins = now.minutes(since: now.addingTimeInterval(-3600)) // ~60
let hrs = now.hours(since: now.addingTimeInterval(-7200))    // ~2
let dys = now.days(since: now.addingTimeInterval(-172800))   // ~2

// Time zone conversion
let utcNoon = Date.from("2025-09-24 12:00", format: "yyyy-MM-dd HH:mm", timeZone: TimeZone(secondsFromGMT: 0))!
let localNoon = utcNoon.toLocalTime() // Adjusted to local zone
let backToUTC = localNoon.toUTC()

// Age
let birth = Date.from("1990-05-12", format: "yyyy-MM-dd")!
let age = birth.age()
*/
