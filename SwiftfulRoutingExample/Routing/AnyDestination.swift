//
//  AnyDestination.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 2/17/25.
//


import Foundation
import SwiftUI

struct AnyDestination: Identifiable, Hashable {
    let id: String
    let segue: SegueOption
    private(set) var destination: AnyView
    let onDismiss: (() -> Void)?

    init<T:View>(id: String = UUID().uuidString, segue: SegueOption, _ destination: @escaping (any Router) -> T, onDismiss: (() -> Void)? = nil) {
        self.id = id
        self.segue = segue
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
    
//    mutating func wrappedInRouterViewInternal() {
//        destination = AnyView(
//            RouterViewInternal(
//                routerId: id,
//                addNavigationStack: segue != .push,
//                content: destination
//            )
//        )
//    }
}
