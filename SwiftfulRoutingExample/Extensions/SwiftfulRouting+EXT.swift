//
//  SwiftfulRouting+EXT.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftfulRouting
import SwiftfulLogging

extension RoutingLogType {
    
    var type: LogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .analytic
        case .warning:
            return .warning
        case .severe:
            return .severe
        }
    }
}
extension LogManager: @retroactive RoutingLogger {
    public func trackEvent(event: any RoutingLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
    
    public func trackScreenView(event: any SwiftfulRouting.RoutingLogEvent) {
        trackEvent(event: event)
    }
}
