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
            routerId: RouterViewModel.rootId,
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

struct AnyDestinationStack: Equatable {
    var segue: SegueOption
    var screens: [AnyDestination]
    
    func dismiss(index: Int) -> AnyDestinationStack {
        AnyDestinationStack(segue: segue, screens: Array(screens.prefix(index)))
    }
}

@MainActor
@Observable
final class RouterViewModel {
    static let rootId = "root"

    var screens: [AnyDestinationStack] = [AnyDestinationStack(segue: .push, screens: [])]
    
    func insertRootView(view: AnyDestination) {
        screens.insert(AnyDestinationStack(segue: .sheet, screens: [view]), at: 0)
    }
    
    func showScreen<T>(segue: SegueOption, id: String, routerId: String, destination: @escaping (any Router) -> T) where T : View {
        let destination = AnyDestination(
            id: id,
            RouterViewInternal(
                routerId: id,
                addNavigationStack: segue != .push,
                content: destination),
            onDismiss: nil
        )
        
        let index = screens.firstIndex { stack in
            return stack.screens.contains(where: { $0.id == routerId })
        }
        guard let index else {
            print("routerId index not found!")
            return
        }

        let item = screens[index]

        
        switch segue {
        case .push:
            // Look for routerId, if it's in a .push stack, append to that
            // Otherwise, find the next .push stack and append to that

            if item.segue == .push {
                screens[index].screens.append(destination)
            } else {
                screens[index + 1].screens.append(destination) // tbd
            }
        case .sheet, .fullScreenCover:
            // Look for routerId, if it's in a .push stack, append after that
            // Otherwise, find the next .push stack and append to that
            
            let blankStack = AnyDestinationStack(segue: .push, screens: [])
            if item.segue == .push {
                screens.insert(contentsOf: [
                    AnyDestinationStack(segue: segue, screens: [destination]),
                    blankStack
                ], at: index + 1)
            } else {
                screens.insert(contentsOf: [
                    AnyDestinationStack(segue: segue, screens: [destination]),
                    blankStack
                ], at: index + 2) // tbd
            }
        }
    }
    
    func dismissScreen(routeId: String) {
        for (outerIndex, innerArray) in screens.enumerated() {
            if let innerIndex = innerArray.screens.firstIndex(where: { $0.id == routeId }) {
                // Remove all arrays after the current outerIndex
                screens = Array(screens.prefix(outerIndex + 1))
                
                // Trim the inner array to include only elements up to and including the matched destination
                screens[outerIndex] = innerArray.dismiss(index: innerIndex)
                
                // There should always be a blank pushable stack for the NavigationStack to bind to
                if screens.last?.segue != .push {
                    screens.append(AnyDestinationStack(segue: .push, screens: []))
                }
                return
            }
        }
    }
    
    func dismissScreens(to routeId: String) {
        for (outerIndex, innerArray) in screens.enumerated() {
            if let innerIndex = innerArray.screens.firstIndex(where: { $0.id == routeId }) {
                // Remove all arrays after the current outerIndex
                screens = Array(screens.prefix(outerIndex + 1))
                
                // Trim the inner array to include only elements up to and including the matched destination
                screens[outerIndex] = innerArray.dismiss(index: innerIndex + 1)
                
                if screens.last?.segue != .push {
                    screens.append(AnyDestinationStack(segue: .push, screens: []))
                }
                return
            }
        }
    }
}

// Getting weird behavior only when having BOTH modifiers together.
// Works when it's 1 or the other perfectly fine.
// Try a Binding if so that both of these aren't on the same View?
// Check

// Check observable object?
// which variation worked but with errors?
//
//

/*
 .ifSatisfiesCondition(addNavigationStack, transform: { content in
     content
         .ifSatisfiesCondition(getNextStack(segue: .sheet) != nil, transform: { content in
             content
                 .modifier(SheetViewModifier(viewModel: viewModel, routeId: routerId))
         })
         .ifSatisfiesCondition(getNextStack(segue: .fullScreenCover) != nil, transform: { content in
             content
                 .modifier(FullScreenCoverViewModifier(viewModel: viewModel, routeId: routerId))
         })
 })
 
 works but no animations (too fast lol)
 

 Look at original solution
 */

struct RouterViewInternal<Content: View>: View, Router {
    
    @Environment(RouterViewModel.self) var viewModel
    var routerId: String
    var addNavigationStack: Bool = false
    var content: (Router) -> Content
    
//    @State private var segue: SegueOption = .push
    
    private var getStack: AnyDestinationStack? {
        viewModel.screens.first { stack in
            return stack.screens.contains(where: { $0.id == routerId })
        }
    }
    
    private func getNextStack(segue: SegueOption) -> AnyDestinationStack? {
        let index = viewModel.screens.firstIndex { stack in
            return stack.screens.contains(where: { $0.id == routerId })
        }
        guard let index, viewModel.screens.indices.contains(index + 1) else {
            return nil
        }
//        print("NEXT STACK FOR \(routerId)")
//        print(viewModel.screens[index + 1])
        let nextSheetStack = viewModel.screens[(index + 1)...].first(where: { $0.segue == segue })

        return nextSheetStack
    }

