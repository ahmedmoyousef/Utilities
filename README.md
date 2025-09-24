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

## Installation
These sources live under `Sources/Utilities/`.

- Same app target: Include the source files in your app target. No extra import is required beyond Foundation for extensions; for helpers, import as needed.
  - Extensions: `Sources/Utilities/Extensions/`
  - Helpers: `Sources/Utilities/Helpers/`
- As a Swift Package module named `Utilities`: Add the package to your project, then:
```swift
import Utilities
