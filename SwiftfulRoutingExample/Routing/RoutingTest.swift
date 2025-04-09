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

//@MainActor
protocol Router: Sendable {
    @MainActor func showScreens(destinations: [AnyDestination])
    @MainActor func dismissScreen(animates: Bool)
    @MainActor func dismissScreen(id: String, animates: Bool)
    @MainActor func dismissScreens(upToScreenId: String, animates: Bool)
    @MainActor func dismissScreens(count: Int, animates: Bool)
    @MainActor func dismissPushStack(animates: Bool)
    @MainActor func dismissEnvironment(animates: Bool)
    @MainActor func dismissLastScreen(animates: Bool)
    @MainActor func dismissLastPushStack(animates: Bool)
    @MainActor func dismissLastEnvironment(animates: Bool)
    @MainActor func dismissAllScreens(animates: Bool)
    
    @MainActor func addScreensToQueue(destinations: [AnyDestination])
    @MainActor func removeScreensFromQueue(ids: [String])
    @MainActor func clearScreenQueue()
    @MainActor func showNextScreen() throws
    
    @MainActor func showAlert(alert: AnyAlert)
    @MainActor func dismissAlert()
    
    @MainActor func showModal(modal: AnyModal)
    @MainActor func dismissModal()
    @MainActor func dismissModal(id: String)
    @MainActor func dismissModals(upToModalId: String)
    @MainActor func dismissModals(count: Int)
    @MainActor func dismissAllModals()
    
    @MainActor func showTransition(transition: AnyTransitionDestination)
    @MainActor func showTransitions(transitions: [AnyTransitionDestination])
    @MainActor func dismissTransition() throws
    @MainActor func dismissTransition(id: String)
    @MainActor func dismissTransitions(upToScreenId: String)
    @MainActor func dismissTransitions(count: Int)
    @MainActor func dismissAllTransitions()
    
    @MainActor func addTransitionsToQueue(transitions: [AnyTransitionDestination])
    @MainActor func removeTransitionsFromQueue(ids: [String])
    @MainActor func clearTransitionsQueue()
    @MainActor func showNextTransition() throws
}


@MainActor
@Observable
final class RouterViewModel {
    static let rootId = "root"

    // make these private(set)?
    // throw errors on dismiss not there?
    // better printing
    
    
    var activeScreenStacks: [AnyDestinationStack] = [AnyDestinationStack(segue: .push, screens: [])]
    
    var availableScreenQueue: [AnyDestination] = []
    
    var activeAlert: [String: AnyAlert] = [:] // RouterId : Alert
    
    var allModals: [String: [AnyModal]] = [:] // RouterId : [Modals]
    
    var allTransitions: [String: [AnyTransitionDestination]] = [RouterViewModel.rootId: [.root]] // RouterId : [Transitions]
    var currentTransitions: [String: TransitionOption] = [RouterViewModel.rootId: .trailing]
    var availableTransitionQueue: [String: [AnyTransitionDestination]] = [:]
    
    func insertRootView(view: AnyDestination) {
        activeScreenStacks.insert(AnyDestinationStack(segue: .fullScreenCover(), screens: [view]), at: 0)
    }
    
    func addScreensToQueue(routerId: String, destinations: [AnyDestination]) {
        var insertCounts: [String: Int] = [
            routerId: 0
        ]
        for destination in destinations {
            switch destination.location {
            case .append:
                availableScreenQueue.append(destination)
            case .insert:
                // Here we insert screens, but
                // For example:
                // If the original is [A, B, C]
                // And then insert 2 screens herein
                // Result should be [1, 2, A, B, C]
                // So we can't just .insert 2 at 0
                let index = insertCounts[routerId] ?? 0
                availableScreenQueue.insert(destination, at: index)
                insertCounts[routerId] = index + 1
            case .insertAfter(id: let requestedId):
                if let requestedIsInQueueIndex = availableScreenQueue.firstIndex(where: { $0.id == requestedId }) {
                    let index = Int(requestedIsInQueueIndex) + 1 + (insertCounts[requestedId] ?? 0)
                    availableScreenQueue.insert(destination, at: index)
                    insertCounts[requestedId] = index + 1
                } else {
                    let index = insertCounts[routerId] ?? 0
                    availableScreenQueue.insert(destination, at: index)
                    insertCounts[routerId] = index + 1
                }
            }
        }
    }
    
    func removeScreensFromQueue(screenIds: [String]) {
        for screenId in screenIds {
            availableScreenQueue.removeAll(where: { $0.id == screenId })
        }
    }
    
    func clearScreenQueue() {
        availableScreenQueue.removeAll()
    }
    
    enum ScreenQueueError: Error {
        case noScreensInQueue
    }
    
    enum TransitionQueueError: Error {
        case noTransitionsInQueue
    }
    
