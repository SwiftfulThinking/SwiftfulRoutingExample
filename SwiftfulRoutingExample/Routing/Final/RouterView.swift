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
    var content: (AnyRouter) -> Content

    var body: some View {
        RouterViewInternal(
            routerId: RouterViewModel.rootId,
            addNavigationStack: addNavigationStack,
            content: content
        )
        .environmentObject(viewModel)
    }
}
