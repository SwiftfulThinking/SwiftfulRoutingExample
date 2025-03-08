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
        .environment(viewModel)
    }
}

@MainActor
protocol Router {
//    func showScreen(destination: AnyDestination)
    func showScreens(destinations: [AnyDestination])
//    func showScreen<T>(segue: SegueOption, location: SegueLocation, id: String, @ViewBuilder destination: @escaping (Router) -> T) where T: View
    func dismissScreen()
    func dismissScreen(id: String)
    func dismissScreens(upToScreenId: String)
    func dismissScreens(count: Int)
    
    func dismissPushStack()
    func dismissEnvironment()
    
    func dismissLastScreen()
    func dismissLastPushStack()
    func dismissLastEnvironment()

    func dismissAllScreens()
}


@MainActor
@Observable
final class RouterViewModel {
    static let rootId = "root"

    var activeScreenStacks: [AnyDestinationStack] = [AnyDestinationStack(segue: .push, screens: [])]
    
    func insertRootView(view: AnyDestination) {
        activeScreenStacks.insert(AnyDestinationStack(segue: .fullScreenCover, screens: [view]), at: 0)
    }
    
    func showScreens(routerId: String, destinations: [AnyDestination]) {
        var routerIdUpdated = routerId
        
        Task {
            var lastSegue: SegueOption? = nil
            
            for destination in destinations {
                if lastSegue?.presentsNewEnvironment == true {
                    // If there is a .push after a new environment, the OS needs a slight delay before it will animate (idk why)
                    // Also if 2 new environments back to back
                    if destination.segue == .push || destination.segue.presentsNewEnvironment {
                        try? await Task.sleep(for: .seconds(0.55))
                    }
                }
                
                showScreen(routerId: routerIdUpdated, destination: destination)
                
                // After each loop, that screen is presented, so next showScreen should be the presented screen's routerId
                routerIdUpdated = destination.id
                lastSegue = destination.segue
            }
        }
    }
    
