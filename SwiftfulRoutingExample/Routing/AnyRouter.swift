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
    
    func showScreen<T>(id: String = UUID().uuidString, segue: SegueOption = .push, location: SegueLocation = .insert, onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> T) where T : View {
        let destination = AnyDestination(id: id, segue: segue, location: location, onDismiss: onDismiss, destination: destination)
        object.showScreens(destinations: [destination])
    }
    
    func showScreen<T>(id: String = UUID().uuidString, _ segue: SegueOption = .push, location: SegueLocation = .insert, onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> T) where T : View {
        let destination = AnyDestination(id: id, segue: segue, location: location, onDismiss: onDismiss, destination: destination)
        object.showScreens(destinations: [destination])
    }
    
    func dismissScreen() {
        object.dismissScreen()
    }
    
    func dismissScreen(id: String) {
        object.dismissScreen(id: id)
    }
    
    func dismissScreens(upToScreenId: String) {
        object.dismissScreens(upToScreenId: upToScreenId)
    }
    
    func dismissScreens(count: Int) {
        object.dismissScreens(count: count)
    }
    
    func dismissPushStack() {
        object.dismissPushStack()
    }
    
    func dismissEnvironment() {
        object.dismissEnvironment()
    }
    
    func dismissLastScreen() {
        object.dismissLastScreen()
    }
    
    func dismissLastPushStack() {
        object.dismissLastPushStack()
    }
    
    func dismissLastEnvironment() {
        object.dismissLastEnvironment()
    }
    
    func dismissAllScreens() {
        object.dismissAllScreens()
    }

    
    /// Show any screen via Push (NavigationLink), Sheet, or FullScreenCover.
//    func showScreen<T>(id: String = UUID().uuidString, _ option: SegueOption, onDismiss: (() -> Void)? = nil, @ViewBuilder destination: @escaping (AnyRouter) -> T) where T : View {
//        object.enterScreenFlow([AnyRoute(id: id, option, onDismiss: onDismiss, destination: destination)])
//    }
//
//    /// Show any screen via Push (NavigationLink), Sheet, or FullScreenCover.
//    func showScreen(_ route: AnyRoute) {
//        object.enterScreenFlow([route])
//    }
//    
//    /// Show a flow of screens, segueing to the first route immediately. The following routes can be accessed via 'showNextScreen()'.
//    func enterScreenFlow(_ routes: [AnyRoute]) {
//        object.enterScreenFlow(routes)
//    }
//    
//    /// Shows the next screen set in the current screen flow. This would have been set previously via showScreens().
//    func showNextScreen() throws {
//        try object.showNextScreen()
//    }
//    
//    /// If there is a next screen in the current screen flow, go to it. Otherwise, flow is complete and dismiss the environment.
//    func showNextScreenOrDismissEnvironment() {
//        do {
//            try showNextScreen()
//        } catch {
//            dismissEnvironment()
//        }
//    }
//    
//    /// Dismiss the top-most presented environment (this would be the top-most sheet or fullScreenCover).
//    func dismissEnvironment() {
//        object.dismissEnvironment()
//    }
//    
//    /// Dismiss the top-most presented screen in the current Environment. Same as calling presentationMode.wrappedValue.dismiss().
//    func dismissScreen() {
//        object.dismissScreen()
//    }
//    
//    func dismissScreens(to id: String) {
//        object.dismissScreens(to: id)
//    }
//
//    /// Push a stack of screens and show the last one immediately.
//    @available(iOS 16, *)
//    func pushScreenStack(destinations: [PushRoute]) {
//        object.pushScreenStack(destinations: destinations)
//    }
//    
//    /// Show a resizeable sheet on top of the current context.
//    @available(iOS 16, *)
//    func showResizableSheet<V>(sheetDetents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool, onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> V) where V : View {
//        object.showResizableSheet(sheetDetents: sheetDetents, selection: selection, showDragIndicator: showDragIndicator, onDismiss: onDismiss, destination: destination)
//    }
//        
//    /// Dismiss all NavigationLinks in NavigationStack heirarchy.
//    ///
//    ///  WARNING: Does not dismiss Sheet or FullScreenCover.
//    @available(iOS 16, *)
//    func dismissScreenStack() {
//        object.dismissScreenStack()
//    }
    
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
