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
    func showScreen<T>(segue: SegueOption, id: String, @ViewBuilder destination: @escaping (Router) -> T) where T: View
    func dismissScreen()
    func dismissScreens(to routerId: String)
}

@MainActor
@Observable
final class RouterViewModel {
    
    var screens: [[AnyDestination]] = [[]]
    
    func showScreen<T>(segue: SegueOption, id: String, destination: @escaping (any Router) -> T) where T : View {
        let destination = AnyDestination(
            id: id,
            RouterViewInternal(
                routerId: id,
                addNavigationStack: false,
                content: destination),
            onDismiss: nil
        )
        
        switch segue {
        case .push:
            if screens.isEmpty {
                screens.append([destination])
            } else {
                screens[screens.count - 1].append(destination)
            }
        case .sheet:
            break
        }
    }
    
    func dismissScreen(routeId: String) {
        for (outerIndex, innerArray) in screens.enumerated() {
            if let innerIndex = innerArray.firstIndex(where: { $0.id == routeId }) {
                // Remove all arrays after the current outerIndex
                screens = Array(screens.prefix(outerIndex + 1))
                
                // Trim the inner array to include only elements up to and including the matched destination
                screens[outerIndex] = Array(innerArray.prefix(innerIndex))
                return
            }
        }
    }
    
    func dismissScreens(to routeId: String) {
        for (outerIndex, innerArray) in screens.enumerated() {
            if let innerIndex = innerArray.firstIndex(where: { $0.id == routeId }) {
                // Remove all arrays after the current outerIndex
                screens = Array(screens.prefix(outerIndex + 1))
                
                // Trim the inner array to include only elements up to and including the matched destination
                screens[outerIndex] = Array(innerArray.prefix(innerIndex + 1))
                return
            }
        }
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
    
    func showScreen<T>(segue: SegueOption, id: String, destination: @escaping (any Router) -> T) where T : View {
        viewModel.showScreen(segue: segue, id: id, destination: destination)
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
                router.showScreen(segue: .push, id: "screen_2") { router2 in
                    Button("Click me 2") {
                        router2.showScreen(segue: .push, id: "screen_3") { router3 in
                            Button("Click me 3") {
                                router3.showScreen(segue: .push, id: "screen_4") { router4 in
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
            NavigationStack(path: $viewModel.screens.last!) {
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

public enum SegueOption: Equatable {
    case push, sheet // , fullScreenCover
    
//    @available(iOS 14.0, *)
//    case
//    
//    @available(iOS 16.0, *)
//    case sheetDetents
}
