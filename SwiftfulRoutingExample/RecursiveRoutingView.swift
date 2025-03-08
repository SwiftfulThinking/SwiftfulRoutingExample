//
//  RecursiveRoutingView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 3/4/25.
//

import SwiftUI

struct ContentView2: View {
    var body: some View {
        RouterView(addNavigationStack: true, logger: true) { router in
            RecursiveRoutingView(router: router, screenNumber: 0)
        }
    }
}

struct RecursiveRoutingView: View {
    
    let router: AnyRouter
    let screenNumber: Int

    @State private var lastDismiss: Int = -1

    var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }

    var isSegueTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("SEGUES")
    }
    
    var isMultiSegueTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("MULTISEGUES")
    }
    
    var isDismissTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("DISMISSING")
    }
        
    var body: some View {
        List {
            Text("Screen Number: \(screenNumber)")
                .accessibilityIdentifier("Title_\(screenNumber)")

            Text("Last dismiss number: " + (lastDismiss >= 0 ? "\(lastDismiss)" : ""))
                .accessibilityIdentifier("LastDismiss_\(lastDismiss)")

            if isUITesting {
                if isSegueTesting {
                    segueButtons
                    dismissButtons()
                } else if isMultiSegueTesting {
                    multiSegueButtons
                    dismissButtons()
                } else if isDismissTesting {
                    segueButtons
                    dismissButtons(showAll: true)
                } else {
                    Text("Err")
                }
            } else {
                Section("Segues") {
                    segueButtons
                }
                Section("Multi-Segues") {
                    multiSegueButtons
                }
                Section("Dismiss actions") {
                    dismissButtons(showAll: true)
                }
            }
        }
        .navigationTitle("\(screenNumber)")
        .navigationBarTitleDisplayMode(.inline)
//        .listStyle(PlainListStyle())
    }
    
    private func dismissAction(_ number: Int) {
        print("DISMISS ACTION: \(number)")
        lastDismiss = number
    }
    
    private func performSegue(segue: SegueOption) {
        let screenNumber = screenNumber + 1
        let screen = AnyDestination(
            id: "\(screenNumber)",
            segue: segue,
            location: .insert,
            onDismiss: {
                dismissAction(screenNumber)
            },
            destination: { router in
                RecursiveRoutingView(
                    router: router,
                    screenNumber: screenNumber
                )
            }
        )
        
        router.showScreen(screen)
    }
    
    private func performMultiSegue(segues: [SegueOption]) {
        var destinations: [AnyDestination] = []
        
        for (index, segue) in segues.enumerated() {
            let screenNumber = screenNumber + 1 + index
            let screen = AnyDestination(
                id: "\(screenNumber)",
                segue: segue,
                location: .insert,
                onDismiss: {
                    dismissAction(screenNumber)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: screenNumber
                    )
                }
            )
            destinations.append(screen)
        }
        
        router.showScreens(destinations: destinations)
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
    var multiSegueButtons: some View {
        Button("Push 3x") {
            performMultiSegue(segues: [.push, .push, .push])
        }
        .accessibilityIdentifier("Button_Push3x")
        
        Button("Sheet 3x") {
            performMultiSegue(segues: [.sheet, .sheet, .sheet])
        }
        .accessibilityIdentifier("Button_Sheet3x")

        Button("Full 3x") {
            performMultiSegue(segues: [.fullScreenCover, .fullScreenCover, .fullScreenCover])
        }
        .accessibilityIdentifier("Button_Full3x")

        Button("Push, Sheet, Full") {
            performMultiSegue(segues: [.push, .sheet, .fullScreenCover])
        }
        .accessibilityIdentifier("Button_PushSheetFull")

        Button("Full, Sheet, Push") {
            performMultiSegue(segues: [.fullScreenCover, .sheet, .push])
        }
        .accessibilityIdentifier("Button_FullSheetPush")
    }
    
    @ViewBuilder
    func dismissButtons(showAll: Bool = false) -> some View {
        Button("Dismiss") {
            router.dismissScreen()
        }
        .accessibilityIdentifier("Button_Dismiss")

        if showAll {
            Button("Dismiss screen 2") {
                router.dismissScreen(id: "2")
            }
            .accessibilityIdentifier("Button_DismissId2")

            Button("Dismiss to screen 1") {
                router.dismissScreens(upToScreenId: "1")
            }
            .accessibilityIdentifier("Button_DismissTo1")
            
            Button("Dismiss to 2 screens") {
                router.dismissScreens(upToScreenId: "1")
            }
            .accessibilityIdentifier("Button_DismissCount2")

            Button("Dismiss push stack") {
                router.dismissPushStack()
            }
            .accessibilityIdentifier("Button_DismissStack")

            Button("Dismiss environment") {
                router.dismissEnvironment()
            }
            .accessibilityIdentifier("Button_DismissEnvironment")

            Button("Dismiss all screens") {
                router.dismissAllScreens()
            }
            .accessibilityIdentifier("Button_DismissAll")

        }
    }

}

#Preview {
    ContentView2()
}
