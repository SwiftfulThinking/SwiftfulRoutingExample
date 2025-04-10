//
//  RouterViewModel.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/9/25.
//
import SwiftUI

@MainActor
final class RouterViewModel: ObservableObject {
    static let rootId = "root"
    
    // Active screen stack heirarchy. See AnyDestinationStack.swift for documentation.
    @Published private(set) var activeScreenStacks: [AnyDestinationStack] = [AnyDestinationStack(segue: .fullScreenCover, screens: [])]
    
    // Available screens in queue, accessible via .showNextScreen()
    @Published private(set) var availableScreenQueue: [AnyDestination] = []
    
    // Active alerts for all child screens. Each screen can have only one active alert.
    // [routerId : Alert]
    @Published private(set) var activeAlert: [String: AnyAlert] = [:]
    
    // All modals for all child screens. Each screen can have multiple modals simultaneously.
    // Modals remain in the array even after beign dismissed (ie modal.isRemoved = true)
    // [routerId : [Modals]]
    @Published private(set) var allModals: [String: [AnyModal]] = [:]
    
    // All transitions for all child screens. Each screen can have multiple transitions.
    // Transitions are removed from the array when dismissed.
    // [routerId : [Transitions]]
    @Published private(set)var allTransitions: [String: [AnyTransitionDestination]] = [RouterViewModel.rootId: [.root]]
    
    // The current TransitionOption on each screen.
    // While a transition is rendered, its .transition may change based on the next/previous transition.
    @Published private(set)var currentTransitions: [String: TransitionOption] = [RouterViewModel.rootId: .trailing]
    
    // Available transitions in queue, accessible via .showNextTransition()
    @Published private(set)var availableTransitionQueue: [String: [AnyTransitionDestination]] = [:]
    
    // Only called once onFirstAppear in the root router.
    // This replaces starting activeScreenStacks value.
    // It MUST be called after the screen appears, since it is adding the View itself to the array.
    func insertRootView(view: AnyDestination) {
        activeScreenStacks.insert(AnyDestinationStack(segue: .fullScreenCover, screens: [view]), at: 0)
    }
    
}

// MARK: EVENTS

extension RouterViewModel {
    
    enum Event: RoutingLogEvent {
        case routerIdNotFound(id: String)
        
        var eventName: String {
            switch self {
            case .routerIdNotFound:             return "Routing_RouterIdNotFound"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .routerIdNotFound(id: let id):
                return [
                    "router_id": id
                ]
//            default:
//                return nil
            }
        }
        
        var type: RoutingLogType {
            switch self {
            case .routerIdNotFound:
                return .warning
            }
        }
    }

}

// MARK: SEGUE METHODS

extension RouterViewModel {
    
    private func showScreen(routerId: String, destination: AnyDestination) {
        
        // 1. Get the index within the activeScreenStacks that we will edit
        let stackIndex: Int
        switch destination.location {
        case .insert:
            guard let index = activeScreenStacks.lastIndexWhereChildStackContains(routerId: routerId) else {
                logger.trackEvent(event: Event.routerIdNotFound(id: routerId))
                return
            }

            stackIndex = index
        case .insertAfter(id: let requestedRouterId):
            guard let index = activeScreenStacks.lastIndexWhereChildStackContains(routerId: requestedRouterId) else {
                logger.trackEvent(event: Event.routerIdNotFound(id: requestedRouterId))
                return
            }

            stackIndex = index
        case .append:
            guard let index = activeScreenStacks.indices.last else {
                logger.trackEvent(event: Event.routerIdNotFound(id: "last_id"))
                return
            }
            
            stackIndex = index
        }
        
        // The stack we will edit
        let currentStack = activeScreenStacks[stackIndex]
        
        // Every new screen has a new transition array.
        // We append .root to account for the first screen that will already exist as
        // the screen renders for the first time (ie. the destination).
        allTransitions[destination.id] = [.root]
        
        
        // We have to append the destination differently depending on the segue
        // For more details, see AnyDestinationStack.swift for documentation.
        
        switch destination.segue {
        case .push:
            // If pushing to the next screen...
            //  If currentStack is already a .push stack, then append to it
            //  Otherwise, currentStack is therefore a sheet/fullScreenCover and the associated push stack should be (index + 1)

            // The index where we will attempt to add the new screen
            let appendingIndex: Int = currentStack.segue == .push ? (stackIndex) : (stackIndex + 1)
            
            // Existing screens in this stack (may be empty)
            let existingScreens = activeScreenStacks[appendingIndex].screens
            
            // In addition to the segue type, the developer can customize the insertion location
            // Depending on the location, we alter where exactly we insert
            // The appendingIndex is our anchor but may not be the final index.
            
            func insertPushScreenIntoExistingArray(requestedRouterId: String) {
                // If there are no screens yet, append at the default location.
                guard !existingScreens.isEmpty else {
                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.append(destination)
                    }
                    return
                }
                
                // Get the screen index of the current router, so that we can insert after it
                guard let index = existingScreens.firstIndex(where: { $0.id == requestedRouterId }) else {
                    // However, if the index does not exist, then we can assume the requested screen
                    // was the .sheet or .fullScreenCover before this stack
                    // Therefore the next screen above the requested screen in the push stack at index 0

                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.insert(destination, at: 0)
                    }
                    return
                }
                
                
                // If the screenIndex is not last, we can use the insert method
                if existingScreens.indices.contains(index + 1) {
                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.insert(destination, at: index + 1)
                    }
                    return
                    
                // If the screenIndex is last, we can use the append method
                } else {
                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.append(destination)
                    }
                    return
                }
            }

            
            switch destination.location {
            case .insert:
                // Insert the screen into the array based on the routerId
                insertPushScreenIntoExistingArray(requestedRouterId: routerId)
                
            case .insertAfter(let requestedRouterId):
                // Insert the screen into the array based on the requestedRouterId
                // Note: Same as .insert case, except using requestedRouterId instead of routerId
                insertPushScreenIntoExistingArray(requestedRouterId: requestedRouterId)

            case .append:
                // If user selects append, we add to the end of the push stack,
                // regardless of where it has been called from!

                triggerAction(withAnimation: destination.animates) {
                    self.activeScreenStacks[appendingIndex].screens.append(destination)
                }
            }
        case .sheetConfig, .fullScreenCoverConfig:
            // If showing sheet or fullScreenCover...
            //  If currentStack is a .push stack, then add a new stack for the environment next (index + 1)
            //  If currentStack is .sheet or .fullScreenCover stack, then the next stack is already a .push, and we add newStack after that (index + 2)
            //
            // When appending a new sheet or fullScreenCover, always append a following .push stack for the new NavigationStack on that environment to bind to
            //
            
            let newStack = AnyDestinationStack(segue: destination.segue, screens: [destination])
            let blankStack = AnyDestinationStack(segue: .push, screens: [])
            let appendingIndex: Int = currentStack.segue == .push ? (stackIndex + 1) : (stackIndex + 2)
            
            triggerAction(withAnimation: destination.animates) {
                self.activeScreenStacks.insert(contentsOf: [newStack, blankStack], at: appendingIndex)
            }
        }
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

    
}



extension RouterViewModel {
    
    
    
    
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
