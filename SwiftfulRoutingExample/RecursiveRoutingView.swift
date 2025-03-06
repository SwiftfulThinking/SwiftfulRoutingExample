//
//  RecursiveRoutingView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 3/4/25.
//

import SwiftUI

struct ContentView2: View {
    var body: some View {
        RouterView(addNavigationStack: true) { router in
            RecursiveRoutingView(router: router, screenNumber: 0)
        }
    }
}

struct RecursiveRoutingView: View {
    
    let router: AnyRouter
    let screenNumber: Int

    var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }

    var isSegueTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("SEGUES")
    }
        
    var body: some View {
        List {
            Text("Screen Number: \(screenNumber)")
                .accessibilityIdentifier("Title_\(screenNumber)")

            if isUITesting {
                if isSegueTesting {
                    segueButtons
                    dismissButtons
                }
            } else {
                segueButtons
                dismissButtons
            }
        }
        .navigationTitle("\(screenNumber)")
        .navigationBarTitleDisplayMode(.inline)
//        .listStyle(PlainListStyle())
    }
    
    private func performSegue(segue: SegueOption) {
        let screen = AnyDestination(
            id: "\(screenNumber + 1)",
            segue: segue,
            location: .insert,
            onDismiss: nil,
            destination: { router in
                RecursiveRoutingView(
                    router: router,
                    screenNumber: screenNumber + 1
                )
            }
        )
        
        router.showScreen(screen)
    }
    
//    private func performMultipleSegues(segue: [SegueOption]) {
//        let screen = AnyDestination(
//            id: "\(screenNumber + 1)",
//            segue: segue,
//            location: .insert,
//            onDismiss: nil,
//            destination: { router in
//                RecursiveRoutingView(
//                    router: router,
//                    screenNumber: screenNumber + 1
//                )
//            }
//        )
//
//        router.showScreen(screen)
//    }
    
    @ViewBuilder
    var segueButtons: some View {
        Button("Push") {
            performSegue(segue: .push)
        }
        .accessibilityIdentifier("Button_Push")

        Button("Sheet") {
            performSegue(segue: .sheet)
        }
        .accessibilityIdentifier("Button_Sheet")

        Button("FullScreenCover") {
            performSegue(segue: .fullScreenCover)
        }
        .accessibilityIdentifier("Button_FullScreenCover")
    }
    
    @ViewBuilder
    var dismissButtons: some View {
        Button("Dismiss") {
            router.dismissScreen()
        }
        .accessibilityIdentifier("Button_Dismiss")

    }

}

#Preview {
    ContentView2()
}