    func showNextScreen(routerId: String) throws {
        guard let nextScreen = availableScreenQueue.first else {
            throw ScreenQueueError.noScreensInQueue
        }
        
        showScreen(routerId: routerId, destination: nextScreen)
        availableScreenQueue.removeFirst()
    }
    
    func showScreens(routerId: String, destinations: [AnyDestination]) {
        var routerIdUpdated = routerId
        
        Task {
            var lastSegue: SegueOption? = nil
            
            for destination in destinations {
                if lastSegue?.presentsNewEnvironment == true {
                    // If there is a .push after a new environment, the OS needs a slight delay before it will animate (idk why)
                    // Also if 2 new environments back to back
                    // But works without delay if there is no animation
                    if (destination.segue == .push || destination.segue.presentsNewEnvironment) && destination.animates  {
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
        allTransitions[destination.id] = [.root]
        
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
                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.append(destination)
                    }
                    return
                }
                
                // If there are existing screens and we find the requested screen
                if let index = existingScreens.firstIndex(where: { $0.id == routerId }) {
                    // If it is not last, insert
                    if existingScreens.indices.contains(index + 1) {
                        triggerAction(withAnimation: destination.animates) {
                            self.activeScreenStacks[appendingIndex].screens.insert(destination, at: index + 1)
                        }
                        return
                    } else {
                        triggerAction(withAnimation: destination.animates) {
                            self.activeScreenStacks[appendingIndex].screens.append(destination)
                        }
                        return
                    }
                }
                
                // Else, requested screen was the sheet or fullScreenCover before this stack (ie: index 0)
                triggerAction(withAnimation: destination.animates) {
                    self.activeScreenStacks[appendingIndex].screens.insert(destination, at: 0)
                }
            case .append:
                triggerAction(withAnimation: destination.animates) {
                    self.activeScreenStacks[appendingIndex].screens.append(destination)
                }
            case .insertAfter(let requestedRouterId):
                // If there are no screens yet, we can append
                if existingScreens.isEmpty {
                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.append(destination)
                    }
                    return
                }
                
                // If there are existing screens and we find the requested screen
                if let index = existingScreens.firstIndex(where: { $0.id == requestedRouterId }) {
                    // If it is not last, insert
                    if existingScreens.indices.contains(index + 1) {
                        triggerAction(withAnimation: destination.animates) {
                            self.activeScreenStacks[appendingIndex].screens.insert(destination, at: index + 1)
                        }
                        return
                    } else {
                        triggerAction(withAnimation: destination.animates) {
                            self.activeScreenStacks[appendingIndex].screens.append(destination)
                        }
                        return
                    }
                }
                
                // Else, requested screen was the sheet or fullScreenCover before this stack (ie: index 0)
                triggerAction(withAnimation: destination.animates) {
                    self.activeScreenStacks[appendingIndex].screens.insert(destination, at: 0)
                }
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
            
            triggerAction(withAnimation: destination.animates) {
                self.activeScreenStacks.insert(contentsOf: [newStack, blankStack], at: appendingIndex)
            }
        }
    }
    
    private func triggerAction(withAnimation: Bool, action: @escaping () -> Void) {
        if withAnimation {
            action()
        } else {
            var transaction = Transaction(animation: .none)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                action()
            }
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
    func dismissScreen(routeId: String, animates: Bool) {
        guard routeId != RouterViewModel.rootId else { return }
        
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
                triggerAction(withAnimation: animates) {
                    self.activeScreenStacks = keep
                }

                // Trigger screen onDismiss closures, if available
                for screen in screensToDismiss.reversed() {
                    screen.onDismiss?()
                }
                
                // Stop loop
                return
            }
        }
        
