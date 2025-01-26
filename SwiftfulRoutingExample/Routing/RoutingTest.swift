//
//  RoutingTest.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/19/25.
//

import SwiftUI

/* STACK EXAMPLES:
 
 Basic structure is that every new environment has [.sheet] + [.push]

 
 STACK: .fullScreenCover, .push, .push, .push:
 [
     [.fullScreenCover]
     [.push, .push, .push]
 ]
 
 
 STACK .fullScreenCover, .push, .push, .sheet, .push:
 [
     [.fullScreenCover]
     [.push, .push]
     [.sheet]
     [.push]
 ]
 
 STACK .fullScreenCover, .sheet, .push, .sheet:
 [
     [.fullScreenCover]
     []
     [.sheet]
     [.push]
     [.sheet]
     []
 ]
 
 STACK .fullScreenCover, .fullScreenCover, .fullScreenCover:
 [
     [.fullScreenCover]
     []                     <- these empty stacks in-between are for .pushes
     [.fullScreenCover]
     []
     [.fullScreenCover]
     []
 ]
 */



struct RouterView<Content: View>: View {
    @State private var viewModel: RouterViewModel = RouterViewModel()
    var logger: Bool = false
    var content: (Router) -> Content

    var body: some View {
        RouterViewInternal(
            routerId: RouterViewModel.rootId,
            addNavigationStack: true,
            logger: logger,
            content: content
        )
        .environment(viewModel)
    }
}

@MainActor
protocol Router {
    func showScreen<T>(segue: SegueOption, id: String, @ViewBuilder destination: @escaping (Router) -> T) where T: View
    func dismissScreen()
    func dismissScreen(id: String)
    func dismissLastScreen()
    func dismissScreens(to: String)
    func dismissScreens(count: Int)
}

struct AnyDestinationStack: Equatable {
    private(set) var segue: SegueOption
    private(set) var screens: [AnyDestination]
    
//    mutating func updating(screens: [AnyDestination]) {
//        self.screens = screens
//    }
    
    mutating func adding(screen: AnyDestination) {
        self.screens.append(screen)
    }
}

@MainActor
@Observable
final class RouterViewModel {
    static let rootId = "root"

    var activeScreenStacks: [AnyDestinationStack] = [AnyDestinationStack(segue: .push, screens: [])]
    
    func insertRootView(view: AnyDestination) {
        activeScreenStacks.insert(AnyDestinationStack(segue: .fullScreenCover, screens: [view]), at: 0)
    }
    
    func showScreen<T>(segue: SegueOption, id: String, routerId: String, destination: @escaping (any Router) -> T) where T : View {
        
        // Wrap injected destination within another RouterViewInternal
        let destination = AnyDestination(
            id: id,
            RouterViewInternal(
                routerId: id,
                addNavigationStack: segue != .push,
                content: destination
            ),
            onDismiss: nil
        )
        
        // Get the index of the currentStack this is being called from
        guard let index = activeScreenStacks.lastIndex(where: { stack in
            return stack.screens.contains(where: { $0.id == routerId })
        }) else {
            return
        }

        let currentStack = activeScreenStacks[index]
        
        
        switch segue {
        case .push:
            // If pushing to the next screen,
            //  If currentStack is already .push, append to it
            //  Otherwise, currentStack is therefore sheet/fullScreenCover and there should be a push stack (index +1)
            // Otherwise, find the next .push stack and append to that

            let appendingIndex: Int = currentStack.segue == .push ? (index) : (index + 1)
            
            activeScreenStacks[appendingIndex].adding(screen: destination)
        case .sheet, .fullScreenCover:
            // If showing sheet or fullScreenCover,
            //  If currentStack is .push, add newStack next (index + 1)
            //  If currentStack is sheet or fullScreenCover, the next stack already a .push, add newStack after (index + 2)
            //
            // When appending a new sheet or fullScreenCover, also append a .push stack for the new NavigationStack to bind to
            //
            
            let newStack = AnyDestinationStack(segue: segue, screens: [destination])
            let blankStack = AnyDestinationStack(segue: .push, screens: [])
            let appendingIndex: Int = currentStack.segue == .push ? (index + 1) : (index + 2)
            
            activeScreenStacks.insert(contentsOf: [newStack, blankStack], at: appendingIndex)
        }
    }
    
    // Simplify the first one
    // Combine both of these
    // Clean up the logic
    //
    // Add other dismiss methods (all, environment, count)
    
    // Currently dismisses screen
    
    // Change to dismiss only the screen in question
    
    // add dismissLastScreen()
    // add dismissScreens(count: 2)
    // add dismissScreens(ids: [])
    // add dismissScreen(id: [])
    // add dismissScreen()

    
    // Dismiss push - DONE
    // Dismiss push, push, push - DONE
    // Dismiss sheet - DONE
    // Dismiss sheet, sheet, sheet
    // Dismiss any combo

