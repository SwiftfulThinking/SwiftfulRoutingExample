//
//  RoutingTest.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/19/25.
//

import SwiftUI

struct RouterView<Content: View>: View {
    
    var content: (Router) -> Content
    @State private var viewModel: RouterViewModel = RouterViewModel()

    var body: some View {
        RouterViewInternal(
            routerId: "root",
            addNavigationStack: true,
            content: content
        )
        .environment(viewModel)
    }
}

@MainActor
protocol Router {
    func showScreen<T>(id: String, @ViewBuilder destination: @escaping (Router) -> T) where T: View
    func dismissScreen()
    func dismissScreens(to routerId: String)
}

@MainActor
@Observable
final class RouterViewModel {
    
    var screens: [AnyDestination] = []
    
    func showScreen<T>(id: String, destination: @escaping (any Router) -> T) where T : View {
        let destination = AnyDestination(
            id: id,
            RouterViewInternal(
                routerId: id,
                addNavigationStack: false,
                content: destination),
            onDismiss: nil
        )
        screens.append(destination)
    }
    
    func dismissScreen(routeId: String) {
        guard let index = screens.firstIndex(where: { $0.id == routeId }) else {
            print("Route ID not found: \(routeId)")
            return
        }
        screens = Array(screens.prefix(index))
    }
    
    func dismissScreens(to routeId: String) {
        guard let index = screens.firstIndex(where: { $0.id == routeId }) else {
            print("Route ID not found: \(routeId)")
            return
        }
        screens = Array(screens.prefix(index + 1))
    }
}

struct RouterViewInternal<Content: View>: View, Router {
    
    @Environment(RouterViewModel.self) var viewModel
    var routerId: String
    var addNavigationStack: Bool = false
    var content: (Router) -> Content

    var body: some View {
        NavigationStackIfNeeded(viewModel: viewModel, addNavigationStack: addNavigationStack) {
            content(self)
                .navigationDestinationIfNeeded(addNavigationDestination: addNavigationStack)
        }
    }
    
    func showScreen<T>(id: String, destination: @escaping (any Router) -> T) where T : View {
        viewModel.showScreen(id: id, destination: destination)
    }
    
    func dismissScreen() {
        viewModel.dismissScreen(routeId: routerId)
    }
    
    func dismissScreens(to routerId: String) {
        viewModel.dismissScreens(to: routerId)
    }
}

struct RoutingTest: View {
    var body: some View {
        RouterView { router in
            Button("Click me") {
                router.showScreen(id: "screen_2") { router2 in
                    Button("Click me 2") {
                        router2.showScreen(id: "screen_3") { router3 in
                            Button("Click me 3") {
                                router3.showScreen(id: "screen_4") { router4 in
                                    Button("Click me 4") {
                                        router4.dismissScreens(to: "screen_2")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RoutingTest()
}

import Foundation
import SwiftUI

struct AnyDestination: Identifiable, Hashable {
    let id: String
    let destination: AnyView
    let onDismiss: (() -> Void)?

    init<T:View>(id: String = UUID().uuidString, _ destination: T, onDismiss: (() -> Void)? = nil) {
        self.id = id
        self.destination = AnyView(destination)
        self.onDismiss = onDismiss
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.id == rhs.id
    }
    
}


struct NavigationStackIfNeeded<Content:View>: View {
    
    @Bindable var viewModel: RouterViewModel
    let addNavigationStack: Bool
    @ViewBuilder var content: Content
    
    @ViewBuilder var body: some View {
        if addNavigationStack {
            NavigationStack(path: $viewModel.screens) {
                content
            }
        } else {
            content
        }
    }
}

struct NavigationDestinationViewModifier: ViewModifier {
    
    var addNavigationDestination: Bool

    func body(content: Content) -> some View {
        if addNavigationDestination {
            content
                .navigationDestination(for: AnyDestination.self) { value in
                    value.destination
                }
        } else {
            content
        }
    }
}

extension View {
    
    func navigationDestinationIfNeeded(addNavigationDestination: Bool) -> some View {
        modifier(NavigationDestinationViewModifier(addNavigationDestination: addNavigationDestination))
    }
}
