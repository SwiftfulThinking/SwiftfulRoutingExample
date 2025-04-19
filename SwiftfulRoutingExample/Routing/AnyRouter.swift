//
//  AnyRouter.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

struct RouterEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyRouter = AnyRouter(object: MockRouter())
}

extension EnvironmentValues {
    var router: AnyRouter {
        get { self[RouterEnvironmentKey.self] }
        set { self[RouterEnvironmentKey.self] = newValue }
    }
}

/// Type-erased Router with convenience methods.
struct AnyRouter: Sendable, Router {
    private let object: any Router

    init(object: any Router) {
        self.object = object
    }
    
    /// Active screen stacks in this RouterView's heirarchy.
    ///
    /// Use activeScreens.allScreens for underlying screen array.
    @MainActor var activeScreens: [AnyDestinationStack] {
        object.activeScreens
    }
    
    /// Available screens in this RouterView's screen queue.
    ///
    /// Use showNextScreen() to trigger the next screen.
    @MainActor var activeScreenQueue: [AnyDestination] {
        object.activeScreenQueue
    }
    
    /// If there is at least 1 screen in activeScreenQueue.
    @MainActor var hasScreenInQueue: Bool {
        !object.activeScreenQueue.isEmpty
    }
    
    /// The currently displayed alert on this screen.
    @MainActor var activeAlert: AnyAlert? {
        object.activeAlert
    }
    
    /// If an alert is currently displayed on this screen.
    @MainActor var hasActiveAlert: Bool {
        activeAlert != nil
    }
    
    /// Active modals displayed on this screen.
    @MainActor var activeModals: [AnyModal] {
        object.activeModals
    }
    
    /// If a modal is currently displayed on this screen.
    @MainActor var hasActiveModal: Bool {
        !object.activeModals.isEmpty
    }
    
    /// Active transition heirarchy on this screen.
    @MainActor var activeTransitions: [AnyTransitionDestination] {
        object.activeTransitions
    }
    
    /// If there is an active transition on this screen.
    @MainActor var hasActiveTransition: Bool {
        !object.activeTransitions.isEmpty
    }
    
    /// Available transition destinations in this screen's tranisition queue.
    ///
    /// Use showNextTransition() to trigger the next transition.
    @MainActor var activeTransitionQueue: [AnyTransitionDestination] {
        object.activeTransitionQueue
    }
    
    /// If there is at least 1 transition in activeTransitionQueue.
    @MainActor var hasTransitionInQueue: Bool {
        !object.activeTransitionQueue.isEmpty
    }
    
    /// Segue to a new screen.
    /// - Parameters:
    ///   - segue: Push (NavigationLink), Sheet, or FullScreenCover
    ///   - id: Identifier for the screen
    ///   - location: Where to insert the new screen in the heirarchy (default = .insert)
    ///   - onDismiss: Trigger closure when screen gets dismissed (note: dismiss != disappear)
    ///   - animates: If the segue should animate or not (default = true)
    ///   - destination: The destination screen.
    @MainActor func showScreen<T>(
        _ segue: SegueOption = .push,
        id: String = UUID().uuidString,
        location: SegueLocation = .insert,
        animates: Bool = true,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> T
    ) where T : View {
        let destination = AnyDestination(id: id, segue: segue, location: location, animates: animates, onDismiss: onDismiss, destination: destination)
        object.showScreens(destinations: [destination])
    }

    /// Add one screen to the screen heirarchy.
    @MainActor func showScreen(destination: AnyDestination) {
        object.showScreens(destinations: [destination])
    }
    
    /// Add one screen to the screen heirarchy.
    @MainActor func showScreen(_ destination: AnyDestination) {
        object.showScreens(destinations: [destination])
    }
    
    /// Add multiple screens to the screen heirarchy. Immediately trigger screens in order, resulting with the last screen displayed to the user.
    ///
    /// Note: destination.location will be overridden to support this method.
    @MainActor func showScreens(destinations: [AnyDestination]) {
        object.showScreens(destinations: destinations)
    }
        