    private func removeAllStacksAsNeeded(stacks: [AnyDestinationStack], stackIndex: Int) -> (keep: [AnyDestinationStack], remove: [AnyDestinationStack]) {
        // Keep stacks up-to and including the current stackIndex
        // Remove all stacks after current stackIndex
        
        // Ensure the index is within bounds
        guard stackIndex >= 0 && stackIndex < stacks.count else {
            // If the index is out of bounds, return all stacks as "keep" and none as "remove"
            return (keep: stacks, remove: [])
        }
        
        let currentStack = stacks[stackIndex]
        if currentStack.screens.count > 1 {
            // Do not remove the currentStack
            
            let keep = Array(stacks[...stackIndex]) // Includes up to and including the stackIndex
            let remove = Array(stacks[(stackIndex + 1)...]) // Includes all after stackIndex
            return (keep, remove)
        } else {
            // Remove the currentStack
            let keep = Array(stacks[..<stackIndex]) // Includes stacks before the current stackIndex
            let remove = Array(stacks[stackIndex...]) // Includes the current stack and all after it
            return (keep, remove)
        }
    }
    
    private func removeScreensAsNeeded(stack: AnyDestinationStack, screenIndex: Int) -> (keep: AnyDestinationStack, remove: [AnyDestination]) {
        // Keep all screens before the current screenIndex
        // Remove screen at currentIndex and all screens after currentIndex
        let screens: [AnyDestination] = stack.screens
        
        // Ensure the index is within bounds
        guard screenIndex >= 0 && screenIndex < screens.count else {
            // If the index is out of bounds, keep all screens and remove none
            return (keep: stack, remove: [])
        }

        // Split the screens array into keep and remove parts
        let keepScreens = Array(screens[..<screenIndex]) // Keep all screens before screenIndex
        let removeScreens = Array(screens[screenIndex...]) // Remove the current screen and all after it

        // Create a new stack with the remaining screens
        let keepStack = AnyDestinationStack(segue: stack.segue, screens: keepScreens)

        return (keep: keepStack, remove: removeScreens)
    }

    /// Dismiss screen at routeId and all screens in front of it. (TBD?)
    func dismissScreen(routeId: String) {
        for (stackIndex, stack) in activeScreenStacks.enumerated().reversed() {
            // Check if stack.screens contains the routeId
            // Loop from last, in case there are multiple screens in the stack with the same routeId (should not happen)
            if let screenIndex = stack.screens.lastIndex(where: { $0.id == routeId }) {
                
                print("STACK INDEX IS: \(stackIndex)")
                print("SCREEN INDEX IS \(screenIndex)")
                
                
                var (keep, remove) = removeAllStacksAsNeeded(stacks: activeScreenStacks, stackIndex: stackIndex)
                var screensToDismiss = remove.flatMap({ $0.screens })
                
                // If the currentStack is still here, then it was not removed
                // Now we need to trim current stack as well
                if keep.indices.contains(stackIndex) {
                    let currentStack = keep[stackIndex]
                    let (currentStackUpdated, removeScreens) = removeScreensAsNeeded(stack: currentStack, screenIndex: screenIndex)
                    
                    // Update currentStack without current screen
                    keep[stackIndex] = currentStackUpdated
                    
                    // Append more screen to remove
                    if !removeScreens.isEmpty {
                        screensToDismiss.insert(contentsOf: removeScreens, at: 0)
                    }
                }
                
                // There should always be a blank pushable stack for the NavigationStack to bind to
                if keep.last?.segue != .push {
                    keep.append(AnyDestinationStack(segue: .push, screens: []))
                }
                
                // Publish update to the view
                activeScreenStacks = keep

                // Trigger screen onDismiss closures, if available
                for screen in screensToDismiss.reversed() {
                    screen.onDismiss?()
                }
                
                // Stop loop
                return
            }
        }
        
        print("🚨 RouteId: \(routeId) not found in active view heirarchy.")
    }
    
    func dismissScreens(to routeId: String) {
        // The parameter routeId should be the remaining screen after dismissing all screens in front of it
        // So we call dismissScreen(routeId:) with the next screen's routeId
        
        let allScreens = activeScreenStacks.flatMap({ $0.screens })
        if let screenIndex = allScreens.firstIndex(where: { $0.id == routeId }) {
            if allScreens.indices.contains(screenIndex + 1) {
                let nextRoute = allScreens[screenIndex + 1]
                dismissScreen(routeId: nextRoute.id)
                return
            }
        }
        
        print("🚨 Dismiss to routeId: \(routeId) not found in active view heirarchy.")
    }
    
    func dismissLastScreen() {
        // Find the last screen and dismiss it
        let allScreens = activeScreenStacks.flatMap({ $0.screens })
        if let lastScreen = allScreens.last {
            dismissScreen(routeId: lastScreen.id)
            return
        }
        
        print("🚨 There are no screens to dismiss in the active view heirarchy.")
    }
    
    func dismissScreens(count: Int) {
        // Find the last screen and dismiss it
        let allScreensReversed = activeScreenStacks.flatMap({ $0.screens }).reversed()
        
        var counter: Int = 0
        for screen in allScreensReversed {
            counter += 1
            
            if counter == count || screen == allScreensReversed.last {
                dismissScreen(routeId: screen.id)
                return
            }
        }
        
        print("🚨 There are no screens to dismiss in the active view heirarchy.")
    }
    
