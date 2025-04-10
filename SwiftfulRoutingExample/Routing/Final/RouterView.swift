//
//  RouterView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/9/25.
//
import SwiftUI

struct RouterView<Content: View>: View {
    
    @StateObject private var viewModel: RouterViewModel = RouterViewModel()
    var addNavigationStack: Bool = true
    var logger: Bool = false
    var content: (AnyRouter) -> Content

    var body: some View {
        RouterViewInternal(
            routerId: RouterViewModel.rootId,
            addNavigationStack: addNavigationStack,
            logger: logger,
            content: content
        )
        .environmentObject(viewModel)
    }
}

@MainActor
enum RoutingConfig {
    static var logger: (any RoutingLogger)?
    
    static func enableLogging(_ logger: some RoutingLogger) {
        self.logger = logger
    }
}