    private func showScreen(routerId: String, destination: AnyDestination) {
        // Get the index of the currentStack this is being called from
        
        let stackIndex: Int
        switch destination.location {
        case .insert:
            guard let index = activeScreenStacks.lastIndex(where: { stack in
                return stack.screens.contains(where: { $0.id == routerId })
            }) else {
                print("🚨 Error showScreen: NOT FOUND!")
                return
            }
            stackIndex = index
        case .insertAfter(id: let requestedRouterId):
            guard let index = activeScreenStacks.lastIndex(where: { stack in
                return stack.screens.contains(where: { $0.id == requestedRouterId })
            }) else {
                print("🚨 Error showScreen: NOT FOUND!")
                return
            }
            stackIndex = index
        case .append:
            guard let index = activeScreenStacks.indices.last else {
                print("🚨 Error showScreen: NOT FOUND!")
                return
            }
            stackIndex = index
        }
        

        let currentStack = activeScreenStacks[stackIndex]
        
        
        switch destination.segue {
        case .push:
            // If pushing to the next screen,
            //  If currentStack is already .push, append to it
            //  Otherwise, currentStack is therefore sheet/fullScreenCover and there should be a push stack (index +1)
            //  Otherwise, find the next .push stack and append to that

            let appendingIndex: Int = currentStack.segue == .push ? (stackIndex) : (stackIndex + 1)
            
            let existingScreens = activeScreenStacks[appendingIndex].screens
            switch destination.location {
            case .insert:
                // If there are no screens yet, we can append
                if existingScreens.isEmpty {
                    activeScreenStacks[appendingIndex].screens.append(destination)
                    return
                }
                
                // If there are existing screens and we find the requested screen
                if let index = existingScreens.firstIndex(where: { $0.id == routerId }) {
                    // If it is not last, insert
                    if existingScreens.indices.contains(index + 1) {
                        activeScreenStacks[appendingIndex].screens.insert(destination, at: index + 1)
                        return
                    } else {
                        activeScreenStacks[appendingIndex].screens.append(destination)
                        return
                    }
                }
                
                // Else, requested screen was the sheet or fullScreenCover before this stack (ie: index 0)
                activeScreenStacks[appendingIndex].screens.insert(destination, at: 0)
            case .append:
                activeScreenStacks[appendingIndex].screens.append(destination)
            case .insertAfter(let requestedRouterId):
                // If there are no screens yet, we can append
                if existingScreens.isEmpty {
                    activeScreenStacks[appendingIndex].screens.append(destination)
                    return
                }
                
                // If there are existing screens and we find the requested screen
                if let index = existingScreens.firstIndex(where: { $0.id == requestedRouterId }) {
                    // If it is not last, insert
                    if existingScreens.indices.contains(index + 1) {
                        activeScreenStacks[appendingIndex].screens.insert(destination, at: index + 1)
                        return
                    } else {
                        activeScreenStacks[appendingIndex].screens.append(destination)
                        return
                    }
                }
                
                // Else, requested screen was the sheet or fullScreenCover before this stack (ie: index 0)
                activeScreenStacks[appendingIndex].screens.insert(destination, at: 0)
            }
        case .sheet, .fullScreenCover:
            // If showing sheet or fullScreenCover,
            //  If currentStack is .push, add newStack next (index + 1)
            //  If currentStack is sheet or fullScreenCover, the next stack already a .push, add newStack after (index + 2)
            //
            // When appending a new sheet or fullScreenCover, also append a .push stack for the new NavigationStack to bind to
            //
            
            let newStack = AnyDestinationStack(segue: destination.segue, screens: [destination])
            let blankStack = AnyDestinationStack(segue: .push, screens: [])
            let appendingIndex: Int = currentStack.segue == .push ? (stackIndex + 1) : (stackIndex + 2)
            
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

    /// Removes all stacks after stackIndex. Keeps stacks up-to and including the stackIndex.
    private func removeAllStacksAsNeeded(stacks: [AnyDestinationStack], stackIndex: Int) -> (keep: [AnyDestinationStack], remove: [AnyDestinationStack]) {
        
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
    
    /// Remove screen at screenIndex and all screens after screenIndex. Keeps all screens before the screenIndex.
    private func removeScreensAsNeeded(stack: AnyDestinationStack, screenIndex: Int) -> (keep: AnyDestinationStack, remove: [AnyDestination]) {
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

    /// Dismiss screen at routeId and all screens in front of it.
    func dismissScreen(routeId: String) {
        for (stackIndex, stack) in activeScreenStacks.enumerated().reversed() {
            // Check if stack.screens contains the routeId
            // Loop from last, in case there are multiple screens in the stack with the same routeId (should not happen)
            if let screenIndex = stack.screens.lastIndex(where: { $0.id == routeId }) {
                
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
                    print("DISMISSING SCREEN \(screen.id)")
                }
                
                // Stop loop
                return
            }
        }
        
        print("🚨 RouteId: \(routeId) not found in active view heirarchy.")
    }
    
    func dismissScreens(toEnvironmentId routeId: String) {
        if let stackIndex = activeScreenStacks.firstIndex(where: { $0.screens.contains(where: { $0.id == routeId }) }) {
            if activeScreenStacks.indices.contains(stackIndex + 1) {
                let nextStack = activeScreenStacks[stackIndex + 1]
                if let lastScreen = nextStack.screens.last {
                    dismissScreens(to: lastScreen.id)
                    return
                }
            }
            
            if let lastScreen = activeScreenStacks[stackIndex].screens.last {
                dismissScreens(to: lastScreen.id)
                return
            }
        }
        
        // This is NOT a problem if it triggers.
        // This method is build to support swipe gesture dismiss.
        // However, if the user is programatically dismissing, the screens would already be dismissed herein, when this gets called anyway.
        // Therefore, it is OK to fail (it's like a safety mechanism to keep).
//        print("🚨 Dismiss to routeId: \(routeId) not found in active view heirarchy.")
    }
    
    /// Dismiss all screens in front of routeId, leaving routeId as the active screen.
    func dismissScreens(to routeId: String) {
        // The parameter routeId should be the remaining screen after dismissing all screens in front of it
        // So we call dismissScreen(routeId:) with the next screen's routeId
        
//        print("TRIGGERING ON :\(routeId)")
//        print(activeScreenStacks)
        let allScreens = activeScreenStacks.flatMap({ $0.screens })
        if let screenIndex = allScreens.firstIndex(where: { $0.id == routeId }) {
            if allScreens.indices.contains(screenIndex + 1) {
                let nextRoute = allScreens[screenIndex + 1]
                dismissScreen(routeId: nextRoute.id)
                return
            }
        }
        
        // This is NOT a problem if it triggers.
        // This method is build to support swipe gesture dismiss.
        // However, if the user is programatically dismissing, the screens would already be dismissed herein, when this gets called anyway.
        // Therefore, it is OK to fail (it's like a safety mechanism to keep).
//        print("🚨 Dismiss to routeId: \(routeId) not found in active view heirarchy.")
    }
    
    /// Dismiss the last screen presented.
    func dismissLastScreen() {
        let allScreens = activeScreenStacks.flatMap({ $0.screens })
        if let lastScreen = allScreens.last {
            dismissScreen(routeId: lastScreen.id)
            return
        }
        
        print("🚨 There are no screens to dismiss in the active view heirarchy.")
    }
    
    /// Dismiss the last x screens presented.
    func dismissScreens(count: Int) {
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
    
    /// Dismiss the closest .sheet or .fullScreenCover below the routeId.
    func dismissEnvironment(routeId: String) {
        var didFindScreen: Bool = false
        for stack in activeScreenStacks.reversed() {
            if stack.screens.contains(where: { $0.id == routeId }) {
                didFindScreen = true
            }
            
            if didFindScreen, stack.segue.presentsNewEnvironment, let route = stack.screens.first {
                dismissScreen(routeId: route.id)
                return
            }
        }
    }
    
    /// Dismiss the last .sheet or .fullScreenCover presented.
    func dismissLastEnvironment() {
        let lastEnvironmentStack = activeScreenStacks.last(where: { $0.segue.presentsNewEnvironment })
        if let route = lastEnvironmentStack?.screens.first {
            dismissScreen(routeId: route.id)
            return
        }
        
        print("🚨 There is no dismissable environment in view heirarchy.")
    }
    
    /// Dismiss all .push routes on the current NavigationStack, up-to but not including any .sheet or .fullScreenCover.
    func dismissPushStack(routeId: String) {
        for (stackIndex, stack) in activeScreenStacks.enumerated().reversed() {
            if stack.screens.contains(where: { $0.id == routeId }) {
                
                // If current stack is .push, dismiss to the first screen in this stack
                if stack.segue == .push, let route = stack.screens.first {
                    dismissScreen(routeId: route.id)
                    return
                }
                
                // If current stack is .sheet or .fullScreenCover, then the .push stack should be the following stack
                if stack.segue.presentsNewEnvironment {
                    if activeScreenStacks.indices.contains(stackIndex + 1) {
                        let nextStack = activeScreenStacks[stackIndex + 1]
                        if nextStack.segue == .push, let route = nextStack.screens.first {
                            dismissScreen(routeId: route.id)
                            return
                        }
                    }
                }
            }
        }
    }
    
    /// Dismiss all .push routes on the last NavigationStack, up-to but not including any .sheet or .fullScreenCover.
    func dismissLastPushStack() {
        let lastPushStack = activeScreenStacks.last(where: { $0.segue == .push })
        if let route = lastPushStack?.screens.first {
            dismissScreen(routeId: route.id)
            return
        }
        
        print("🚨 There is no dismissable push stack in view heirarchy.")
    }
    
    /// Dismiss all screens back to root.
    func dismissAllScreens() {
        dismissScreen(routeId: RouterViewModel.rootId)
    }

}

struct RouterViewInternal<Content: View>: View, Router {
    
    @Environment(RouterViewModel.self) var viewModel
    var routerId: String
    var addNavigationStack: Bool = false
    var logger: Bool = false
    var content: (AnyRouter) -> Content

    private var currentRouter: AnyRouter {
        AnyRouter(object: self)
    }

    var body: some View {
        content(currentRouter)
            // Add NavigationStack if needed
            .ifSatisfiesCondition(addNavigationStack, transform: { content in
                NavigationStack(path: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, onDidDismiss: { lastRouteRemaining in
                    if let lastRouteRemaining {
                        viewModel.dismissScreens(to: lastRouteRemaining.id)
                    } else {
                        viewModel.dismissPushStack(routeId: routerId)
                    }
                })) {
                    content
                        .navigationDestination(for: AnyDestination.self) { value in
                            value.destination
                        }
                }
            })
            // Add Sheet modifier. Add on background to supress OS warnings.
            .background(
                Text("")
                    .sheet(item: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, segue: .sheet, onDidDismiss: {
                        // This triggers if the user swipes down to dismiss the screen
                        // Now we must update activeScreenStacks to match that behavior
                        viewModel.dismissScreens(toEnvironmentId: routerId)
                    }), onDismiss: nil) { destination in
                        destination.destination
                    }
            )
        
            // Add FullScreenCover modifier. Add on background to supress OS warnings.
            .background(
                Text("")
                    .fullScreenCover(item: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, segue: .fullScreenCover, onDidDismiss: {
                        // This triggers if the user swipes down to dismiss the screen
                        // Now we must update activeScreenStacks to match that behavior
                        viewModel.dismissScreens(toEnvironmentId: routerId)
                    }), onDismiss: nil) { destination in
                        destination.destination
                    }
            )
        
            // If this is the root router, add "root" stack to the array
            .ifSatisfiesCondition(routerId == RouterViewModel.rootId, transform: { content in
                content
                    .onFirstAppear {
                        let view = AnyDestination(id: routerId, segue: .fullScreenCover, location: .insert, onDismiss: nil, destination: { _ in self })
                        viewModel.insertRootView(view: view)
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
    
    func showScreens(destinations: [AnyDestination]) {
        viewModel.showScreens(routerId: routerId, destinations: destinations)
    }
    
    func showScreen(destination: AnyDestination) {
        viewModel.showScreens(routerId: routerId, destinations: [destination])
    }
    
    func showScreen<T>(segue: SegueOption, location: SegueLocation, id: String, destination: @escaping (any Router) -> T) where T : View {
    }
    
    func dismissScreen() {
        viewModel.dismissScreen(routeId: routerId)
    }
    
    func dismissScreen(id: String) {
        viewModel.dismissScreen(routeId: id)
    }
    
    func dismissScreens(upToScreenId: String) {
        viewModel.dismissScreens(to: upToScreenId)
    }
    
    func dismissScreens(count: Int) {
        viewModel.dismissScreens(count: count)
    }
    
    func dismissLastScreen() {
        viewModel.dismissLastScreen()
    }
    
    func dismissEnvironment() {
        viewModel.dismissEnvironment(routeId: routerId)
    }
        
    func dismissLastEnvironment() {
        viewModel.dismissLastEnvironment()
    }
    
    func dismissLastPushStack() {
        viewModel.dismissLastPushStack()
    }
    
    func dismissPushStack() {
        viewModel.dismissPushStack(routeId: routerId)
    }
    
    func dismissAllScreens() {
        viewModel.dismissAllScreens()
    }
}

// 1.
// Manual swipe sheet - binding to sheet - DONE
// Manual swipe back - onChange of stack - DONE
//
// 2.
// Push screens - DONE
// Push screens with Sheet? - DONE
//
// 3. Make sure dismiss is working - DONE
// Dismiss working for all segues - DONE
//
// 4. Write tests for segues - DONE
// Tests for onDismiss - DONE
//
// 5.
// Enter screen flow / queue -
// Next screen -
//
// 6.
// Dismiss single screen? - HOLD
// dismiss style - .singleScreen ... .allScreensToThisScreen?
//
//
// showScreenStyle .append (top of stack) or .insert (exact location) ... insertAfter? - DONE
//
// 
// duplicate screen ids


/*
 
 Todo:
 - dismiss tests - DONE
 - on dismiss tests - DONE
 - insert, append, last dismisses - DONE
 
 
 - dismiss style (.single, .waterfall)
 - duplicate screen ids? warning?
 - location .insertAfter(x)
 - dismiss or segue with no animation?
 - addToQueue
 - nextScreen
 - contentTransition
 - Kavsoft's floating UI no background?
 
 
 - tests
 - alerts
 - modals
 - transitions
    - preloaded
    - no animation
 - modules
 - tabbars
 
 */



//

struct RoutingTest: View {
    var body: some View {
        RouterView(logger: true) { router in
            Button("Click me 1") {
                
                var firstRouter: AnyRouter? = nil
                let screen1 = AnyDestination(id: "screen_1", segue: .push, destination: { router in
                    firstRouter = router
                    return Color.red.ignoresSafeArea()
                })

                let screen2 = AnyDestination(id: "screen_2", segue: .sheet, destination: { router in
                    Color.blue.ignoresSafeArea()
                        .onTapGesture {
                            firstRouter?.showScreen(id: "adsf", segue: .push, location: .insert, destination: { _ in
                                Color.orange.ignoresSafeArea()
                                    .onTapGesture {
                                        router.dismissLastScreen()
                                    }
                            })
                        }
                })
                
//                let screen3 = AnyDestination(id: "screen_3", segue: .fullScreenCover, { router in
//                    Color.orange.ignoresSafeArea()
//                }, onDismiss: nil)
//                
//                let screen4 = AnyDestination(id: "screen_4", segue: .push, { router in
//                    Color.pink.ignoresSafeArea()
//                }, onDismiss: nil)


                router.showScreens(destinations: [screen1, screen2]) // screen3, screen4
                
                
                
//                let destination1 = AnyDestination(id: "screen_2", segue: .sheet, { router2 in
//                    Button("Click me 2") {
//                        let destination2 = AnyDestination(id: "screen_3", segue: .push, { router3 in
//                            Button("Click me 3") {
//                                let destination3 = AnyDestination(id: "screen_4", segue: .push, { router4 in
//                                    Button("Click me 4") {
//                                        router4.dismissPushStack()
//                                    }
//                                    
//                                }, onDismiss: nil)
//                                
//                                router3.showScreen(destination: destination3)
//                            }
//                        }, onDismiss: nil)
//                        
//                        router2.showScreen(destination: destination2)
//                    }
//                }, onDismiss: nil)
//                
//                router.showScreen(destination: destination1)
            }
        }
                
//                router.showScreen(segue: .sheet, id: "screen_2") { router2 in
//                    Button("Click me 2") {
////                        router2.dismissScreen()
//                        router2.showScreen(segue: .push, id: "screen_3") { router3 in
//                            Button("Click me 3") {
//                                router3.showScreen(segue: .push, id: "screen_4") { router4 in
//                                    Button("Click me 4") {
////                                        router2.dismissScreen()
////                                        router4.dismissScreen()
////                                        router2.dismissLastScreen()
////                                        router4.dismissScreens(to: "screen_2")
////                                        router4.dismissScreens(count: 2)
//                                        router4.dismissPushStack()
//                                        //                                        router4.dismissScreen()
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}

#Preview {
    RoutingTest()
}

//struct NavigationStackIfNeeded<Content:View>: View {
//    
//    @Bindable var viewModel: RouterViewModel
//    let addNavigationStack: Bool
//    var routerId: String
//    @ViewBuilder var content: Content
//    
//    @ViewBuilder var body: some View {
//        if addNavigationStack {
//            // The routerId would be the .sheet, so bind to the next .push stack after
//            NavigationStack(path: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, onDidDismiss: <#T##(AnyDestination?) -> Void##(AnyDestination?) -> Void##(_ lastRouteRemaining: AnyDestination?) -> Void#>)) {
//                content
//            }
//        } else {
//            content
//        }
//    }
//}

extension Binding where Value == [AnyDestination] {
    
    init(stack: [AnyDestinationStack], routerId: String, onDidDismiss: @escaping (_ lastRouteRemaining: AnyDestination?) -> Void) {
        self.init {
            let index = stack.firstIndex { subStack in
                return subStack.screens.contains(where: { $0.id == routerId })
            }
            guard let index, stack.indices.contains(index + 1) else {
                return []
            }
            return stack[index + 1].screens
        } set: { newValue in
            // User manually swiped back on screen
            
            let index = stack.firstIndex { subStack in
                return subStack.screens.contains(where: { $0.id == routerId })
            }
            guard let index, stack.indices.contains(index + 1) else {
                return
            }
            
            if newValue.count < stack[index + 1].screens.count {
                onDidDismiss(newValue.last)
            }
        }
    }
}


extension Binding where Value == AnyDestination? {
    
    init(stack: [AnyDestinationStack], routerId: String, segue: SegueOption, onDidDismiss: @escaping () -> Void) {
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
                return screen
            }
            
            return nil
        } set: { newValue in
            // User manually swiped down on environment
            if newValue == nil {
                onDidDismiss()
            }
        }
    }
}

//struct NavigationDestinationViewModifier: ViewModifier {
//    
//    var addNavigationDestination: Bool
//
//    func body(content: Content) -> some View {
//        if addNavigationDestination {
//            content
//                .navigationDestination(for: AnyDestination.self) { value in
//                    value.destination
//                }
//        } else {
//            content
//        }
//    }
//}
//
//extension View {
//    
//    func navigationDestinationIfNeeded(addNavigationDestination: Bool) -> some View {
//        modifier(NavigationDestinationViewModifier(addNavigationDestination: addNavigationDestination))
//    }
//}



//struct FullScreenCoverViewModifier: ViewModifier {
//    
//    @Bindable var viewModel: RouterViewModel
//    var routeId: String
//
//    func body(content: Content) -> some View {
//        content
//            .fullScreenCover(item: Binding(stack: viewModel.activeScreenStacks, routerId: routeId, segue: .fullScreenCover), onDismiss: nil) { destination in
//                destination.destination
//            }
//    }
//}
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

//struct SheetViewModifier: ViewModifier {
//    
//    @Bindable var viewModel: RouterViewModel
//    var routeId: String
//
//    func body(content: Content) -> some View {
//        content
//            .sheet(item: Binding(stack: viewModel.activeScreenStacks, routerId: routeId, segue: .sheet), onDismiss: nil) { destination in
//                destination.destination
//            }
//    }
//}




