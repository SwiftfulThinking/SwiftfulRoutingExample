//
//  AnyRouter.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

//struct RouterEnvironmentKey: EnvironmentKey {
//    static let defaultValue: AnyRouter = AnyRouter(object: MockRouter())
//}
//
//extension EnvironmentValues {
//    var router: AnyRouter {
//        get { self[RouterEnvironmentKey.self] }
//        set { self[RouterEnvironmentKey.self] = newValue }
//    }
//}

/// Type-erased Router with convenience methods.
struct AnyRouter: Router {
    private let object: any Router

    init(object: any Router) {
        self.object = object
    }
    
    func showScreen(destination: AnyDestination) {
        object.showScreens(destinations: [destination])
    }
    
    func showScreen(_ destination: AnyDestination) {
        object.showScreens(destinations: [destination])
    }
    
    /// Note: AnyDestination.location will be overridden to support this method.
    func showScreens(destinations: [AnyDestination]) {
        object.showScreens(destinations: destinations)
    }
    
    func showScreen<T>(id: String = UUID().uuidString, segue: SegueOption = .push, location: SegueLocation = .insert, onDismiss: (() -> Void)? = nil, animates: Bool = true, destination: @escaping (AnyRouter) -> T) where T : View {
        let destination = AnyDestination(id: id, segue: segue, location: location, animates: animates, onDismiss: onDismiss, destination: destination)
        object.showScreens(destinations: [destination])
    }
    
    func showScreen<T>(id: String = UUID().uuidString, _ segue: SegueOption = .push, location: SegueLocation = .insert, onDismiss: (() -> Void)? = nil, animates: Bool = true, destination: @escaping (AnyRouter) -> T) where T : View {
        let destination = AnyDestination(id: id, segue: segue, location: location, onDismiss: onDismiss, destination: destination)
        object.showScreens(destinations: [destination])
    }
    
    func dismissScreen(animates: Bool = true) {
        object.dismissScreen(animates: animates)
    }
    
    func dismissScreen(id: String, animates: Bool = true) {
        object.dismissScreen(id: id, animates: animates)
    }
    
    func dismissScreens(upToScreenId: String, animates: Bool = true) {
        object.dismissScreens(upToScreenId: upToScreenId, animates: animates)
    }
    
    func dismissScreens(count: Int, animates: Bool = true) {
        object.dismissScreens(count: count, animates: animates)
    }
    
    func dismissPushStack(animates: Bool = true) {
        object.dismissPushStack(animates: animates)
    }
    
    func dismissEnvironment(animates: Bool = true) {
        object.dismissEnvironment(animates: animates)
    }
    
    func dismissLastScreen(animates: Bool = true) {
        object.dismissLastScreen(animates: animates)
    }
    
    func dismissLastPushStack(animates: Bool = true) {
        object.dismissLastPushStack(animates: animates)
    }
    
    func dismissLastEnvironment(animates: Bool = true) {
        object.dismissLastEnvironment(animates: animates)
    }
    
    func dismissAllScreens(animates: Bool = true) {
        object.dismissAllScreens(animates: animates)
    }

    func addScreenToQueue(destination: AnyDestination) {
        object.addScreensToQueue(destinations: [destination])
    }
    
    func addScreensToQueue(destinations: [AnyDestination]) {
        object.addScreensToQueue(destinations: destinations)
    }
    
    func removeScreenFromQueue(id: String) {
        object.removeScreensFromQueue(ids: [id])
    }
    
    func removeScreensFromQueue(ids: [String]) {
        object.removeScreensFromQueue(ids: ids)
    }
    
    func clearQueue() {
        object.clearQueue()
    }
    
    func showNextScreen() throws {
        try object.showNextScreen()
    }
    
    func showNextScreenOrDismiss(animateDismiss: Bool = true) throws {
        do {
            try object.showNextScreen()
        } catch {
            object.dismissScreen(animates: animateDismiss)
        }
    }
    
    func showNextScreenOrDismissEnvironment(animateDismiss: Bool = true) throws {
        do {
            try object.showNextScreen()
        } catch {
            object.dismissEnvironment(animates: animateDismiss)
        }
    }
    
    func showNextScreenOrDismissPushStack(animateDismiss: Bool = true) throws {
        do {
            try object.showNextScreen()
        } catch {
            object.dismissPushStack(animates: animateDismiss)
        }
    }
    
    
    // MARK: ALERTS
    
