//
//  RoutingTest.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/19/25.
//

import SwiftUI

protocol Router: Sendable {
    
    @MainActor var activeScreens: [AnyDestinationStack] { get }
    @MainActor var activeScreenQueue: [AnyDestination] { get }
    @MainActor var activeAlert: AnyAlert? { get }
    @MainActor var activeModals: [AnyModal] { get }
    @MainActor var activeTransitions: [AnyTransitionDestination] { get }
    @MainActor var activeTransitionQueue: [AnyTransitionDestination] { get }
    
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
    @MainActor func removeAllScreensFromQueue()
    @MainActor func showNextScreen()
    
    @MainActor func showAlert(alert: AnyAlert)
    @MainActor func dismissAlert()
    @MainActor func dismissAllAlerts()

    @MainActor func showModal(modal: AnyModal)
    @MainActor func dismissModal()
    @MainActor func dismissModal(id: String)
    @MainActor func dismissModals(upToModalId: String)
    @MainActor func dismissModals(count: Int)
    @MainActor func dismissAllModals()
    
    @MainActor func showTransition(transition: AnyTransitionDestination)
    @MainActor func showTransitions(transitions: [AnyTransitionDestination])
    @MainActor func dismissTransition()
    @MainActor func dismissTransition(id: String)
    @MainActor func dismissTransitions(upToId: String)
    @MainActor func dismissTransitions(count: Int)
    @MainActor func dismissAllTransitions()
    
    @MainActor func addTransitionsToQueue(transitions: [AnyTransitionDestination])
    @MainActor func removeTransitionsFromQueue(ids: [String])
    @MainActor func removeAllTransitionsFromQueue()
    @MainActor func showNextTransition()
}

@MainActor
struct RouterViewInternal<Content: View>: View, Router {
    
    @EnvironmentObject var viewModel: RouterViewModel
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
                .sheet(item: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, segue: .sheet, onDidDismiss: {
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
                .fullScreenCover(item: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, segue: .fullScreenCover, onDidDismiss: {
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
                    let view = AnyDestination(id: routerId, segue: .fullScreenCover, location: .insert, onDismiss: nil, destination: { _ in self })
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
                .onChange(of: viewModel.activeScreenStacks) { newValue in
                    printScreenStack(screenStack: newValue, screenQueue: nil)
                }
                .onChange(of: viewModel.availableScreenQueue) { newValue in
                    printScreenStack(screenStack: nil, screenQueue: newValue)
                }
                .onChange(of: viewModel.allModals[routerId] ?? []) { newValue in
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
    
    var activeScreens: [AnyDestinationStack] {
        viewModel.activeScreenStacks
    }
    
    var activeScreenQueue: [AnyDestination] {
        viewModel.availableScreenQueue
    }
    
    var activeAlert: AnyAlert? {
        viewModel.activeAlert[routerId]
    }
    
    var activeModals: [AnyModal] {
        viewModel.allModals[routerId]?.filter({ !$0.isRemoved }) ?? []
    }
    
    var activeTransitions: [AnyTransitionDestination] {
        viewModel.allTransitions[routerId] ?? []
    }
    
    var activeTransitionQueue: [AnyTransitionDestination] {
        viewModel.availableTransitionQueue[routerId] ?? []
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
    
    func removeAllScreensFromQueue() {
        viewModel.removeAllScreensFromQueue()
    }
    
    func showNextScreen() {
        viewModel.showNextScreen(routerId: routerId)
    }
    
    func showAlert(alert: AnyAlert) {
        viewModel.showAlert(routerId: routerId, alert: alert)
    }
    
    func dismissAlert() {
        viewModel.dismissAlert(routerId: routerId)
    }
    
    func dismissAllAlerts() {
        viewModel.dismissAllAlerts()
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
    
    func dismissTransition() {
        viewModel.dismissTransition(routerId: routerId)
    }
    
    func dismissTransition(id: String) {
        viewModel.dismissTransitions(routerId: routerId, transitionId: id)
    }
    
    func dismissTransitions(upToId id: String) {
        viewModel.dismissTransitions(routerId: routerId, toTransitionId: id)
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
    
    func removeAllTransitionsFromQueue() {
        viewModel.removeAllTransitionsFromQueue(routerId: routerId)
    }
    
    func showNextTransition() {
        viewModel.showNextTransition(routerId: routerId)
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
                    segue: .sheet,
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