    /// Dismiss this screen and all screens in front of it.
    @MainActor func dismissScreen(animates: Bool = true) {
        object.dismissScreen(animates: animates)
    }
    
    /// Dismiss screen at id and all screens in front of it.
    @MainActor func dismissScreen(id: String, animates: Bool = true) {
        object.dismissScreen(id: id, animates: animates)
    }
    
    /// Dismiss all screens in front of (but not including) screen at id.
    @MainActor func dismissScreens(upToScreenId: String, animates: Bool = true) {
        object.dismissScreens(upToScreenId: upToScreenId, animates: animates)
    }
    
    /// Dismiss a specific number of screens.
    @MainActor func dismissScreens(count: Int, animates: Bool = true) {
        object.dismissScreens(count: count, animates: animates)
    }
    
    /// Dismiss all .push segues on the NavigationStack for this screen.
    @MainActor func dismissPushStack(animates: Bool = true) {
        object.dismissPushStack(animates: animates)
    }
    
    /// Dismiss the closest .sheet or .fullScreenCover to this screen.
    @MainActor func dismissEnvironment(animates: Bool = true) {
        object.dismissEnvironment(animates: animates)
    }
    
    /// Dismiss the last screen in the heirarchy, regardless of call-site.
    @MainActor func dismissLastScreen(animates: Bool = true) {
        object.dismissLastScreen(animates: animates)
    }
    
    /// Dismiss all .push segues on the last NavigationStack in the heirarchy, regardless of call-site.
    @MainActor func dismissLastPushStack(animates: Bool = true) {
        object.dismissLastPushStack(animates: animates)
    }
    
    /// Dismiss the last .sheet or .fullScreenCover in the heirarchy, regardless of call-site.
    @MainActor func dismissLastEnvironment(animates: Bool = true) {
        object.dismissLastEnvironment(animates: animates)
    }
    
    /// Dismiss all screens in the heirarchy.
    @MainActor func dismissAllScreens(animates: Bool = true) {
        object.dismissAllScreens(animates: animates)
    }

    
    /// Add 1 screen to this RouterView's screen queue.
    ///
    /// Use showNextScreen() to trigger the next screen.
    @MainActor func addScreenToQueue(destination: AnyDestination) {
        object.addScreensToQueue(destinations: [destination])
    }
    
    /// Add multiple screens to this RouterView's screen queue.
    ///
    /// Use showNextScreen() to trigger the next screen.
    @MainActor func addScreensToQueue(destinations: [AnyDestination]) {
        object.addScreensToQueue(destinations: destinations)
    }
    
    /// Remove 1 screen from this RouterView's screen queue.
    @MainActor func removeScreenFromQueue(id: String) {
        object.removeScreensFromQueue(ids: [id])
    }
    
    /// Remove multiple screens from this RouterView's screen queue.
    @MainActor func removeScreensFromQueue(ids: [String]) {
        object.removeScreensFromQueue(ids: ids)
    }
    
