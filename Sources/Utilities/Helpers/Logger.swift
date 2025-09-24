//
//  Logger.swift
//  Utilities
//
//  Created by Ahmed Yousef on 24/09/2025.
//

import Foundation

// MARK: - Logger

/// A lightweight, thread-safe logging utility for iOS projects.
///
/// Logger provides consistent, configurable logging with support for multiple levels, timestamp formatting,
/// optional emojis, and contextual information (file, function, and line). It is safe to use from any thread
/// and serializes output so logs appear in order.
///
/// Use the shared instance `Logger.shared` for convenience, or create your own instance with a custom configuration.
///
/// Example:
/// ```swift
/// Logger.shared.debug("Fetching user profile…")
/// Logger.shared.info("Profile loaded")
/// Logger.shared.warning("Low disk space warning")
/// Logger.shared.error("Failed to save: \(error.localizedDescription)")
/// ```
public final class Logger: @unchecked Sendable {

    // MARK: Configuration

    /// A configuration container that controls how the logger formats and emits messages.
    public struct Configuration: Sendable {
        /// Date format used for timestamps (e.g., "yyyy-MM-dd HH:mm:ss.SSS").
        public var dateFormat: String
        /// Whether to include emojis for each log level.
        public var showEmojis: Bool
        /// Whether to include file, function, and line context in each log.
        public var showContext: Bool
        /// Master switch to enable/disable logging output.
        public var enabled: Bool

        /// Creates a configuration.
        /// - Parameters:
        ///   - dateFormat: Date format for timestamps.
        ///   - showEmojis: Include emojis in output.
        ///   - showContext: Include file/function/line context.
        ///   - enabled: Enable/disable logging.
        public init(dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS",
                    showEmojis: Bool = true,
                    showContext: Bool = true,
                    enabled: Bool = {
                        #if DEBUG
                        true
                        #else
                        false
                        #endif
                    }()) {
            self.dateFormat = dateFormat
            self.showEmojis = showEmojis
            self.showContext = showContext
            self.enabled = enabled
        }

        /// A sensible default configuration.
        public static var `default`: Configuration { Configuration() }
    }

    // MARK: Levels

    /// Log levels supported by the logger.
    public enum Level: Int, Sendable, CaseIterable {
        /// Verbose debugging information.
        case debug
        /// General informational messages.
        case info
        /// Non-fatal warnings about potential issues.
        case warning
        /// Errors indicating failures that require attention.
        case error

        /// A short textual marker for the level (e.g., "[DEBUG]").
        public var marker: String {
            switch self {
            case .debug:   return "[DEBUG]"
            case .info:    return "[INFO ]"
            case .warning: return "[WARN ]"
            case .error:   return "[ERROR]"
            }
        }

        /// An optional emoji associated with the level.
        public var emoji: String {
            switch self {
            case .debug:   return "🛠"
            case .info:    return "ℹ️"
            case .warning: return "⚠️"
            case .error:   return "❌"
            }
        }
    }

    // MARK: Shared instance

    /// A shared, global logger instance configured with defaults.
    public static let shared = Logger()

    // MARK: Private state

    private let queue = DispatchQueue(label: "com.utilities.logger", qos: .utility)
    private var configuration: Configuration
    private let dateFormatter: DateFormatter

    // MARK: Initialization

