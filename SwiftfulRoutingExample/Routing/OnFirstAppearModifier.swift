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
    
    @ViewBuilder func ifLetCondition<T, Content: View>(_ value: T?, transform: @escaping (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
    
    @ViewBuilder func applyResizableSheetModifiersIfNeeded(segue: SegueOption) -> some View {
        switch segue {
        case .push:
            self
        case .sheet(config: let config):
            self
                // If a selection is passed in, bind to it
                .ifLetCondition(config.selection) { content, value in
                    content
                        .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }), selection: Binding(selection: value))
                }
                // Otherwise, don't pass in anything for the selection
                .ifSatisfiesCondition(config.selection == nil) { content in
                    content
                        .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }))
                }
            
                // Value for showing drag indicator
                .presentationDragIndicator(config.dragIndicator)
            
                // Add background color if needed
                .applyEnvironmentBackground(option: config.background)
            
                // Value for background corner radius
                .ifLetCondition(config.cornerRadius, transform: { content, value in
                    content
                        .presentationCornerRadius(value)
                })
            
                // Background interaction
                .presentationBackgroundInteraction(config.backgroundInteraction)
            
                // Content interaction
                .presentationContentInteraction(config.contentInteraction)
        case .fullScreenCover(config: let config):
            self
                // Add background color if needed
                .applyEnvironmentBackground(option: config.background)
        }
    }
    
    @ViewBuilder private func applyEnvironmentBackground(option: EnvironmentBackgroundOption) -> some View {
        switch option {
        case .automatic:
            self
        case .clear:
            self
                .presentationBackground(.clear)
                .background(RemoveSheetShadow())
        case .custom(let value):
            self
                .presentationBackground(AnyShapeStyle(value))
        }
    }
    
}


fileprivate struct RemoveSheetShadow: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let shadowView = view.dropShadowView {
                shadowView.layer.shadowColor = UIColor.clear.cgColor
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension UIView {
    var dropShadowView: UIView? {
        if let superview, String(describing: type(of: superview)) == "UIDropShadowView" {
            return superview
        }
        
        return superview?.dropShadowView
    }
}
