//
//  RouterView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/9/25.
//
import SwiftUI

@MainActor
final class ModuleViewModel: ObservableObject {
    
    // All modules
    // Modules are removed from the array when dismissed.
    @Published private(set) var moduleStack: [AnyTransitionDestination] = [.root]
    
    // The current TransitionOption for changing modules.
    @Published private(set) var currentModuleTransition: TransitionOption = .trailing

}

struct RouterView<Content: View>: View {
    
    @StateObject private var viewModel = ModuleViewModel()
    var addNavigationStack: Bool = true
    var addModuleSupport: Bool = false
    var content: (AnyRouter) -> Content

    var body: some View {
        Group {
            if addModuleSupport {
                ModuleSupportView(
                    addNavigationStack: addNavigationStack,
                    modules: viewModel.moduleStack,
                    content: content,
                    currentTransition: viewModel.currentModuleTransition
                )
            } else {
                RouterViewModelWrapper {
                    RouterViewInternal(
                        routerId: RouterViewModel.rootId,
                        addNavigationStack: addNavigationStack,
                        content: content
                    )
                }
            }
        }
        .environmentObject(viewModel)
    }
}

struct RouterViewModelWrapper<Content: View>: View {
    
    @StateObject private var viewModel = RouterViewModel()
    @ViewBuilder var content: Content

    var body: some View {
        content
            .environmentObject(viewModel)
    }
}