    /// Dismiss the environment for the routeId
    func dismissEnvironment(routeId: String) {
        
    }
    
    /// Dismiss the top-most environment
    func dismissLastEnvironment() {
        
    }
    
    /// Dismiss the push stack for the routeId
    func dismissPushStack(routeId: String) {
        
    }
    
    /// Dismiss the top-most push stack
    func dismissLastPushStack() {
        
    }
    
    /// Dismiss all screens back to root
    func dismissAllScreens() {
        dismissScreen(routeId: RouterViewModel.rootId)
    }

}

struct RouterViewInternal<Content: View>: View, Router {
    
    @Environment(RouterViewModel.self) var viewModel
    var routerId: String
    var addNavigationStack: Bool = false
    var logger: Bool = false
    var content: (Router) -> Content

    var body: some View {
        content(self)
            // Add NavigationStack if needed
            .ifSatisfiesCondition(addNavigationStack, transform: { content in
                NavigationStack(path: Binding(stack: viewModel.activeScreenStacks, routerId: routerId)) {
                    content
                        .navigationDestination(for: AnyDestination.self) { value in
                            value.destination
                        }
                }
            })
            // Add Sheet modifier. Add on background to supress OS warnings.
            .background(
                Text("")
                    .sheet(item: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, segue: .sheet), onDismiss: nil) { destination in
                        destination.destination
                    }
            )
        
            // Add FullScreenCover modifier. Add on background to supress OS warnings.
            .background(
                Text("")
                    .fullScreenCover(item: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, segue: .fullScreenCover), onDismiss: nil) { destination in
                        destination.destination
                    }
            )
        
            // If this is the root router, add "root" stack to the array
            .ifSatisfiesCondition(routerId == RouterViewModel.rootId, transform: { content in
                content
                    .onFirstAppear {
                        viewModel.insertRootView(view: AnyDestination(id: routerId, self, onDismiss: nil))
                    }
            })
        
            // Print screen stack if logging is enabled
            .ifSatisfiesCondition(logger && routerId == RouterViewModel.rootId, transform: { content in
                content
                    .onChange(of: viewModel.activeScreenStacks) { oldValue, newValue in
                        printScreenStack(newValue)
                    }
            })
    }
    
    private func printScreenStack(_ newValue: [AnyDestinationStack]) {
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
    
    func showScreen<T>(segue: SegueOption, id: String, destination: @escaping (any Router) -> T) where T : View {
        viewModel.showScreen(segue: segue, id: id, routerId: routerId, destination: destination)
    }
    
    
    func dismissLastScreen() {
        viewModel.dismissLastScreen()
    }

    func dismissScreen() {
        viewModel.dismissScreen(routeId: routerId)
    }
    
    func dismissScreen(id: String) {
        viewModel.dismissScreen(routeId: id)
    }
    
    func dismissScreens(to routerId: String) {
        viewModel.dismissScreens(to: routerId)
    }
    
    func dismissScreens(count: Int) {
        viewModel.dismissScreens(count: count)
    }
    
    func dismissAllScreens() {
        
    }
    
    func dismissEnvironment() {
        
    }
    
    func dismissPushStack() {
        
    }
    
    /*
     // add dismissLastScreen()
     // add dismissScreens(count: 2)
     // add dismissScreens(ids: [])
     // add dismissScreen(id: [])
     // add dismissScreen()

     */
}

struct RoutingTest: View {
    var body: some View {
        RouterView(logger: true) { router in
            Button("Click me 1") {
                router.showScreen(segue: .sheet, id: "screen_2") { router2 in
                    Button("Click me 2") {
//                        router2.dismissScreen()
                        router2.showScreen(segue: .push, id: "screen_3") { router3 in
                            Button("Click me 3") {
                                router3.showScreen(segue: .sheet, id: "screen_4") { router4 in
                                    Button("Click me 4") {
//                                        router2.dismissScreen()
//                                        router4.dismissScreen()
//                                        router2.dismissLastScreen()
//                                        router4.dismissScreens(to: "screen_2")
                                        router4.dismissScreens(count: 2)
                                        //                                        router4.dismissScreen()
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
            NavigationStack(path: Binding(stack: viewModel.activeScreenStacks, routerId: routerId)) {
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

            if routerStack.segue == .push, routerStack.screens.last?.id != routerId {
                return nil
            }
            
            var nextSheetStack: AnyDestinationStack?
            if routerStack.segue == .push, stack.indices.contains(routerStackIndex + 1) {
                nextSheetStack = stack[routerStackIndex + 1]
            } else if stack.indices.contains(routerStackIndex + 2) {
                nextSheetStack = stack[routerStackIndex + 2]
            }

            if nextSheetStack?.segue == segue, let screen = nextSheetStack?.screens.first {
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
            .fullScreenCover(item: Binding(stack: viewModel.activeScreenStacks, routerId: routeId, segue: .fullScreenCover), onDismiss: nil) { destination in
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
            .sheet(item: Binding(stack: viewModel.activeScreenStacks, routerId: routeId, segue: .sheet), onDismiss: nil) { destination in
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
