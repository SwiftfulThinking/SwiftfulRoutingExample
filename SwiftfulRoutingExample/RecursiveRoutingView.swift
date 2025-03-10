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
    
    enum ViewState {
        case regular
        case testingSegues
        case testingMultiSegues
        case testingDismissing
        case testingMultiRouters
        case testingSegueQueue
    }
    
    var viewState: ViewState {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("UI_TESTING") {
            if arguments.contains("SEGUES") {
                return .testingSegues
            } else if arguments.contains("MULTISEGUES") {
                return .testingMultiSegues
            } else if arguments.contains("DISMISSING") {
                return .testingDismissing
            } else if arguments.contains("MULTIROUTER") {
                return .testingMultiRouters
            } else if arguments.contains("SEGUEQUEUE") {
                return .testingSegueQueue
            }
        }
        
        return .regular
    }
    
    var body: some View {
        List {
            Text("Screen Number: \(screenNumber)")
                .accessibilityIdentifier("Title_\(screenNumber)")

            Text("Last dismiss number: " + (lastDismiss >= 0 ? "\(lastDismiss)" : ""))
                .accessibilityIdentifier("LastDismiss_\(lastDismiss)")

            switch viewState {
            case .regular:
                Section("Segues") {
                    segueButtons
                }
                Section("Multi-Segues") {
                    multiSegueButtons
                }
                Section("Dismiss actions") {
                    dismissButtons(showAll: true)
                }
                Section("Multi-Routers") {
                    multiRouterButtons
                }
                Section("Segue Queue") {
                    queueButtons
                }
                Section("Resizable Sheets") {
                    resizableSheetButtons
                }
            case .testingSegues:
                segueButtons
                dismissButtons()
            case .testingMultiSegues:
                multiSegueButtons
                dismissButtons()
            case .testingDismissing:
                segueButtons
                dismissButtons(showAll: true)
            case .testingMultiRouters:
                multiRouterButtons
                dismissButtons(showAll: false)
            case .testingSegueQueue:
                queueButtons
                dismissButtons(showAll: false)
            }
        }
        .navigationTitle("\(screenNumber)")
        .navigationBarTitleDisplayMode(.inline)
//        .listStyle(PlainListStyle())
    }
    
    private func dismissAction(_ number: Int) {
        lastDismiss = number
    }
    
    private func performSegue(segue: SegueOption, location: SegueLocation = .insert, screenNumberOverride: Int? = nil, animates: Bool = true) {
        let screenNumber = (screenNumberOverride ?? screenNumber) + 1
        let screen = AnyDestination(
            id: "\(screenNumber)",
            segue: segue,
            location: location,
            animates: animates,
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
    
    private func performMultiSegue(segues: [SegueOption], animates: Bool = true) {
        var destinations: [AnyDestination] = []
        
        for (index, segue) in segues.enumerated() {
            let screenNumber = screenNumber + 1 + index
            let screen = AnyDestination(
                id: "\(screenNumber)",
                segue: segue,
                location: .insert,
                animates: animates,
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

        Button("Push (no animation)") {
            performSegue(segue: .push, animates: false)
        }
        
        Button("Sheet") {
            performSegue(segue: .sheet)
        }
        .accessibilityIdentifier("Button_Sheet")

        Button("Sheet (no animation)") {
            performSegue(segue: .sheet, animates: false)
        }

        Button("FullScreenCover") {
            performSegue(segue: .fullScreenCover)
        }
        .accessibilityIdentifier("Button_FullScreenCover")
        
        Button("FullScreenCover (no animation)") {
            performSegue(segue: .fullScreenCover, animates: false)
        }
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

        Button("Sheet 3x (no animation)") {
            performMultiSegue(segues: [.sheet, .sheet, .sheet], animates: false)
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
            Button("Dismiss (no animation)") {
                router.dismissScreen(animates: false)
            }

            Button("Dismiss screen 2") {
                router.dismissScreen(id: "2")
            }
            .accessibilityIdentifier("Button_DismissId2")

            Button("Dismiss to screen 1") {
                router.dismissScreens(upToScreenId: "1")
            }
            .accessibilityIdentifier("Button_DismissTo1")
            
            Button("Dismiss 2 screens") {
                router.dismissScreens(count: 2)
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
            
            Button("Dismiss all screens (no animation)") {
                router.dismissAllScreens(animates: false)
            }
        }
    }
    
    @ViewBuilder
    var multiRouterButtons: some View {
        // Appending screens from a previous router
        Button("Segue, then append screens") {
            performSegue(segue: .sheet, location: .append)
            
            Task {
                try? await Task.sleep(for: .seconds(1.1))
                performSegue(segue: .push, location: .append, screenNumberOverride: 1)
                try? await Task.sleep(for: .seconds(1.1))
                performSegue(segue: .fullScreenCover, location: .append, screenNumberOverride: 2)
                try? await Task.sleep(for: .seconds(1.1))
                performSegue(segue: .push, location: .append, screenNumberOverride: 3)
            }
        }
        .accessibilityIdentifier("Button_SegueAppend")

        // Inserting screens from a previous router
        Button("Segue, then insert push") {
            performSegue(segue: .sheet, location: .insert)
            
            Task {
                try? await Task.sleep(for: .seconds(1.1))
                performSegue(segue: .push, location: .insert, screenNumberOverride: 1)
                try? await Task.sleep(for: .seconds(1.1))
            }
        }
        .accessibilityIdentifier("Button_SegueInsertPush")
        
        Button("Segue, then insert sheet") {
            performSegue(segue: .sheet, location: .insert)
            
            Task {
                try? await Task.sleep(for: .seconds(1.1))
                performSegue(segue: .sheet, location: .insert, screenNumberOverride: 1)
                try? await Task.sleep(for: .seconds(1.1))
            }
        }
        .accessibilityIdentifier("Button_SegueInsertSheet")

        
        Button("Segue, then insert full") {
            performSegue(segue: .sheet, location: .insert)
            
            Task {
                try? await Task.sleep(for: .seconds(1.1))
                performSegue(segue: .fullScreenCover, location: .insert, screenNumberOverride: 1)
                try? await Task.sleep(for: .seconds(1.1))
            }
        }
        .accessibilityIdentifier("Button_SegueInsertFullScreenCover")

        Button("Insert after 1") {
            performMultiSegue(segues: [.sheet, .push, .push])
            
            Task {
                try? await Task.sleep(for: .seconds(1.1))
                performSegue(segue: .push, location: .insertAfter(id: "1"), screenNumberOverride: 3)
                try? await Task.sleep(for: .seconds(1.1))
            }
        }
        .accessibilityIdentifier("Button_SegueInsertFullScreenCover")
        
        Button("Test dismiss last screen") {
            performMultiSegue(segues: [.push, .sheet, .fullScreenCover, .push])
            
            Task {
                try? await Task.sleep(for: .seconds(2))
                router.dismissLastScreen()
            }
        }
        .accessibilityIdentifier("Button_DismissLastScreen")
        
        Button("Test dismiss last environment") {
            performMultiSegue(segues: [.push, .sheet, .fullScreenCover, .push])
            
            Task {
                try? await Task.sleep(for: .seconds(2))
                router.dismissLastEnvironment()
            }
        }
        .accessibilityIdentifier("Button_DismissLastEnvironment")

        Button("Test dismiss last push stack") {
            performMultiSegue(segues: [.push, .sheet, .fullScreenCover, .push, .push])
            
            Task {
                try? await Task.sleep(for: .seconds(2))
                router.dismissLastPushStack()
            }
        }
        .accessibilityIdentifier("Button_DismissLastPushStack")
    }

    @ViewBuilder
    var queueButtons:  some View {
        Button("Append 1 push to queue") {
            let number = 100
            let screen = AnyDestination(
                id: "\(number)",
                segue: .push,
                location: .append,
                animates: true,
                onDismiss: {
                    dismissAction(number)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: number
                    )
                }
            )
            router.addScreenToQueue(destination: screen)
        }
        .accessibilityIdentifier("Button_QueueAppend")
        
        Button("Insert 1 push to queue") {
            let number = 200
            let screen = AnyDestination(
                id: "\(number)",
                segue: .push,
                location: .insert,
                animates: true,
                onDismiss: {
                    dismissAction(number)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: number
                    )
                }
            )
            router.addScreenToQueue(destination: screen)
        }
        .accessibilityIdentifier("Button_QueueInsert")

        Button("Append 3 push to queue") {
            let screen1Number = 300
            let screen1 = AnyDestination(
                id: "\(screen1Number)",
                segue: .push,
                location: .append,
                animates: true,
                onDismiss: {
                    dismissAction(screen1Number)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: screen1Number
                    )
                }
            )
            
            let screen2Number = 301
            let screen2 = AnyDestination(
                id: "\(screen2Number)",
                segue: .push,
                location: .append,
                animates: true,
                onDismiss: {
                    dismissAction(screen2Number)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: screen2Number
                    )
                }
            )
            
            let screen3Number = 302
            let screen3 = AnyDestination(
                id: "\(screen3Number)",
                segue: .push,
                location: .append,
                animates: true,
                onDismiss: {
                    dismissAction(screen3Number)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: screen3Number
                    )
                }
            )
            router.addScreensToQueue(destinations: [screen1, screen2, screen3])
        }
        .accessibilityIdentifier("Button_QueueAppend3")

        Button("Remove screen 301 from queue") {
            router.removeScreenFromQueue(id: "301")
        }
        .accessibilityIdentifier("Button_QueueRemove1")
        
        Button("Remove screen 300 and 301 from queue") {
            router.removeScreensFromQueue(ids: ["300", "301"])
        }
        .accessibilityIdentifier("Button_QueueRemove2")

        Button("Clear queue") {
            router.clearQueue()
        }
        .accessibilityIdentifier("Button_QueueClear")

        Button("Try to show next screen") {
            try? router.showNextScreen()
        }
        .accessibilityIdentifier("Button_QueueNext")
    }
    
    @ViewBuilder
    var resizableSheetButtons: some View {
        Button("Resizable Sheet [.medium, .large]") {
            let config = ResizableSheetConfig(
                detents: [.medium, .large],
                selection: nil,
                dragIndicator: .visible
            )
            performSegue(segue: .resizableSheet(config: config))
        }

        Button("Resizable Sheet [.medium]") {
            let config = ResizableSheetConfig(
                detents: [.medium],
                selection: nil,
                dragIndicator: .visible
            )
            performSegue(segue: .resizableSheet(config: config))
        }
        
        Button("Resizable Sheet [.fraction(0.3, 0.5, 0.8)]") {
            let config = ResizableSheetConfig(
                detents: [.fraction(0.3), .fraction(0.5), .fraction(0.8)],
                selection: nil,
                dragIndicator: .visible
            )
            performSegue(segue: .resizableSheet(config: config))
        }
        
        Button("Resizable Sheet [.height(300, 500)]") {
            let config = ResizableSheetConfig(
                detents: [.height(300), .height(500)],
                selection: nil,
                dragIndicator: .visible
            )
            performSegue(segue: .resizableSheet(config: config))
        }
    }
}

#Preview {
    ContentView2()
}