    var body: some View {
        NavigationStackIfNeeded(viewModel: viewModel, addNavigationStack: addNavigationStack, routerId: routerId) {
            content(self)
                .navigationDestinationIfNeeded(addNavigationDestination: addNavigationStack)
                .overlay(
                    Text("")
                        .modifier(SheetViewModifier(viewModel: viewModel, routeId: routerId))
                )
                .background(
                    Text("")
                        .modifier(FullScreenCoverViewModifier(viewModel: viewModel, routeId: routerId))
                )
                .ifSatisfiesCondition(routerId == RouterViewModel.rootId, transform: { content in
                    content
                        .onFirstAppear {
                            viewModel.insertRootView(view: AnyDestination(id: routerId, self, onDismiss: nil))
                        }
                })
        }
        .ifSatisfiesCondition(routerId == RouterViewModel.rootId, transform: { content in
            content
                .onChange(of: viewModel.screens) { oldValue, newValue in
                    print("PRINTING SCREEN STACK")
                    
                    // For each AnyDestinationStack
                    for (arrayIndex, item) in newValue.enumerated() {
                        print("stack \(arrayIndex): \(item.segue.rawValue)")
                        
                        if item.screens.isEmpty {
                            print("    no screens")
                        } else {
                            for (screenIndex, screen) in item.screens.enumerated() {
                                print("    screen \(screenIndex): \(screen.id)")
                            }
                        }
                    }
                    print("\n")
                }
        })
    }
    
    func showScreen<T>(segue: SegueOption, id: String, destination: @escaping (any Router) -> T) where T : View {
        viewModel.showScreen(segue: segue, id: id, routerId: routerId, destination: destination)
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
            Button("Click me 1") {
                router.showScreen(segue: .sheet, id: "screen_2") { router2 in
                    Button("Click me 2") {
                        router2.showScreen(segue: .fullScreenCover, id: "screen_3") { router3 in
                            Button("Click me 3") {
                                router3.showScreen(segue: .sheet, id: "screen_4") { router4 in
                                    Button("Click me 4") {
//                                        router4.dismissScreen()
                                        router4.dismissScreens(to: "root")
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
    var routerId: String
    @ViewBuilder var content: Content
    
    @ViewBuilder var body: some View {
        if addNavigationStack {
            // The routerId would be the .sheet, so bind to the next .push stack after
            NavigationStack(path: Binding(stack: viewModel.screens, routerId: routerId)) {
                content
            }
        } else {
            content
        }
    }
}

extension Binding where Value == [AnyDestination] {
    
    init(stack: [AnyDestinationStack], routerId: String) {
        self.init {
            let index = stack.firstIndex { subStack in
                return subStack.screens.contains(where: { $0.id == routerId })
            }
            guard let index, stack.indices.contains(index + 1) else {
                return []
            }
            return stack[index + 1].screens
        } set: { newValue in
            //            value.wrappedValue = newValue
        }
    }
}


extension Binding where Value == AnyDestination? {
    
    init(stack: [AnyDestinationStack], routerId: String, segue: SegueOption) {
        self.init {
            let routerStackIndex = stack.firstIndex { subStack in
                return subStack.screens.contains(where: { $0.id == routerId })
            }
            
            guard let routerStackIndex else {
                return nil
            }
            
            let routerStack = stack[routerStackIndex]
//            print("router stack: \(routerStack)")
            if routerStack.segue == .push, routerStack.screens.last?.id != routerId {
                return nil
            }
            
//            // Find the next item (after item) in stack where stack.segue == .sheet
            let nextSheetStack = stack[(routerStackIndex + 1)...].first(where: { $0.segue == segue })
//            print("NEXT stack: \(routerStack)")

            if let screen = nextSheetStack?.screens.first {
//                print("RETURNING TRUE \(segue.rawValue)!!!!! \(routerId) \(stack.count)")
                return screen
            }
            
//            print("RETURNING FALSE \(segue.rawValue)!!!!! \(routerId) \(stack.count)")

            return nil
        } set: { newValue in
//            value.wrappedValue = newValue
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

public enum SegueOption: String, Equatable {
    case push, sheet, fullScreenCover
    
//    @available(iOS 14.0, *)
//    case
//    
//    @available(iOS 16.0, *)
//    case sheetDetents
}

struct FullScreenCoverViewModifier: ViewModifier {
    
    @Bindable var viewModel: RouterViewModel
    var routeId: String

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: Binding(stack: viewModel.screens, routerId: routeId, segue: .fullScreenCover), onDismiss: nil) { destination in
                destination.destination
            }
    }
}
/*
 ZStack {
     if let loadedDestination {
         loadedDestination.destination
     }
 }
 .onAppear {
     loadedDestination = destination
 }
 */

struct SheetViewModifier: ViewModifier {
    
    @Bindable var viewModel: RouterViewModel
    var routeId: String

    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(stack: viewModel.screens, routerId: routeId, segue: .sheet), onDismiss: nil) { destination in
                destination.destination
            }
    }
}

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
    
}
