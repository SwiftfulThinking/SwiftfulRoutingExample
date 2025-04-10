//
//  RoutingLogger.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 11/11/24.
//
@MainActor var logger: (any RoutingLogger) = MockRoutingLogger()

// SwiftfulRouting.enableLogging(logger: logger)
@MainActor public func enableLogging(logger newValue: RoutingLogger) {
    logger = newValue
}

@MainActor
public protocol RoutingLogger {
    func trackEvent(event: RoutingLogEvent)
}

struct MockRoutingLogger: RoutingLogger {
    
    func trackEvent(event: any RoutingLogEvent) {
        #if DEBUG
        switch event.type {
        case .info:
            break
        case .analytic:
            break
        case .warning:
            print("⚠️ SwiftfulRouting -> \(event.eventName)")
        case .severe:
            print("🚨 SwiftfulRouting -> \(event.eventName)")
        }
        #endif
    }
    
}

public protocol RoutingLogEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: RoutingLogType { get }
}

public enum RoutingLogType: Int, CaseIterable, Sendable {
    case info // 0
    case analytic // 1
    case warning // 2
    case severe // 3

    var emoji: String {
        switch self {
        case .info:
            return "👋"
        case .analytic:
            return "📈"
        case .warning:
            return "⚠️"
        case .severe:
            return "🚨"
        }
    }

    var asString: String {
        switch self {
        case .info: return "info"
        case .analytic: return "analytic"
        case .warning: return "warning"
        case .severe: return "severe"
        }
    }
}