    /// Creates a logger with a given configuration.
    /// - Parameter configuration: The initial configuration to use. Defaults to `.default`.
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
        self.dateFormatter = DateFormatter()
        self.dateFormatter.locale = .current
        self.dateFormatter.timeZone = .current
        self.dateFormatter.dateFormat = configuration.dateFormat
    }

    // MARK: Configuration API

    /// Updates the logger's configuration in a thread-safe manner.
    /// - Parameter update: A closure that can mutate the current configuration.
    ///
    /// Example:
    /// ```swift
    /// Logger.shared.configure { cfg in
    ///     cfg.showEmojis = false
    ///     cfg.enabled = true
    /// }
    /// ```
    public func configure(_ update: (inout Configuration) -> Void) {
        queue.sync {
            var cfg = self.configuration
            update(&cfg)
            self.configuration = cfg
            // Keep DateFormatter in sync with the configured format.
            self.dateFormatter.dateFormat = cfg.dateFormat
        }
    }

    /// Enables or disables logging output.
    /// - Parameter enabled: Pass `true` to enable logging or `false` to silence it.
    ///
    /// Example:
    /// ```swift
    /// #if !DEBUG
    /// Logger.shared.setEnabled(false)
    /// #endif
    /// ```
    public func setEnabled(_ enabled: Bool) {
        configure { $0.enabled = enabled }
    }

    // MARK: Public logging API

    /// Logs a message at the specified level.
    /// - Parameters:
    ///   - level: The log level.
    ///   - message: The message to log. Evaluated lazily.
    ///   - file: The file name from which the log originates. Defaults to `#fileID`.
    ///   - function: The function name from which the log originates. Defaults to `#function`.
    ///   - line: The line number from which the log originates. Defaults to `#line`.
    ///
    /// Example:
    /// ```swift
    /// Logger.shared.log(.info, "App launched")
    /// ```
    public func log(_ level: Level,
                    _ message: @Sendable @autoclosure @escaping () -> String,
                    file: String = #fileID,
                    function: String = #function,
                    line: Int = #line) {
        // Evaluate the message immediately to avoid capturing a non-Sendable closure in a @Sendable context.
        let resolvedMessage = message()
        queue.async { [weak self] in
            guard let self else { return }
            let cfg = self.configuration
            guard cfg.enabled else { return }

            let timestamp = self.dateFormatter.string(from: Date())
            let levelToken = cfg.showEmojis ? level.emoji : level.marker

            var context = ""
            if cfg.showContext {
                context = " [\(file):\(line) \(function)]"
            }

            let output = "\(timestamp) \(levelToken) \(resolvedMessage)\(context)"
            print(output)
        }
    }

    /// Logs a debug-level message.
    /// - Parameters:
    ///   - message: The message to log. Evaluated lazily.
    ///   - file: The file name from which the log originates. Defaults to `#fileID`.
    ///   - function: The function name from which the log originates. Defaults to `#function`.
    ///   - line: The line number from which the log originates. Defaults to `#line`.
    ///
    /// Example:
    /// ```swift
    /// Logger.shared.debug("Loading cache…")
    /// ```
    public func debug(_ message: @Sendable @autoclosure @escaping () -> String,
                      file: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
        log(.debug, message(), file: file, function: function, line: line)
    }

    /// Logs an info-level message.
    /// - Parameters:
    ///   - message: The message to log. Evaluated lazily.
    ///   - file: The file name from which the log originates. Defaults to `#fileID`.
    ///   - function: The function name from which the log originates. Defaults to `#function`.
    ///   - line: The line number from which the log originates. Defaults to `#line`.
    ///
    /// Example:
    /// ```swift
    /// Logger.shared.info("User signed in")
    /// ```
    public func info(_ message: @Sendable @autoclosure @escaping () -> String,
                     file: String = #fileID,
                     function: String = #function,
                     line: Int = #line) {
        log(.info, message(), file: file, function: function, line: line)
    }

    /// Logs a warning-level message.
    /// - Parameters:
    ///   - message: The message to log. Evaluated lazily.
    ///   - file: The file name from which the log originates. Defaults to `#fileID`.
    ///   - function: The function name from which the log originates. Defaults to `#function`.
    ///   - line: The line number from which the log originates. Defaults to `#line`.
    ///
    /// Example:
    /// ```swift
    /// Logger.shared.warning("Disk space critically low")
    /// ```
    public func warning(_ message: @Sendable @autoclosure @escaping () -> String,
                        file: String = #fileID,
                        function: String = #function,
                        line: Int = #line) {
        log(.warning, message(), file: file, function: function, line: line)
    }

    /// Logs an error-level message.
    /// - Parameters:
    ///   - message: The message to log. Evaluated lazily.
    ///   - file: The file name from which the log originates. Defaults to `#fileID`.
    ///   - function: The function name from which the log originates. Defaults to `#function`.
    ///   - line: The line number from which the log originates. Defaults to `#line`.
    ///
    /// Example:
    /// ```swift
    /// Logger.shared.error("Network request failed")
    /// ```
    public func error(_ message: @Sendable @autoclosure @escaping () -> String,
                      file: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
        log(.error, message(), file: file, function: function, line: line)
    }
}

// MARK: - Usage Examples

/*
Usage examples:

// Basic logging
Logger.shared.debug("Fetching user profile…")
Logger.shared.info("Profile loaded")
Logger.shared.warning("Low disk space warning")
Logger.shared.error("Failed to save: unexpected nil")

// Customize configuration
Logger.shared.configure { cfg in
    cfg.showEmojis = false
    cfg.showContext = true
    cfg.dateFormat = "HH:mm:ss.SSS"
}

// Disable logging in Release builds
#if !DEBUG
Logger.shared.setEnabled(false)
#endif
*/

