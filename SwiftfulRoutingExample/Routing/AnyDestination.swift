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
}

struct AnyDestination: Identifiable, Hashable {
    let id: String
    let segue: SegueOption
    let location: SegueLocation
    private(set) var destination: AnyView
    let onDismiss: (() -> Void)?
    
//    init<T:View>(id: String = UUID().uuidString, _ segue: SegueOption = .push, location: SegueLocation = .insert, onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> T) {
//        self.init(id: id, segue: segue, location: location, onDismiss: onDismiss, destination: destination)
//    }
    
    init<T:View>(id: String = UUID().uuidString, segue: SegueOption = .push, location: SegueLocation = .insert, onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> T) {
        self.id = id
        self.segue = segue
        self.location = location
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