    /// Remove all screens from this RouterView's screen queue.
    @MainActor func removeAllScreensFromQueue() {
        object.removeAllScreensFromQueue()
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, if available.
    @MainActor func showNextScreen() {
        object.showNextScreen()
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, otherwise throw an error.
    @MainActor func tryShowNextScreen() throws {
        guard hasScreenInQueue else {
            throw AnyRouterError.noScreensInQueue
        }
        
        object.showNextScreen()
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, if available, otherwise dismiss the screen.
    @MainActor func showNextScreenOrDismissScreen(animateDismiss: Bool = true) {
        do {
            try tryShowNextScreen()
        } catch {
            object.dismissScreen(animates: animateDismiss)
        }
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, if available, otherwise dismiss the environment.
    @MainActor func showNextScreenOrDismissEnvironment(animateDismiss: Bool = true) throws {
        do {
            try tryShowNextScreen()
        } catch {
            object.dismissEnvironment(animates: animateDismiss)
        }
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, if available, otherwise dismiss the .push stack.
    @MainActor func showNextScreenOrDismissPushStack(animateDismiss: Bool = true) throws {
        do {
            try tryShowNextScreen()
        } catch {
            object.dismissPushStack(animates: animateDismiss)
        }
    }
    
    
    // MARK: ALERTS
    
    @MainActor public func showAlert<T:View>(
        _ style: AlertStyle = .alert,
        location: AlertLocation = .topScreen,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder buttons: @escaping () -> T
    ) where T : View {
        let alert = AnyAlert(style: style, location: location, title: title, subtitle: subtitle, buttons: buttons)
        object.showAlert(alert: alert)
    }
    
    @MainActor public func showAlert(_ style: AlertStyle = .alert, location: AlertLocation = .topScreen, title: String, subtitle: String? = nil) {
        let alert = AnyAlert(style: style, location: location, title: title, subtitle: subtitle)
        object.showAlert(alert: alert)
    }
    
    @MainActor public func showAlert(alert: AnyAlert) {
        object.showAlert(alert: alert)
    }
    
    @MainActor public func showAlert(_ alert: AnyAlert) {
        object.showAlert(alert: alert)
    }
    
    @MainActor public func showSimpleAlert(text: String, action: (() -> Void)? = nil) {
        showAlert(.alert, title: text) {
            Button("OK") {
                action?()
            }
        }
    }
    
    @MainActor public func dismissAlert() {
        object.dismissAlert()
    }
    
    @MainActor public func dismissAllAlerts() {
        object.dismissAllAlerts()
    }

    // MARK: MODALS
    
    @MainActor public func showModal<T>(
        id: String = UUID().uuidString,
        transition: AnyTransition = .identity,
        animation: Animation = .smooth,
        alignment: Alignment = .center,
        backgroundColor: Color? = nil,
        dismissOnBackgroundTap: Bool = true,
        ignoreSafeArea: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder destination: @escaping () -> T
    ) where T : View {
            let modal = AnyModal(
                id: id,
                transition: transition,
                animation: animation,
                alignment: alignment,
                backgroundColor: backgroundColor,
                dismissOnBackgroundTap: dismissOnBackgroundTap,
                ignoreSafeArea: ignoreSafeArea,
                destination: destination,
                onDismiss: onDismiss
            )
            object.showModal(modal: modal)
    }
    
    /// Convenience method for a simple modal appearing over the current Environment in the center of the screen.
//    public func showBasicModal<T>(@ViewBuilder destination: @escaping () -> T) where T : View {
//        showModal(
//            transition: AnyTransition.opacity.animation(.easeInOut),
//            animation: .easeInOut,
//            alignment: .center,
//            backgroundColor: Color.black.opacity(0.4),
//            ignoreSafeArea: true,
//            destination: destination)
//    }
    
    @MainActor public func showModal(modal: AnyModal) {
        object.showModal(modal: modal)
    }
    
    @MainActor public func showModal(_ modal: AnyModal) {
        object.showModal(modal: modal)
    }
    
    @MainActor public func showModals(modals: [AnyModal]) {
        for modal in modals {
            object.showModal(modal: modal)
        }
    }
    
    @MainActor func dismissModal() {
        object.dismissModal()
    }
    
    @MainActor func dismissModal(id: String) {
        object.dismissModal(id: id)
    }
    
    @MainActor func dismissModals(upToModalId: String) {
        object.dismissModals(upToModalId: upToModalId)
    }
    
    @MainActor func dismissModals(count: Int) {
        object.dismissModals(count: count)
    }
    
    @MainActor func dismissAllModals() {
        object.dismissAllModals()
    }
    
    @MainActor public func showTransition<T>(
        _ transition: TransitionOption,
        id: String = UUID().uuidString,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> T
    ) where T : View {
        let transition = AnyTransitionDestination(id: id, transition: transition, destination: destination)
        object.showTransition(transition: transition)
    }
    
    @MainActor public func showTransition(transition: AnyTransitionDestination) {
        object.showTransition(transition: transition)
    }
    
    @MainActor public func showTransition(_ transition: AnyTransitionDestination) {
        object.showTransition(transition: transition)
    }
    
    @MainActor public func showTransitions(transitions: [AnyTransitionDestination]) {
        object.showTransitions(transitions: transitions)
    }
    
    @MainActor public func dismissTransition() {
        object.dismissTransition()
    }
    
    @MainActor func dismissTransition(id: String) {
        object.dismissTransition(id: id)
    }
    
    @MainActor public func dismissTransitions(upToId: String) {
        object.dismissTransitions(upToId: upToId)
    }
    
    @MainActor public func dismissTransitions(count: Int) {
        object.dismissTransitions(count: count)
    }
    
    @MainActor public func dismissTransitionOrDismissScreen() {
        if hasActiveTransition {
            dismissTransition()
        } else {
            dismissScreen()
        }
    }
    
    @MainActor public func dismissAllTransitions() {
        object.dismissAllTransitions()
    }

    @MainActor public func addTransitionToQueue(transition: AnyTransitionDestination) {
        object.addTransitionsToQueue(transitions: [transition])
    }
    
    @MainActor public func addTransitionsToQueue(transitions: [AnyTransitionDestination]) {
        object.addTransitionsToQueue(transitions: transitions)
    }
    
    @MainActor public func removeTransitionFromQueue(id: String) {
        object.removeTransitionsFromQueue(ids: [id])
    }
    
    @MainActor public func removeTransitionsFromQueue(ids: [String]) {
        object.removeTransitionsFromQueue(ids: ids)
    }
    
    @MainActor public func removeAllTransitionsFromQueue() {
        object.removeAllTransitionsFromQueue()
    }
    
    @MainActor public func showNextTransition() {
        object.showNextTransition()
    }
    
    @MainActor public func tryShowNextTransition() throws {
        guard hasTransitionInQueue else {
            throw AnyRouterError.noTransitionsInQueue
        }
        
        object.showNextTransition()
    }
    
    @MainActor public func showNextTransitionOrNextScreenOrDismissScreen() throws {
        do {
            try tryShowNextTransition()
        } catch {
            do {
                try tryShowNextScreen()
            } catch {
                dismissScreen()
            }
        }
    }
    
    enum AnyRouterError: Error {
        case noTransitionsInQueue
        case noScreensInQueue
    }
    
    @MainActor public func showModule<T>(
        _ transition: TransitionOption,
        id: String = UUID().uuidString,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> T
    ) where T : View {
        let module = AnyTransitionDestination(id: id, transition: transition, destination: destination)
        object.showModule(module: module)
    }
    
    @MainActor public func showModule(module: AnyTransitionDestination) {
        object.showModule(module: module)
    }
    
    @MainActor public func showModule(_ module: AnyTransitionDestination) {
        object.showModule(module: module)
    }
    
    @MainActor public func showModules(modules: [AnyTransitionDestination]) {
        object.showModules(modules: modules)
    }
    
    @MainActor public func dismissModule() {
        object.dismissModule()
    }
    
    @MainActor public func dismissModule(id: String) {
        object.dismissModule(id: id)
    }
    
    @MainActor public func dismissModules(upToId: String) {
        object.dismissModules(upToId: upToId)
    }
    
    @MainActor public func dismissModules(count: Int) {
        object.dismissModules(count: count)
    }
    
    @MainActor public func dismissAllModules() {
        object.dismissAllModules()
    }
    

    /// Open URL in Safari app. To open url in in-app browser, use showSheet with a WebView.
    func showSafari(_ url: @escaping () -> URL) {
        object.showSafari(url)
    }

}

let printPrefix = "🕊️ SwiftfulRouting 🕊️ -> "

struct MockRouter: Router {
    
    private func printError() {
        #if DEBUG
        print(printPrefix + "Please add a RouterView to the View heirarchy before using Router. There is no Router in the environment!")
        #endif
    }
    
    init() {
        
    }
    
    var activeScreens: [AnyDestinationStack] {
        []
    }
    
    var activeScreenQueue: [AnyDestination] {
        []
    }
    
    var activeAlert: AnyAlert? {
        nil
    }
    
    var activeModals: [AnyModal] {
        []
    }
    
    var activeTransitions: [AnyTransitionDestination] {
        []
    }
    
    var activeTransitionQueue: [AnyTransitionDestination] {
        []
    }

    
    func showScreens(destinations: [AnyDestination]) {
        printError()
    }
    
    func dismissScreen(animates: Bool) {
        printError()
    }
    
    func dismissScreen(id: String, animates: Bool) {
        printError()
    }
    
    func dismissScreens(upToScreenId: String, animates: Bool) {
        printError()
    }
    
    func dismissScreens(count: Int, animates: Bool) {
        printError()
    }
    
    func dismissPushStack(animates: Bool) {
        printError()
    }
    
    func dismissEnvironment(animates: Bool) {
        printError()
    }
    
    func dismissLastScreen(animates: Bool) {
        printError()
    }
    
    func dismissLastPushStack(animates: Bool) {
        printError()
    }
    
    func dismissLastEnvironment(animates: Bool) {
        printError()
    }
    
    func dismissAllScreens(animates: Bool) {
        printError()
    }
    
    func addScreensToQueue(destinations: [AnyDestination]) {
        printError()
    }
    
    func removeScreensFromQueue(ids: [String]) {
        printError()
    }
    
    func removeAllScreensFromQueue() {
        printError()
    }
    
    func showNextScreen() {
        printError()
    }
    
    func showAlert(alert: AnyAlert) {
        printError()
    }
    
    func dismissAlert() {
        printError()
    }
    
    func dismissAllAlerts() {
        printError()
    }
    
    func showModal(modal: AnyModal) {
        printError()
    }
    
    func dismissModal() {
        printError()
    }
    
    func dismissModal(id: String) {
        printError()
    }
    
    func dismissModals(upToModalId: String) {
        printError()
    }
    
    func dismissModals(count: Int) {
        printError()
    }
    
    func dismissAllModals() {
        printError()
    }
    
    func showTransition(transition: AnyTransitionDestination) {
        printError()
    }
    
    func showTransitions(transitions: [AnyTransitionDestination]) {
        printError()
    }
    
    func dismissTransition() {
        printError()
    }
    
    func dismissTransition(id: String) {
        printError()
    }
    
    func dismissTransitions(upToId: String) {
        printError()
    }
    
    func dismissTransitions(count: Int) {
        printError()
    }
    
    func dismissAllTransitions() {
        printError()
    }
    
    func addTransitionsToQueue(transitions: [AnyTransitionDestination]) {
        printError()
    }
    
    func removeTransitionsFromQueue(ids: [String]) {
        printError()
    }
    
    func removeAllTransitionsFromQueue() {
        printError()
    }
    
    func showNextTransition() {
        printError()
    }
    
    func showModule(module: AnyTransitionDestination) {
        printError()
    }
    
    func showModules(modules: [AnyTransitionDestination]) {
        printError()
    }
    
    func dismissModule() {
        printError()
    }
    
    func dismissModule(id: String) {
        printError()
    }
    
    func dismissModules(upToId: String) {
        printError()
    }
    
    func dismissModules(count: Int) {
        printError()
    }
    
    func dismissAllModules() {
        printError()
    }
    
    func showSafari(_ url: @escaping () -> URL) {
        printError()
    }
}
