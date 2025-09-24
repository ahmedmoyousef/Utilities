//
//  NetworkMonitor.swift
//  Utilities
//
//  Created by Ahmed Yousef on 24/09/2025.
//

import Foundation
import Network
import Combine

// MARK: - NetworkMonitor

/// A lightweight, thread-safe utility for monitoring network connectivity on iOS.
///
/// `NetworkMonitor` uses `NWPathMonitor` to observe changes to the device's network
/// path and exposes connectivity state via published properties for SwiftUI/Combine,
/// and optional closure callbacks for UIKit-based apps.
///
/// Features:
/// - Observe connectivity changes (Wi‑Fi, Cellular, no connection).
/// - Published properties for reactive updates: `isConnected`, `isOnWiFi`, `isOnCellular`.
/// - Callbacks for UIKit projects via `onStatusChange`.
/// - Singleton access via `NetworkMonitor.shared`.
/// - Thread-safe start/stop and state updates.
///
/// Usage:
/// ```swift
/// // AppDelegate / SceneDelegate: start monitoring
/// NetworkMonitor.shared.start()
///
/// // SwiftUI: Observe with @StateObject or @ObservedObject
/// @StateObject private var networkMonitor = NetworkMonitor.shared
/// var body: some View {
///     VStack {
///         if networkMonitor.isConnected {
///             Text("Online")
///         } else {
///             Text("Offline")
///         }
///     }
/// }
///
/// // UIKit: Use closure callback
/// NetworkMonitor.shared.onStatusChange = { status in
///     switch status {
///     case .satisfiedWiFi:
///         print("Connected via Wi‑Fi")
///     case .satisfiedCellular:
///         print("Connected via Cellular")
///     case .unsatisfied:
///         print("No connection")
///     }
/// }
/// ```
public final class NetworkMonitor: ObservableObject, @unchecked Sendable {

    // MARK: Nested Types

    /// Represents a simplified connectivity status derived from `NWPath`.
    public enum Status: Equatable, Sendable {
        /// Connected to the internet via Wi‑Fi (includes wired/ethernet on supported devices).
        case satisfiedWiFi
        /// Connected to the internet via Cellular.
        case satisfiedCellular
        /// No internet connection available.
        case unsatisfied
    }

    // MARK: Singleton

    /// Shared singleton instance for convenience.
    public static let shared = NetworkMonitor()

    // MARK: Published Properties (for SwiftUI/Combine)

    /// Indicates whether the device is currently connected to the internet.
    @Published public private(set) var isConnected: Bool = false
    /// Indicates whether the active connection is Wi‑Fi (or equivalent like wired/ethernet).
    @Published public private(set) var isOnWiFi: Bool = false
    /// Indicates whether the active connection is Cellular.
    @Published public private(set) var isOnCellular: Bool = false
    /// The derived connectivity status.
    @Published public private(set) var status: Status = .unsatisfied

    // MARK: Callbacks (for UIKit)

    /// Closure invoked whenever connectivity status changes.
    /// Set this from UIKit code to receive updates without Combine.
    public var onStatusChange: (@Sendable (Status) -> Void)?

    // MARK: Private State

    private let monitor: NWPathMonitor
    private let monitorQueue: DispatchQueue
    private let stateQueue = DispatchQueue(label: "com.utilities.networkmonitor.state", qos: .utility)
    private var isMonitoring: Bool = false

    // MARK: Initialization

    /// Creates a new `NetworkMonitor` instance.
    /// - Note: Prefer using the shared singleton `NetworkMonitor.shared` in most cases.
    public init() {
        self.monitor = NWPathMonitor()
        self.monitorQueue = DispatchQueue(label: "com.utilities.networkmonitor.monitor", qos: .utility)
        setupPathUpdateHandler()
    }

    // MARK: Monitoring Control

    /// Starts network path monitoring if not already started.
    ///
    /// Example:
    /// ```swift
    /// NetworkMonitor.shared.start()
    /// ```
    public func start() {
        stateQueue.sync {
            guard !isMonitoring else { return }
            isMonitoring = true
            monitor.start(queue: monitorQueue)
        }
    }

    /// Stops network path monitoring if currently active.
    ///
    /// Example:
    /// ```swift
    /// NetworkMonitor.shared.stop()
    /// ```
    public func stop() {
        stateQueue.sync {
            guard isMonitoring else { return }
            isMonitoring = false
            monitor.cancel()
        }
    }

    // MARK: Computed Properties

    /// `true` if there is at least one satisfied path using Wi‑Fi or wired/ethernet.
    /// This mirrors `isOnWiFi` and is provided for completeness.
    public var isOnEthernetOrWiFi: Bool { isOnWiFi }

    // MARK: Helpers

    /// Configures the monitor's path update handler to process connectivity changes.
    private func setupPathUpdateHandler() {
        monitor.pathUpdateHandler = { [weak self] path in
//            guard let self else { return }
            let derived = Self.deriveStatus(from: path)
            self?.apply(status: derived)
        }
    }

    /// Derives a simplified `Status` from an `NWPath`.
    /// - Parameter path: The network path reported by `NWPathMonitor`.
    /// - Returns: A simplified `Status` value.
    private static func deriveStatus(from path: NWPath) -> Status {
        guard path.status == .satisfied else { return .unsatisfied }

        // Prefer Wi‑Fi/ethernet when available; otherwise cellular when constrained to it.
        if path.usesInterfaceType(.wifi) || path.usesInterfaceType(.wiredEthernet) {
            return .satisfiedWiFi
        }
        if path.usesInterfaceType(.cellular) {
            return .satisfiedCellular
        }
        // Fallback: satisfied but unknown interface type.
        return .satisfiedWiFi
    }

    /// Applies a new `Status` to published properties and invokes callbacks.
    /// - Parameter status: The new connectivity status to apply.
    private func apply(status newStatus: Status) {
        // Update internal state and publish changes on the main queue to keep UI consistent.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.status = newStatus
            switch newStatus {
            case .satisfiedWiFi:
                self.isConnected = true
                self.isOnWiFi = true
                self.isOnCellular = false
            case .satisfiedCellular:
                self.isConnected = true
                self.isOnWiFi = false
                self.isOnCellular = true
            case .unsatisfied:
                self.isConnected = false
                self.isOnWiFi = false
                self.isOnCellular = false
            }
            self.onStatusChange?(newStatus)
        }
    }
}

// MARK: - Usage Examples

/*
Usage examples:

// 1) Start monitoring in AppDelegate or SceneDelegate
// AppDelegate example:
// func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//     NetworkMonitor.shared.start()
//     return true
// }
//
// SceneDelegate example:
// func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//     NetworkMonitor.shared.start()
// }
//
// 2) SwiftUI observation using @StateObject or @ObservedObject
// struct ContentView: View {
//     @StateObject private var networkMonitor = NetworkMonitor.shared
//     var body: some View {
//         VStack(spacing: 12) {
//             Text(networkMonitor.isConnected ? "Online" : "Offline")
//             if networkMonitor.isOnWiFi { Text("Wi‑Fi") }
//             if networkMonitor.isOnCellular { Text("Cellular") }
//         }
//         .onAppear { NetworkMonitor.shared.start() }
//     }
// }
//
// 3) UIKit closures
// NetworkMonitor.shared.onStatusChange = { status in
//     switch status {
//     case .satisfiedWiFi: print("Connected via Wi‑Fi")
//     case .satisfiedCellular: print("Connected via Cellular")
//     case .unsatisfied: print("No connection")
//     }
// }
// NetworkMonitor.shared.start()
*/


