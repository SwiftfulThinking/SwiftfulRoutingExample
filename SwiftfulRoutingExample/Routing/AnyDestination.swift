//
//  AnyDestination.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 2/17/25.
//


import Foundation
import SwiftUI

enum SegueLocation {
    /// Insert screen at the location of the call-site's router
    case insert
    /// Append screen to the end of the active stack
    case append
    /// Insert screen after the location injected screen's router
    case insertAfter(id: String)
}

struct AnyDestination: Identifiable, Hashable {
    let id: String
    let segue: SegueOption
    let location: SegueLocation
    let animates: Bool
    private(set) var destination: AnyView
    let onDismiss: (() -> Void)?
    
//    init<T:View>(id: String = UUID().uuidString, _ segue: SegueOption = .push, location: SegueLocation = .insert, onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> T) {
//        self.init(id: id, segue: segue, location: location, onDismiss: onDismiss, destination: destination)
//    }
    
    init<T:View>(
        id: String = UUID().uuidString,
        segue: SegueOption = .push,
        location: SegueLocation = .insert,
        animates: Bool = true,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> T
    ) {
        self.id = id
        self.segue = segue
        self.location = location
        self.animates = animates
        self.destination = AnyView(
            RouterViewInternal(
                routerId: id,
                addNavigationStack: segue != .push,
                content: destination
            )
        )
        self.onDismiss = onDismiss
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.id == rhs.id
    }
    
}

enum AlertStyle {
    case alert, confirmationDialog
}

struct AnyAlert: Identifiable {
    let id = UUID().uuidString
    let style: AlertStyle
    let title: String
    let subtitle: String?
    let buttons: AnyView
    
    init<T:View>(
        style: AlertStyle = .alert,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder buttons: () -> T
    ) {
        self.style = style
        self.title = title
        self.subtitle = subtitle
        self.buttons = AnyView(buttons())
    }
    
    init(
        style: AlertStyle = .alert,
        title: String,
        subtitle: String? = nil
    ) {
        self.style = style
        self.title = title
        self.subtitle = subtitle
        self.buttons = AnyView(
            Button("OK", action: { })
        )
    }
}
