//
//  AnyDestinationStack.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 2/17/25.
//
import SwiftUI

struct AnyDestinationStack: Equatable {
    private(set) var segue: SegueOption
    var screens: [AnyDestination]
}
