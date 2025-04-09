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
    
    @MainActor func showScreen(destination: AnyDestination) {
        object.showScreens(destinations: [destination])
    }
    
    @MainActor func showScreen(_ destination: AnyDestination) {
        object.showScreens(destinations: [destination])
    }
    
    /// Note: AnyDestination.location will be overridden to support this method.
    @MainActor func showScreens(destinations: [AnyDestination]) {
        object.showScreens(destinations: destinations)
    }
    
    @MainActor func showScreen<T>(
        id: String = UUID().uuidString,
        segue: SegueOption = .push,
        location: SegueLocation = .insert,
        onDismiss: (() -> Void)? = nil,
        animates: Bool = true,
        destination: @escaping (AnyRouter) -> T
    ) where T : View {
        let destination = AnyDestination(id: id, segue: segue, location: location, animates: animates, onDismiss: onDismiss, destination: destination)
        object.showScreens(destinations: [destination])
    }
    
    @MainActor func showScreen<T>(
        id: String = UUID().uuidString,
        _ segue: SegueOption = .push,
        location: SegueLocation = .insert,
        onDismiss: (() -> Void)? = nil,
        animates: Bool = true,
        destination: @escaping (AnyRouter) -> T
    ) where T : View {
        let destination = AnyDestination(id: id, segue: segue, location: location, onDismiss: onDismiss, destination: destination)
        object.showScreens(destinations: [destination])
    }
    
    @MainActor func dismissScreen(animates: Bool = true) {
        object.dismissScreen(animates: animates)
    }
    
    @MainActor func dismissScreen(id: String, animates: Bool = true) {
        object.dismissScreen(id: id, animates: animates)
    }
    
    @MainActor func dismissScreens(upToScreenId: String, animates: Bool = true) {
        object.dismissScreens(upToScreenId: upToScreenId, animates: animates)
    }
    
    @MainActor func dismissScreens(count: Int, animates: Bool = true) {
        object.dismissScreens(count: count, animates: animates)
    }
    
    @MainActor func dismissPushStack(animates: Bool = true) {
        object.dismissPushStack(animates: animates)
    }
    
    @MainActor func dismissEnvironment(animates: Bool = true) {
        object.dismissEnvironment(animates: animates)
    }
    
    @MainActor func dismissLastScreen(animates: Bool = true) {
        object.dismissLastScreen(animates: animates)
    }
    
    @MainActor func dismissLastPushStack(animates: Bool = true) {
        object.dismissLastPushStack(animates: animates)
    }
    
    @MainActor func dismissLastEnvironment(animates: Bool = true) {
        object.dismissLastEnvironment(animates: animates)
    }
    
    @MainActor func dismissAllScreens(animates: Bool = true) {
        object.dismissAllScreens(animates: animates)
    }

    @MainActor func addScreenToQueue(destination: AnyDestination) {
        object.addScreensToQueue(destinations: [destination])
    }
    
    @MainActor func addScreensToQueue(destinations: [AnyDestination]) {
        object.addScreensToQueue(destinations: destinations)
    }
    
    @MainActor func removeScreenFromQueue(id: String) {
        object.removeScreensFromQueue(ids: [id])
    }
    
    @MainActor func removeScreensFromQueue(ids: [String]) {
        object.removeScreensFromQueue(ids: ids)
    }
    
    @MainActor func clearScreenQueue() {
        object.clearScreenQueue()
    }
    
    @MainActor func showNextScreen() throws {
        try object.showNextScreen()
    }
    
    @MainActor func showNextScreenOrDismiss(animateDismiss: Bool = true) throws {
        do {
            try object.showNextScreen()
        } catch {
            object.dismissScreen(animates: animateDismiss)
        }
    }
    
    @MainActor func showNextScreenOrDismissEnvironment(animateDismiss: Bool = true) throws {
        do {
            try object.showNextScreen()
        } catch {
            object.dismissEnvironment(animates: animateDismiss)
        }
    }
    
    @MainActor func showNextScreenOrDismissPushStack(animateDismiss: Bool = true) throws {
        do {
            try object.showNextScreen()
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
        id: String = UUID().uuidString,
        _ transition: TransitionOption,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> T
    ) where T : View {
        let transition = AnyTransitionDestination(id: id, transition: transition, destination: destination)
        object.showTransition(transition: transition)
    }
    
    @MainActor public func showTransition(transition: AnyTransitionDestination) {
        object.showTransition(transition: transition)
    }
    
    @MainActor public func showTransitions(transitions: [AnyTransitionDestination]) {
        object.showTransitions(transitions: transitions)
    }
    
    @MainActor public func dismissTransition() throws {
        try object.dismissTransition()
    }
    
    @MainActor func dismissTransition(id: String) {
        object.dismissTransition(id: id)
    }
    
    @MainActor public func dismissTransitions(upToScreenId: String) {
        object.dismissTransitions(upToScreenId: upToScreenId)
    }
    
    @MainActor public func dismissTransitions(count: Int) {
        object.dismissTransitions(count: count)
    }
    
    @MainActor public func dismissTransitionOrDismissScreen() {
        do {
            try dismissTransition()
        } catch {
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
    
    @MainActor public func clearTransitionsQueue() {
        object.clearTransitionsQueue()
    }
    
    @MainActor public func showNextTransition() throws {
        try object.showNextTransition()
    }
    
//    
//    /// Open URL in Safari app. To open url in in-app browser, use showSheet with a WebView.
//    func showSafari(_ url: @escaping () -> URL) {
//        object.showSafari(url)
//    }

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
    
    func clearScreenQueue() {
        printError()
    }
    
    func showNextScreen() throws {
        printError()
    }
    
    func showAlert(alert: AnyAlert) {
        printError()
    }
    
    func dismissAlert() {
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
    
    func dismissTransition() throws {
        printError()
    }
    
    func dismissTransition(id: String) {
        printError()
    }
    
    func dismissTransitions(upToScreenId: String) {
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
    
    func clearTransitionsQueue() {
        printError()
    }
    
    func showNextTransition() throws {
        printError()
    }
    
    
    
}


//struct MockRouter: Router {
//    

//    
//    func enterScreenFlow(_ routes: [AnyRoute]) {
//        printError()
//    }
//    
//    func showNextScreen() throws {
//        printError()
//    }
//    
//    func dismissScreen() {
//        printError()
//    }
//    
//    func dismissScreens(to id: String) {
//        printError()
//    }
//    
//    func dismissEnvironment() {
//        printError()
//    }
//    
//    func dismissScreenStack() {
//        printError()
//    }
//    
//    func pushScreenStack(destinations: [PushRoute]) {
//        printError()
//    }
//
//    func showResizableSheet<V>(sheetDetents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool, onDismiss: (() -> Void)?, destination: @escaping (AnyRouter) -> V) where V : View {
//        printError()
//    }
//    
//    func showAlert<T>(_ option: DialogOption, title: String, subtitle: String?, alert: @escaping () -> T, buttonsiOS13: [Alert.Button]?) where T : View {
//        printError()
//    }
//    
//    func dismissAlert() {
//        printError()
//    }
//    
//    func showModal<V>(id: String = UUID().uuidString, transition: AnyTransition, animation: Animation, alignment: Alignment, backgroundColor: Color?, dismissOnBackgroundTap: Bool, ignoreSafeArea: Bool, destination: @escaping () -> V) where V : View {
//        printError()
//    }
//    
//    func dismissModal(id: String? = nil) {
//        printError()
//    }
//    
//    func dismissAllModals() {
//        printError()
//    }
//    
//    func showSafari(_ url: @escaping () -> URL) {
//        printError()
//    }
//    
//    
//}
