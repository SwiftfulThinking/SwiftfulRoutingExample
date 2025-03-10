//
//  OnFirstAppearModifier.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 2/17/25.
//
import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
    let action: @MainActor () -> Void
    @State private var isFirstAppear = true
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if isFirstAppear {
                    action()
                    isFirstAppear = false
                }
            }
    }
}

extension View {
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnFirstAppearModifier(action: action))
    }
}

extension View {
    
    @ViewBuilder func ifSatisfiesCondition<Content: View>(_ condition: Bool, transform: @escaping (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func applyResizableSheetModifiersIfNeeded(segue: SegueOption) -> some View {
        switch segue {
        case .push:
            self
        case .sheet:
            self
        case .fullScreenCover:
            self
        case .resizableSheet(let config):
            if let selection = config.selection {
                self
                    .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }), selection: Binding(selection: selection))
                    .presentationDragIndicator(config.dragIndicator)
            } else {
                self
                    .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }))
                    .presentationDragIndicator(config.dragIndicator)
            }
        }
    }
    
}