        print("🚨 RouteId not found in active view heirarchy (\(routeId))")
    }
    
    func dismissScreens(toEnvironmentId routeId: String, animates: Bool) {
        if let stackIndex = activeScreenStacks.firstIndex(where: { $0.screens.contains(where: { $0.id == routeId }) }) {
            if activeScreenStacks.indices.contains(stackIndex + 1) {
                let nextStack = activeScreenStacks[stackIndex + 1]
                if let lastScreen = nextStack.screens.last {
                    dismissScreens(to: lastScreen.id, animates: animates)
                    return
                }
            }
            
            if let lastScreen = activeScreenStacks[stackIndex].screens.last {
                dismissScreens(to: lastScreen.id, animates: animates)
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
    func dismissScreens(to routeId: String, animates: Bool) {
        // The parameter routeId should be the remaining screen after dismissing all screens in front of it
        // So we call dismissScreen(routeId:) with the next screen's routeId
        
//        print("TRIGGERING ON :\(routeId)")
//        print(activeScreenStacks)
        let allScreens = activeScreenStacks.flatMap({ $0.screens })
        if let screenIndex = allScreens.firstIndex(where: { $0.id == routeId }) {
            if allScreens.indices.contains(screenIndex + 1) {
                let nextRoute = allScreens[screenIndex + 1]
                dismissScreen(routeId: nextRoute.id, animates: animates)
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
    func dismissLastScreen(animates: Bool) {
        let allScreens = activeScreenStacks.flatMap({ $0.screens })
        if let lastScreen = allScreens.last {
            dismissScreen(routeId: lastScreen.id, animates: animates)
            return
        }
        
        print("🚨 There are no screens to dismiss in the active view heirarchy.")
    }
    
    /// Dismiss the last x screens presented.
    func dismissScreens(count: Int, animates: Bool) {
        let allScreensReversed = activeScreenStacks.flatMap({ $0.screens }).reversed()
        
        var counter: Int = 0
        for screen in allScreensReversed {
            counter += 1
            
            if counter == count || screen == allScreensReversed.last {
                dismissScreen(routeId: screen.id, animates: animates)
                return
            }
        }
        
        print("🚨 There are no screens to dismiss in the active view heirarchy.")
    }
    
    /// Dismiss the closest .sheet or .fullScreenCover below the routeId.
    func dismissEnvironment(routeId: String, animates: Bool) {
        var didFindScreen: Bool = false
        for stack in activeScreenStacks.reversed() {
            if stack.screens.contains(where: { $0.id == routeId }) {
                didFindScreen = true
            }
            
            if didFindScreen, stack.segue.presentsNewEnvironment, let route = stack.screens.first {
                dismissScreen(routeId: route.id, animates: animates)
                return
            }
        }
    }
    
    /// Dismiss the last .sheet or .fullScreenCover presented.
    func dismissLastEnvironment(animates: Bool) {
        let lastEnvironmentStack = activeScreenStacks.last(where: { $0.segue.presentsNewEnvironment })
        if let route = lastEnvironmentStack?.screens.first {
            dismissScreen(routeId: route.id, animates: animates)
            return
        }
        
        print("🚨 There is no dismissable environment in view heirarchy.")
    }
    
    /// Dismiss all .push routes on the current NavigationStack, up-to but not including any .sheet or .fullScreenCover.
    func dismissPushStack(routeId: String, animates: Bool) {
        for (stackIndex, stack) in activeScreenStacks.enumerated().reversed() {
            if stack.screens.contains(where: { $0.id == routeId }) {
                
                // If current stack is .push, dismiss to the first screen in this stack
                if stack.segue == .push, let route = stack.screens.first {
                    dismissScreen(routeId: route.id, animates: animates)
                    return
                }
                
                // If current stack is .sheet or .fullScreenCover, then the .push stack should be the following stack
                if stack.segue.presentsNewEnvironment {
                    if activeScreenStacks.indices.contains(stackIndex + 1) {
                        let nextStack = activeScreenStacks[stackIndex + 1]
                        if nextStack.segue == .push, let route = nextStack.screens.first {
                            dismissScreen(routeId: route.id, animates: animates)
                            return
                        }
                    }
                }
            }
        }
    }
    
    /// Dismiss all .push routes on the last NavigationStack, up-to but not including any .sheet or .fullScreenCover.
    func dismissLastPushStack(animates: Bool) {
        let lastPushStack = activeScreenStacks.last(where: { $0.segue == .push })
        if let route = lastPushStack?.screens.first {
            dismissScreen(routeId: route.id, animates: animates)
            return
        }
        
        print("🚨 There is no dismissable push stack in view heirarchy.")
    }
    
    /// Dismiss all screens back to root.
    func dismissAllScreens(animates: Bool) {
        dismissScreens(to: RouterViewModel.rootId, animates: animates)
    }

    func showAlert(routerId: String, alert: AnyAlert) {
        var routerId = routerId
        if alert.location == .topScreen {
            if let lastScreen = activeScreenStacks.flatMap({ $0.screens }).last {
                routerId = lastScreen.id
            }
        }
        
        if activeAlert[routerId] == nil {
            self.activeAlert[routerId] = alert
        } else {
            self.activeAlert.removeValue(forKey: routerId)
            
            Task {
                try? await Task.sleep(for: .seconds(0.1))
                self.activeAlert[routerId] = alert
            }
        }
    }
    
    func dismissAlert(routerId: String) {
        self.activeAlert.removeValue(forKey: routerId)
    }
    
    func showModal(routerId: String, modal: AnyModal) {
        if allModals[routerId] == nil {
            allModals[routerId] = []
        }
        
        allModals[routerId]!.append(modal)
    }
    
    func dismissLastModal(onRouterId routerId: String) {
        let allModals = (allModals[routerId] ?? []).filter({ !$0.isRemoved })
        if let lastModal = allModals.last {
            dismissModal(routerId: routerId, modalId: lastModal.id)
            return
        }
        
        print("🚨 1 There are no modals to dismiss in the active view heirarchy.")
    }
    
    func dismissModal(routerId: String, modalId: String) {
        if let index = allModals[routerId]?.lastIndex(where: { $0.id == modalId && !$0.isRemoved }) {
            // Trigger onDismiss for the modal
            allModals[routerId]?[index].onDismiss?()
            
            // Dismiss the modal UI
            allModals[routerId]?[index].convertToEmptyRemovedModal()
//            allModals[routerId]?.remove(at: index)
            return
        }
        
        print("🚨 Modal to dismiss not found.")
    }
    
    func dismissModals(routerId: String, to modalId: String) {
        // The parameter modalId should be the remaining modal after dismissing all modals in front of it
        // So we call dismissModal(modalId:) with the next screen's routeId

        let allModals = allModals[routerId] ?? []
        if let modalIndex = allModals.lastIndex(where: { $0.id == modalId }) {
            // get all modals AFTER modalIndex
            let modalsToDismiss = allModals[(modalIndex + 1)...]
            for modal in modalsToDismiss.reversed() {
                if !modal.isRemoved {
                    dismissModal(routerId: routerId, modalId: modal.id)
                }
            }
        }
    }
    
    func dismissModals(routerId: String, count: Int) {
        let allModalsReversed = (allModals[routerId] ?? []).reversed()
        
        var counter: Int = 0
        for modal in allModalsReversed {
            if !modal.isRemoved {
                counter += 1
                dismissModal(routerId: routerId, modalId: modal.id)
            }

            if counter == count {
                return
            }
        }
    }
    
    func dismissAllModals(routerId: String) {
        let allModalsReversed = (allModals[routerId] ?? []).reversed()
        
        for modal in allModalsReversed {
            if !modal.isRemoved {
                dismissModal(routerId: routerId, modalId: modal.id)
            }
        }
    }
    
    func showTransition(routerId: String, transition: AnyTransitionDestination) {
        self.currentTransitions[routerId] = transition.transition
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000)
            
            // allTransitions[routerId] should never be nil
            // since it's added in showScreen
            self.allTransitions[routerId]?.append(transition)
        }
    }
    
    func showTransitions(routerId: String, transitions: [AnyTransitionDestination]) {
        guard let lastTransition = transitions.last?.transition else { return }
        
        self.currentTransitions[routerId] = lastTransition
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000)
            
            // allTransitions[routerId] should never be nil
            // since it's added in showScreen
            self.allTransitions[routerId]?.append(contentsOf: transitions)
        }
    }
    
    func dismissTransition(routerId: String) throws {
        let transitions = allTransitions[routerId] ?? []
        
        guard let index = transitions.indices.last, transitions.indices.contains(index - 1) else {
            // no transition to dismiss
            return
        }
        
        // Set current transition
        self.currentTransitions[routerId] = transitions[index].transition.reversed
        
        // Task is needed for UI
        Task { @MainActor in
            // Trigger onDismiss for screen
            defer {
                transitions[index].onDismiss?()
            }
            
            // Trigger UI update
            self.allTransitions[routerId]?.remove(at: index)
        }
    }
    
    func dismissTransitions(routerId: String, id: String) {
        // Dismiss to the screen before id
        guard
            let transitions = allTransitions[routerId],
            let requestedIndex = transitions.firstIndex(where: {  $0.id == id }) else {
            return
        }
        
        var resultingScreenId = RouterViewModel.rootId
        if transitions.indices.contains(requestedIndex - 1) {
            resultingScreenId = transitions[requestedIndex - 1].id
        }
        
        dismissTransitions(routerId: routerId, toScreenId: resultingScreenId)
    }
    
    func dismissTransitions(routerId: String, toScreenId: String) {
        let transitions = allTransitions[routerId] ?? []
        
        guard let lastIndex = transitions.indices.last, transitions.indices.contains(lastIndex - 1) else {
            print("no transition to dismiss")
            return
        }
        
        guard let screenIndex = transitions.firstIndex(where: { $0.id == toScreenId }) else {
            print("Could not find screen in transitions")
            return
        }
        
        let screensToDismissStartingIndex = (screenIndex + 1)
        let screensToDismiss = Array(transitions[screensToDismissStartingIndex...])

        guard !screensToDismiss.isEmpty else {
            print("No screens to dismiss")
            return
        }
        
        // Set current transition
        self.currentTransitions[routerId] = transitions[lastIndex].transition.reversed
        
        // Task is needed for UI
        Task { @MainActor in
            defer {
                for screen in screensToDismiss.reversed() {
                    // Trigger onDismiss for screens
                    screen.onDismiss?()
                }
            }
            
            // Trigger UI update
            self.allTransitions[routerId]?.removeSubrange(screensToDismissStartingIndex...)
        }
    }
    
    func dismissTransitions(routerId: String, count: Int) {
        let transitions = allTransitions[routerId] ?? []
        
        guard let lastIndex = transitions.indices.last, transitions.indices.contains(lastIndex - 1) else {
            print("no transition to dismiss")
            return
        }
        
        var counter: Int = 0
        var screensToDismissStartingIndex: Int? = nil
        for (index, _) in transitions.enumerated().reversed() {
            if counter == count {
                break
            }
            
            counter += 1
            screensToDismissStartingIndex = index
        }
        
        guard var screensToDismissStartingIndex else {
            print("Count not find screens to dismiss to count")
            return
        }
        
        // Never dismiss root
        screensToDismissStartingIndex = max(1, screensToDismissStartingIndex)
        
        let screensToDismiss = Array(transitions[screensToDismissStartingIndex...])

        guard !screensToDismiss.isEmpty else {
            print("No screens to dismiss")
            return
        }
        
        // Set current transition
        self.currentTransitions[routerId] = transitions[lastIndex].transition.reversed
        
        // Task is needed for UI
        Task { @MainActor in
            defer {
                for screen in screensToDismiss.reversed() {
                    // Trigger onDismiss for screens
                    screen.onDismiss?()
                }
            }
            
            // Trigger UI update
            self.allTransitions[routerId]?.removeSubrange(screensToDismissStartingIndex...)
        }
    }
    
    func dismissAllTransitions(routerId: String) {
        let transitions = allTransitions[routerId] ?? []
        
        guard let lastIndex = transitions.indices.last, transitions.indices.contains(lastIndex - 1) else {
            print("no transition to dismiss")
            return
        }
                
        let screensToDismissStartingIndex = 1
        let screensToDismiss = Array(transitions[screensToDismissStartingIndex...])

        guard !screensToDismiss.isEmpty else {
            print("No screens to dismiss")
            return
        }
        
        // Set current transition
        self.currentTransitions[routerId] = transitions[lastIndex].transition.reversed
        
        // Task is needed for UI
        Task { @MainActor in
            defer {
                for screen in screensToDismiss.reversed() {
                    // Trigger onDismiss for screens
                    screen.onDismiss?()
                }
            }
            
            // Trigger UI update
            self.allTransitions[routerId]?.removeSubrange(screensToDismissStartingIndex...)
        }
    }
    
    func addTransitionsToQueue(routerId: String, transitions: [AnyTransitionDestination]) {
        if availableTransitionQueue[routerId] == nil {
            availableTransitionQueue[routerId] = []
        }
        
        availableTransitionQueue[routerId]?.append(contentsOf: transitions)
    }
    
    func removeTransitionsFromQueue(routerId: String, transitionIds: [String]) {
        for transitionId in transitionIds {
            availableTransitionQueue[routerId]?.removeAll(where: { $0.id == transitionId })
        }
    }
    
    func clearTransitionsQueue(routerId: String) {
        availableTransitionQueue[routerId]?.removeAll()
    }
    
    func showNextTransition(routerId: String) throws {
        guard let nextTransition = availableTransitionQueue[routerId]?.first else {
            throw TransitionQueueError.noTransitionsInQueue
        }
        
        showTransition(routerId: routerId, transition: nextTransition)
        availableTransitionQueue[routerId]?.removeFirst()
    }
}

@MainActor
struct RouterViewInternal<Content: View>: View, Router {
    
    @Environment(RouterViewModel.self) var viewModel
    var routerId: String
    var addNavigationStack: Bool = false
    var logger: Bool = false
    var content: (AnyRouter) -> Content

    private var currentRouter: AnyRouter {
        AnyRouter(object: self)
    }
    
    private var parentDestination: AnyDestination? {
        guard let index = viewModel.activeScreenStacks.lastIndex(where: { stack in
            return stack.screens.contains(where: { $0.id == routerId })
        }) else {
            return nil
        }
        
        return viewModel.activeScreenStacks[index].screens.first(where: { $0.id == routerId })
    }

    var body: some View {
        // Wrap starting content for Transition support
        TransitionSupportView2(
            behavior: parentDestination?.transitionBehavior ?? .keepPrevious,
            router: currentRouter,
            transitions: viewModel.allTransitions[routerId] ?? [],
            content: content,
            currentTransition: viewModel.currentTransitions[routerId] ?? .trailing,
            onDidSwipeBack: {
                try? dismissTransition()
            }
        )
        // Add NavigationStack if needed
        .ifSatisfiesCondition(addNavigationStack, transform: { content in
            NavigationStack(path: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, onDidDismiss: { lastRouteRemaining in
                if let lastRouteRemaining {
                    viewModel.dismissScreens(to: lastRouteRemaining.id, animates: true)
                } else {
                    viewModel.dismissPushStack(routeId: routerId, animates: true)
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
                .sheet(item: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, segue: .sheet(), onDidDismiss: {
                    // This triggers if the user swipes down to dismiss the screen
                    // Now we must update activeScreenStacks to match that behavior
                    viewModel.dismissScreens(toEnvironmentId: routerId, animates: true)
                }), onDismiss: nil) { destination in
                    destination.destination
                        .applyResizableSheetModifiersIfNeeded(segue: destination.segue)
                }
        )
        
        // Add FullScreenCover modifier. Add on background to supress OS warnings.
        .background(
            Text("")
                .fullScreenCover(item: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, segue: .fullScreenCover(), onDidDismiss: {
                    // This triggers if the user swipes down to dismiss the screen
                    // Now we must update activeScreenStacks to match that behavior
                    viewModel.dismissScreens(toEnvironmentId: routerId, animates: true)
                }), onDismiss: nil) { destination in
                    destination.destination
                        .applyResizableSheetModifiersIfNeeded(segue: destination.segue)
                }
        )
        
        // If this is the root router, add "root" stack to the array
        .ifSatisfiesCondition(routerId == RouterViewModel.rootId, transform: { content in
            content
                .onFirstAppear {
                    let view = AnyDestination(id: routerId, segue: .fullScreenCover(), location: .insert, onDismiss: nil, destination: { _ in self })
                    viewModel.insertRootView(view: view)
                }
        })
        
        // Add Alert modifier.
        .modifier(AlertViewModifier(alert: Binding(get: {
            viewModel.activeAlert[routerId]
        }, set: { newValue in
            if newValue == nil {
                viewModel.dismissAlert(routerId: routerId)
            }
        })))
        
        // Add Modals modifier.
        .overlay(
            ModalSupportView(
                modals: viewModel.allModals[routerId] ?? [],
                onDismissModal: { modal in
                    viewModel.dismissModal(routerId: routerId, modalId: modal.id)
                }
            )
        )
        
        // Print screen stack if logging is enabled
        .ifSatisfiesCondition(logger && routerId == RouterViewModel.rootId, transform: { content in
            content
                .onChange(of: viewModel.activeScreenStacks) { oldValue, newValue in
                    printScreenStack(screenStack: newValue, screenQueue: nil)
                }
                .onChange(of: viewModel.availableScreenQueue) { oldValue, newValue in
                    printScreenStack(screenStack: nil, screenQueue: newValue)
                }
                .onChange(of: viewModel.allModals[routerId] ?? []) { oldValue, newValue in
                    printModalStack(modals: newValue)
                }
        })
        
        // Add to environment for convenience
        .environment(\.router, currentRouter)
    }
    
    private func printModalStack(modals: [AnyModal]) {
        if !modals.isEmpty {
            print("🕊️ SwiftfulRouting Modal Stack 🕊️")

            for modal in modals {
                print("modal \(modal.id)")
            }
            
            print("\n")
        }
    }
    
    private func printScreenStack(screenStack: [AnyDestinationStack]?, screenQueue: [AnyDestination]?) {
        print("🕊️ SwiftfulRouting Screen Stacks 🕊️")
        
        // For each AnyDestinationStack
        let screenStack = screenStack ?? viewModel.activeScreenStacks
        for (arrayIndex, item) in screenStack.enumerated() {
            print("stack \(arrayIndex): \(item.segue.stringValue)")
            
            if item.screens.isEmpty {
                print("    no screens")
            } else {
                for (screenIndex, screen) in item.screens.enumerated() {
                    print("    screen \(screenIndex): \(screen.id)")
                }
            }
        }
        print("\n")

        let screenQueue = screenQueue ?? viewModel.availableScreenQueue
        if !screenQueue.isEmpty {
            print("🪺 SwiftfulRouting Screen Queue 🪺")

            if screenQueue.isEmpty {
                print("    no queue")
            } else {
                for (arrayIndex, item) in screenQueue.enumerated() {
                    print("queue \(arrayIndex): \(item.id)")
                }
            }
            print("\n")
        }
    }
    
    func showScreens(destinations: [AnyDestination]) {
        viewModel.showScreens(routerId: routerId, destinations: destinations)
    }
    
    func showScreen(destination: AnyDestination) {
        viewModel.showScreens(routerId: routerId, destinations: [destination])
    }
    
    func dismissScreen(animates: Bool) {
        viewModel.dismissScreen(routeId: routerId, animates: animates)
    }
    
    func dismissScreen(id: String, animates: Bool) {
        viewModel.dismissScreen(routeId: id, animates: animates)
    }
    
    func dismissScreens(upToScreenId: String, animates: Bool) {
        viewModel.dismissScreens(to: upToScreenId, animates: animates)
    }
    
    func dismissScreens(count: Int, animates: Bool) {
        viewModel.dismissScreens(count: count, animates: animates)
    }
    
    func dismissLastScreen(animates: Bool) {
        viewModel.dismissLastScreen(animates: animates)
    }
    
    func dismissEnvironment(animates: Bool) {
        viewModel.dismissEnvironment(routeId: routerId, animates: animates)
    }
        
    func dismissLastEnvironment(animates: Bool) {
        viewModel.dismissLastEnvironment(animates: animates)
    }
    
    func dismissLastPushStack(animates: Bool) {
        viewModel.dismissLastPushStack(animates: animates)
    }
    
    func dismissPushStack(animates: Bool) {
        viewModel.dismissPushStack(routeId: routerId, animates: animates)
    }
    
    func dismissAllScreens(animates: Bool) {
        viewModel.dismissAllScreens(animates: animates)
    }
    
    func addScreensToQueue(destinations: [AnyDestination]) {
        viewModel.addScreensToQueue(routerId: routerId, destinations: destinations)
    }
    
    func removeScreensFromQueue(ids: [String]) {
        viewModel.removeScreensFromQueue(screenIds: ids)
    }
    
    func clearScreenQueue() {
        viewModel.clearScreenQueue()
    }
    
    func showNextScreen() throws {
        try viewModel.showNextScreen(routerId: routerId)
    }
    
    func showAlert(alert: AnyAlert) {
        viewModel.showAlert(routerId: routerId, alert: alert)
    }
    
    func dismissAlert() {
        viewModel.dismissAlert(routerId: routerId)
    }
    
    func showModal(modal: AnyModal) {
        viewModel.showModal(routerId: routerId, modal: modal)
    }
    
    func dismissModal() {
        viewModel.dismissLastModal(onRouterId: routerId)
    }
    
    func dismissModal(id: String) {
        viewModel.dismissModal(routerId: routerId, modalId: id)
    }
    
    func dismissModals(upToModalId: String) {
        viewModel.dismissModals(routerId: routerId, to: upToModalId)
    }
    
    func dismissModals(count: Int) {
        viewModel.dismissModals(routerId: routerId, count: count)
    }
    
    func dismissAllModals() {
        viewModel.dismissAllModals(routerId: routerId)
    }
    
    func showTransition(transition: AnyTransitionDestination) {
        viewModel.showTransition(routerId: routerId, transition: transition)
    }
    
    func showTransitions(transitions: [AnyTransitionDestination]) {
        viewModel.showTransitions(routerId: routerId, transitions: transitions)
    }
    
    func dismissTransition() throws {
        try viewModel.dismissTransition(routerId: routerId)
    }
    
    func dismissTransition(id: String) {
        viewModel.dismissTransitions(routerId: routerId, id: id)
    }
    
    func dismissTransitions(upToScreenId: String) {
        viewModel.dismissTransitions(routerId: routerId, toScreenId: upToScreenId)
    }
    
    func dismissTransitions(count: Int) {
        viewModel.dismissTransitions(routerId: routerId, count: count)
    }
    
    func dismissAllTransitions() {
        viewModel.dismissAllTransitions(routerId: routerId)
    }
    
    func addTransitionsToQueue(transitions: [AnyTransitionDestination]) {
        viewModel.addTransitionsToQueue(routerId: routerId, transitions: transitions)
    }
    
    func removeTransitionsFromQueue(ids: [String]) {
        viewModel.removeTransitionsFromQueue(routerId: routerId, transitionIds: ids)
    }
    
    func clearTransitionsQueue() {
        viewModel.clearTransitionsQueue(routerId: routerId)
    }
    
    func showNextTransition() throws {
        try viewModel.showNextTransition(routerId: routerId)
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
 - location .insertAfter(x) - DONE
 - dismiss or segue with no animation? - DONE

 - finish tests for queue! - DONE
 
 - addToQueue(destination, location: insert) - DONE
 - addToQueue(destination, location: append) - DONE
 - addToQueue(destinations, location: insert) - DONE
 - nextScreen - DONE
 
 - if no animations, need delay on multi segues?? - DONE
  
 - navigationTransition - HOLD
 - Resizable sheet - DONE
 - navigationTransition example code - DONE
 
 - dismiss style (.single, .waterfall) - HOLD?

 - duplicate screen ids? warning? - HOLD
 - Kavsoft's floating UI no background? - DONE
 - Testing - DONE
    - check normals - DONE
    - color - DONE
    - clear - DONE
    - corner radius - DONE
    - full screen - DONE
 
 - tests - DONE
 - alerts - DONE
    - textfield - DONE
 - modals - DONE
 - modal dismisses - DONE
 - modal tests - DONE
 - modal blur - DONE
 - blurs - DONE
 
 - transitions -
    - transition trailing - DONE
    - transition top - DONE
    - showTransitions - DONE
    - no animation (identity) - DONE
    - transition queue - DONE
    
    - inject behavior - DONE
    - all transitions working one - DONE
    - all transitions working multi - DONE
    - scale - HOLD
    - fade - HOLD
    - opacity - HOLD
    - custom animation values? - HOLD
    - configure swipe gestures - DONE
        - .leading(allowSwipeBack: Bool) - NO
    - transition tests - DONE

 
 
 - modules
    - 
 
 - clean code
 - observable?
 - iOS 15?
 - add to starter project for checks
    - Multiple routers should handle same as multiple modals? -
 - tabbars
    - on selection
 
 - cookbook view
 - clean up example project UI
 
 - preloaded transitions - HOLD

 */



//

struct RoutingTest: View {
    var body: some View {
        RouterView(logger: true) { router in
            Button("Click me 1") {
                
                let destination = AnyDestination(
//                    id: T##String,
                    segue: .sheet(),
//                    location: T##SegueLocation,
//                    animates: T##Bool,
//                    onDismiss: T##(() -> Void)?##(() -> Void)?##() -> Void,
                    destination: { router in
                        Color.red.ignoresSafeArea()
                    }
                )
                
                router.showScreen(destination)
                
//                var firstRouter: AnyRouter? = nil
//                let screen1 = AnyDestination(id: "screen_1", segue: .push, destination: { router in
//                    firstRouter = router
//                    return Color.red.ignoresSafeArea()
//                })
//
//                let screen2 = AnyDestination(id: "screen_2", segue: .sheet, destination: { router in
//                    Color.blue.ignoresSafeArea()
//                        .onTapGesture {
//                            firstRouter?.showScreen(id: "adsf", segue: .push, location: .insert, destination: { _ in
//                                Color.orange.ignoresSafeArea()
//                                    .onTapGesture {
//                                        router.dismissLastScreen()
//                                    }
//                            })
//                        }
//                })
                
//                let screen3 = AnyDestination(id: "screen_3", segue: .fullScreenCover, { router in
//                    Color.orange.ignoresSafeArea()
//                }, onDismiss: nil)
//                
//                let screen4 = AnyDestination(id: "screen_4", segue: .push, { router in
//                    Color.pink.ignoresSafeArea()
//                }, onDismiss: nil)


//                router.showScreens(destinations: [screen1, screen2]) // screen3, screen4
                
                
                
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

import Foundation

extension Set {
    func setMap<U>(_ transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.lazy.map(transform))
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

            if let nextSegue = nextSheetStack?.segue, nextSegue == segue, let screen = nextSheetStack?.screens.first {
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

extension Binding where Value == Bool {
    
    init(ifAlert alert: Binding<AnyAlert?>, isStyle style: AlertStyle) {
        self.init(get: {
            if let alertStyle = alert.wrappedValue?.style, alertStyle == style {
                return true
            }
            return false
        }, set: { newValue in
            if newValue == false {
                alert.wrappedValue = nil
            }
        })
    }
}

extension Binding where Value == PresentationDetent {
    
    init(selection: Binding<PresentationDetentTransformable>) {
        self.init {
            selection.wrappedValue.asPresentationDetent
        } set: { newValue in
            selection.wrappedValue = PresentationDetentTransformable(detent: newValue)
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
//
//struct AlertViewModifier: ViewModifier {
//    
//    let alert: Binding<AnyAlert?>
//
//    func body(content: Content) -> some View {
//        let value = alert.wrappedValue
//        
//        return content
//            .alert(value?.title ?? "", isPresented: Binding(ifNotNil: Binding(if: option, is: .alert, value: item))) {
//                item.wrappedValue?.buttons
//            } message: {
//                if let subtitle = item.wrappedValue?.subtitle {
//                    Text(subtitle)
//                }
//            }
//    }
//}

import Foundation
import SwiftUI

struct AlertViewModifier: ViewModifier {
    
    let alert: Binding<AnyAlert?>

    func body(content: Content) -> some View {
        content
            .alert(
                alert.wrappedValue?.title ?? "",
                isPresented: Binding(ifAlert: alert, isStyle: .alert),
                actions: {
                    alert.wrappedValue?.buttons
                },
                message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
            )
            .confirmationDialog(
                alert.wrappedValue?.title ?? "",
                isPresented: Binding(ifAlert: alert, isStyle: .confirmationDialog),
                titleVisibility: alert.wrappedValue?.title.isEmpty ?? true ? .hidden : .visible,
                actions: {
                    alert.wrappedValue?.buttons
                },
                message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
            )
    }
}

