//
//  View+EXT.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder func ifSatisfiesCondition<Content: View>(_ condition: Bool, transform: @escaping (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func ifLetCondition<T, Content: View>(_ value: T?, transform: @escaping (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }

}