    public func showAlert<T:View>(_ style: AlertStyle = .alert, location: AlertLocation = .topScreen, title: String, subtitle: String? = nil, @ViewBuilder buttons: @escaping () -> T) where T : View {
        let alert = AnyAlert(style: style, location: location, title: title, subtitle: subtitle, buttons: buttons)
        object.showAlert(alert: alert)
    }
    
    public func showAlert(_ style: AlertStyle = .alert, location: AlertLocation = .topScreen, title: String, subtitle: String? = nil) {
        let alert = AnyAlert(style: style, location: location, title: title, subtitle: subtitle)
        object.showAlert(alert: alert)
    }
    
    public func showAlert(alert: AnyAlert) {
        object.showAlert(alert: alert)
    }
    
    public func showSimpleAlert(text: String, action: (() -> Void)? = nil) {
        showAlert(.alert, title: text) {
            Button("OK") {
                action?()
            }
        }
    }
    
    public func dismissAlert() {
        object.dismissAlert()
    }

    


    
    
    
    
    
    /// Show any Alert or ConfirmationDialog.
    ///
    ///  WARNING: Alert modifiers were deprecated between iOS 14 & iOS 15. iOS 15+ will use '@ViewBuilder alert' parameter, while iOS 14 and below will use 'buttonsiOS13' parameter.
//    @available(iOS 15, *)
//    func showAlert<T:View>(_ option: DialogOption, title: String, subtitle: String? = nil, @ViewBuilder alert: @escaping () -> T) where T : View {
//        object.showAlert(option, title: title, subtitle: subtitle, alert: alert, buttonsiOS13: nil)
//    }
//    
//    func showAlert<T:View>(_ option: DialogOption, title: String, subtitle: String? = nil, @ViewBuilder alert: @escaping () -> T, buttonsiOS13: [Alert.Button]? = nil) where T : View {
//        object.showAlert(option, title: title, subtitle: subtitle, alert: alert, buttonsiOS13: buttonsiOS13)
//    }
//    
//    /// Convenience method for a simple alert with title text and ok button.
//    func showBasicAlert(text: String, action: (() -> Void)? = nil) {
//        showAlert(.alert, title: text) {
//            Button("OK") {
//                action?()
//            }
//        }
//    }
//    
//    /// Dismiss presented alert. Note: Alerts often dismiss themselves. Calling this anyway is ok.
//    func dismissAlert() {
//        object.dismissAlert()
//    }
//    
//    /// Show any Modal over the current Environment.
//    func showModal<T>(
//        id: String = UUID().uuidString,
//        transition: AnyTransition = .identity,
//        animation: Animation = .smooth,
//        alignment: Alignment = .center,
//        backgroundColor: Color? = nil,
//        dismissOnBackgroundTap: Bool = true,
//        ignoreSafeArea: Bool = true,
//        @ViewBuilder destination: @escaping () -> T) where T : View {
//            object.showModal(id: id, transition: transition, animation: animation, alignment: alignment, backgroundColor: backgroundColor, dismissOnBackgroundTap: dismissOnBackgroundTap, ignoreSafeArea: ignoreSafeArea, destination: destination)
//    }
//    
//    /// Convenience method for a simple modal appearing over the current Environment in the center of the screen.
//    func showBasicModal<T>(@ViewBuilder destination: @escaping () -> T) where T : View {
//        showModal(
//            transition: AnyTransition.opacity.animation(.easeInOut),
//            animation: .easeInOut,
//            alignment: .center,
//            backgroundColor: Color.black.opacity(0.4),
//            ignoreSafeArea: true,
//            destination: destination)
//    }
//    
//    func dismissModal(id: String? = nil) {
//        object.dismissModal(id: id)
//    }
//    
//    func dismissAllModals() {
//        object.dismissAllModals()
//    }
//    
//    /// Open URL in Safari app. To open url in in-app browser, use showSheet with a WebView.
//    func showSafari(_ url: @escaping () -> URL) {
//        object.showSafari(url)
//    }

}

let printPrefix = "🕊️ SwiftfulRouting 🕊️ -> "

//struct MockRouter: Router {
//    
//    private func printError() {
//        #if DEBUG
//        print(printPrefix + "Please add a RouterView to the View heirarchy before using Router. There is no Router in the environment!")
//        #endif
//    }
//    
//    init() {
//        
//    }
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
