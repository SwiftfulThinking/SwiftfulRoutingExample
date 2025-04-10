//
//  Notes.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/9/25.
//



/// A SwiftUI view that injects a router system into the environment, enabling navigation and routing for all child views.
/// Use this in place of a `NavigationStack` as the root of your view hierarchy.
///
/// Example usage:
/// ```swift
/// RouterView { router in
///     MyView(router: router)
/// }
///
/// ```
/// The returned router is also added to the child Environment, so you don't have to pass it manually:
/// ```swift
/// RouterView { _ in
///     MyView()
/// }
/// ```
///
/// - Parameters:
///   - addNavigationStack: Whether to wrap the root content in a `NavigationStack`. Defaults to `true`.
///   - logger: Enables debug logging for router events. Defaults to `false`.
///   - content: A closure that provides the root content view, receiving an `AnyRouter` instance for navigation control.
