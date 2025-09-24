# Utilities — Swift Extensions and Helpers for iOS

A production-ready set of extensions and lightweight helpers commonly needed in iOS apps. All utilities are concise, documented with Swift `///` comments, and organized using `// MARK:` sections.

## What’s Included
- String extensions: trimming, validation (email/URL), safe conversions, localization, safe substringing, special-character removal, regex helpers, Base64 encode/decode, slugification, and case-style conversion between camelCase and snake_case.
- Date extensions: formatting/parsing, components (year/month/day/hour/minute/second), adding days/months/years, relative checks (today/yesterday/tomorrow), past/future checks, day/week/month boundaries, differences (minutes/hours/days), time zone conversions, and age calculation.
- Int extensions: grouping with commas, seconds -> m:ss, random in range helper, toString, even/odd, clamping.
- Double extensions: rounding to N decimals, percentage/currency strings (locale-aware), toInt (rounded), clamping, seconds -> h:mm:ss.
- NetworkMonitor helper: a lightweight, thread-safe utility built on `NWPathMonitor` to observe connectivity (Wi‑Fi, Cellular, no connection) with Combine-friendly `@Published` properties and optional closure callbacks.

## Requirements
- Swift 6
- iOS 15+ (also works on other Apple platforms with Foundation; `NetworkMonitor` uses `Network` framework available on iOS 12+)
- Xcode 15+

## Installation via Swift Package Manager
Swift Package Manager (SPM) is the recommended way to integrate this library.

### Using Xcode
1. In Xcode, go to: File → Add Packages…
2. Enter the package URL:
