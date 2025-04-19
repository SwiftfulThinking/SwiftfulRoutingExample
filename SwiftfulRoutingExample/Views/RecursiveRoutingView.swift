//
//  RecursiveRoutingView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 3/4/25.
//
import SwiftfulRouting
import SwiftUI

struct ContentView2: View {
    var body: some View {
        RouterView { router in
            RecursiveRoutingView(router: router, screenNumber: 0, viewState: viewState)
        }
    }
    
    var viewState: RecursiveRoutingView.ViewState {
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
            } else if arguments.contains("MODALS") {
                return .testingModals
            } else if arguments.contains("TRANSITIONS") {
                return .testingTransitions
            } else if arguments.contains("TRANSITIONQUEUE") {
                return .testingTransitionQueue
            }
        }
        
        return .regular
    }

}

struct RecursiveRoutingView: View {
    
    let router: AnyRouter
    let screenNumber: Int
    var viewState: ViewState = .regular
    
    @State private var lastDismiss: Int = -1
    @Namespace private var namespace
    
    enum ViewState {
        case regular // tbr
        
        case segueExamples
        case alertExamples
        case modalExamples
        case transitionExamples

        case testingSegues
        case testingMultiSegues
        case testingDismissing
        case testingMultiRouters
        case testingSegueQueue
        case testingModals
        case testingTransitions
        case testingTransitionQueue
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
                Section("Custom Sheets") {
                    customSheetButtons
                }
                Section("Alerts") {
                    alertButtons
                }
                Section("Modals") {
                    modalButtons
                }
                Section("Dismiss modal actions") {
                    dismissModalButtons
                }
                Section("Transitions") {
                    transitionButtons
                }
                Section("Dismiss transition actions") {
                    
                }
                
            // SEGUES
            case .segueExamples:
                Section("Segues") {
                    segueButtons
                }
                Section("Dismiss actions") {
                    dismissButtons(showAll: true)
                }
                Section("Multi-Segues") {
                    multiSegueButtons
                }
                Section("Multi-Routers") {
                    multiRouterButtons
                }
                Section("Segue Queue") {
                    queueButtons
                }
                Section("Modules") {
                    moduleButtons
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
            case .testingSegueQueue:
                queueButtons
                dismissButtons(showAll: false)

            // MODALS
            case .modalExamples:
                Section("Modals") {
                    modalButtons
                }
                Section("Dismiss actions") {
                    dismissModalButtons
                }
            case .testingModals:
                modalButtons
                dismissModalButtons
                
            // ALERTS
            case .alertExamples:
                Section("Alerts") {
                    alertButtons
                }
            
            case .testingMultiRouters:
                multiRouterButtons
                dismissButtons(showAll: false)
            
            // TRANSITIONS
            case .transitionExamples:
                Section("Transitions") {
                    transitionButtons
                }
                Section("Dismiss transition actions") {
                    dismissTransitionButtons
                }
                Section("Transition queue") {
                    transitionQueueButtons
                }
            case .testingTransitions:
                transitionButtons
                dismissTransitionButtons
                
            case .testingTransitionQueue:
                transitionQueueButtons
                dismissTransitionButtons

            }
        }
        .navigationTitle("\(screenNumber)")
        .navigationBarTitleDisplayMode(.inline)
//        .listStyle(PlainListStyle())
    }
    
    private func dismissAction(_ number: Int) {
        lastDismiss = number
    }
    
    private func performSegue(segue: SegueOption, location: SegueLocation = .insert, screenNumberOverride: Int? = nil, animates: Bool = true, hideListBackground: Bool = false) {
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
                    screenNumber: screenNumber,
                    viewState: viewState
                )
                .ifSatisfiesCondition(hideListBackground) { content in
                    content
                        .scrollContentBackground(.hidden)
                }
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
                        screenNumber: screenNumber,
                        viewState: viewState
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

        if viewState == .segueExamples {
            Button("Push (no animation)") {
                performSegue(segue: .push, animates: false)
            }
        }
        
        Button("Sheet") {
            performSegue(segue: .sheet)
        }
        .accessibilityIdentifier("Button_Sheet")

        if viewState == .segueExamples {
            Button("Sheet (no animation)") {
                performSegue(segue: .sheet, animates: false)
            }
        }

        Button("FullScreenCover") {
            performSegue(segue: .fullScreenCover)
        }
        .accessibilityIdentifier("Button_FullScreenCover")
        
        if viewState == .segueExamples {
            Button("FullScreenCover (no animation)") {
                performSegue(segue: .fullScreenCover, animates: false)
            }
        }
        
        if #available(iOS 18.0, *), viewState == .segueExamples {
            Button("Zoom (ie. push w/ navigationTransition)") {
                let screenNumber = screenNumber + 1
                let screen = AnyDestination(
                    id: "\(screenNumber)",
                    segue: .push,
                    onDismiss: {
                        dismissAction(screenNumber)
                    },
                    destination: { router in
                        RecursiveRoutingView(
                            router: router,
                            screenNumber: screenNumber,
                            viewState: viewState
                        )
                        .navigationTransition(.zoom(sourceID: "\(screenNumber)", in: namespace))
                    }
                )
                
                router.showScreen(screen)
            }
            .matchedTransitionSource(id: "\(screenNumber + 1)", in: namespace)
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
            
            if viewState == .segueExamples {
                Button("Dismiss all screens (no animation)") {
                    router.dismissAllScreens(animates: false)
                }
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
                        screenNumber: number,
                        viewState: viewState
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
                        screenNumber: number,
                        viewState: viewState
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
                        screenNumber: screen1Number,
                        viewState: viewState
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
                        screenNumber: screen2Number,
                        viewState: viewState
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
                        screenNumber: screen3Number,
                        viewState: viewState
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

        Button("Clear screen queue") {
            router.removeAllScreensFromQueue()
        }
        .accessibilityIdentifier("Button_QueueClear")

        Button("Try to show next screen") {
            router.showNextScreen()
        }
        .accessibilityIdentifier("Button_QueueNext")
    }
    
    @ViewBuilder
    var customSheetButtons: some View {
        Button("Resizable Sheet [.medium, .large]") {
            let config = ResizableSheetConfig(
                detents: [.medium, .large],
                selection: nil,
                dragIndicator: .visible
            )
            performSegue(segue: .sheetConfig(config: config))
        }

        Button("Resizable Sheet [.medium]") {
            let config = ResizableSheetConfig(
                detents: [.medium],
                selection: nil,
                dragIndicator: .visible
            )
            performSegue(segue: .sheetConfig(config: config))
        }
        
        Button("Resizable Sheet [.fraction(0.3, 0.5, 0.8)]") {
            let config = ResizableSheetConfig(
                detents: [.fraction(0.3), .fraction(0.5), .fraction(0.8)],
                selection: nil,
                dragIndicator: .visible
            )
            performSegue(segue: .sheetConfig(config: config))
        }
        
        Button("Resizable Sheet [.height(300, 500)]") {
            let config = ResizableSheetConfig(
                detents: [.height(300), .height(500)],
                selection: nil,
                dragIndicator: .visible
            )
            performSegue(segue: .sheetConfig(config: config))
        }
        
        Button("Sheet: Background color") {
            let config = ResizableSheetConfig(
                detents: [.medium, .large],
                selection: nil,
                dragIndicator: .visible,
                background: .custom(LinearGradient(colors: [.red, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)),
                cornerRadius: 100,
                backgroundInteraction: .disabled,
                contentInteraction: .automatic
            )
            performSegue(segue: .sheetConfig(config: config), hideListBackground: true)
        }
        
        Button("Sheet: No background") {
            let config = ResizableSheetConfig(
                detents: [.medium],
                selection: nil,
                dragIndicator: .hidden,
                background: .clear,
                cornerRadius: 0,
                backgroundInteraction: .enabled,
                contentInteraction: .automatic
            )
            
            let destination = AnyDestination(segue: .sheetConfig(config: config)) { router in
                Rectangle()
                    .padding(40)
                    .onTapGesture {
                        router.dismissScreen()
                    }
            }
            
            router.showScreen(destination)
        }
        
        Button("FullScreenColor: Background color") {
            let config = FullScreenCoverConfig(background: .custom(Color.orange))
            performSegue(segue: .fullScreenCoverConfig(config: config), hideListBackground: true)
        }
        
        Button("FullScreenColor: Background clear") {
            let config = FullScreenCoverConfig(background: .clear)
            
            let destination = AnyDestination(segue: .fullScreenCoverConfig(config: config)) { router in
                Rectangle()
                    .padding(40)
                    .onTapGesture {
                        router.dismissScreen()
                    }
            }

            router.showScreen(destination)
        }
    }
    
    @ViewBuilder
    var alertButtons: some View {
        Button("Alert 1") {
            let alert = AnyAlert(style: .alert, title: "Title goes here", subtitle: "Subtitle goes here", buttons: {
                Button("Alpha", role: .none, action: {
                    
                })
                Button("Beta", role: .destructive, action: {
                    
                })
                Button("Gamma", role: .cancel, action: {
                    
                })
            })
            router.showAlert(alert: alert)
        }
        
        Button("Alert 2") {
            router.showAlert(.alert, title: "Title goes here", subtitle: "Subtitle goes here")
        }
        
        Button("Alert (simple)") {
            router.showSimpleAlert(text: "Hello!", action: nil)
        }
        
        Button("Alert (textfield)") {
            
            var textfieldText: String = "" // Note: could also be a @Binding at the top of SwiftUI View
            
            let alert = AnyAlert(style: .alert, title: "Title goes here", subtitle: "Subtitle goes here", buttons: {
                TextField("Enter your name", text: Binding(get: {
                    textfieldText
                }, set: { newValue in
                    textfieldText = newValue
                }))
                
                Button("SUBMIT", action: {
                    print(textfieldText)
                })
            })
            
            router.showAlert(alert: alert)
        }
        
        Button("ConfirmationDialog 1") {
            let alert = AnyAlert(style: .confirmationDialog, title: "Title goes here", subtitle: "Subtitle goes here", buttons: {
                Button("Alpha", role: .none, action: {
                    
                })
                Button("Beta", role: .destructive, action: {
                    
                })
                Button("Gamma", role: .cancel, action: {
                    
                })
            })
            router.showAlert(alert: alert)
        }
        
        Button("ConfirmationDialog 2") {
            router.showAlert(.confirmationDialog, title: "Title goes here", subtitle: "Subtitle goes here")
        }
    }
    
    private func modalView(id: String = UUID().uuidString, width: CGFloat? = 275, height: CGFloat? = 450) -> some View {
        Text("Tap to dismiss \(id)")
            .frame(maxWidth: width == nil ? .infinity : nil, maxHeight: height == nil ? .infinity : nil)
            .frame(width: width, height: height)
            .background(Color.blue)
            .cornerRadius(10)
            .onTapGesture {
                router.dismissModal()
            }
            .accessibilityIdentifier("Modal_\(id)")
    }
    
    private func triggerModal1() {
        let modal = AnyModal(
            id: "modal_1",
            transition: .opacity,
            animation: .smooth(duration: 0.3),
            alignment: .center,
            backgroundColor: Color.black.opacity(0.4),
            dismissOnBackgroundTap: true,
            ignoreSafeArea: true,
            destination: {
                modalView(id: "1")
            }
        )
        router.showModal(modal: modal)
    }
    
    private func triggerModal2() {
        let modal = AnyModal(
            id: "modal_2",
            transition: .scale,
            animation: .smooth(duration: 0.7),
            alignment: .center,
            backgroundColor: nil,
            dismissOnBackgroundTap: false,
            ignoreSafeArea: false, // Note: scale doesn't work well if this is true
            destination: {
                modalView(id: "2")
            }
        )
        router.showModal(modal: modal)
    }
    
    private func triggerModal3() {
        let modal = AnyModal(
            id: "modal_3",
            transition: .move(edge: .bottom),
            animation: .smooth(duration: 0.7),
            alignment: .bottom,
            backgroundColor: Color.orange.opacity(0.4),
            dismissOnBackgroundTap: true,
            ignoreSafeArea: true,
            destination: {
                modalView(id: "3", width: nil, height: 400)
            }
        )
        router.showModal(modal: modal)
    }
    
    @ViewBuilder
    var modalButtons: some View {
        Button("Modal: opacity, center, background") {
            triggerModal1()
        }
        .accessibilityIdentifier("Button_Modal1")
        
        Button("Modal: scale, center, no background") {
            triggerModal2()
        }
        .accessibilityIdentifier("Button_Modal2")

        Button("Modal: bottom (ex. 1)") {
            triggerModal3()
        }
        .accessibilityIdentifier("Button_Modal3")

        if viewState != .testingModals {
            Button("Modal: bottom (ex. 2) (bg color + blur)") {
                let modal = AnyModal(
                    transition: .move(edge: .bottom),
                    animation: .spring(),
                    alignment: .center,
                    backgroundColor: Color.orange.opacity(0.4),
                    backgroundEffect: BackgroundEffect(effect: UIBlurEffect(style: .systemMaterialDark), intensity: 0.1),
                    dismissOnBackgroundTap: true,
                    ignoreSafeArea: true,
                    destination: {
                        modalView(width: 300, height: 400)
                    }
                )
                router.showModal(modal: modal)
            }
            
            Button("Modal: top (ex. 1)") {
                let modal = AnyModal(
                    transition: .move(edge: .top),
                    animation: .easeInOut,
                    alignment: .top,
                    backgroundColor: nil,
                    dismissOnBackgroundTap: true,
                    ignoreSafeArea: true,
                    destination: {
                        modalView(width: nil, height: 200)
                    }
                )
                router.showModal(modal: modal)
            }
            
            Button("Modal: top (ex. 2)") {
                let modal = AnyModal(
                    transition: .move(edge: .top),
                    animation: .easeInOut,
                    alignment: .top,
                    backgroundColor: nil,
                    dismissOnBackgroundTap: true,
                    ignoreSafeArea: false,
                    destination: {
                        modalView(width: nil, height: 150)
                            .padding(24)
                    }
                )
                router.showModal(modal: modal)
            }
            
            Button("Modal: leading (ex. 1)") {
                let modal = AnyModal(
                    transition: .move(edge: .leading),
                    animation: .smooth,
                    alignment: .leading,
                    backgroundColor: Color.black.opacity(0.35),
                    dismissOnBackgroundTap: true,
                    ignoreSafeArea: true,
                    destination: {
                        modalView(width: 200, height: nil)
                    }
                )
                router.showModal(modal: modal)
            }
            
            Button("Modal: trailing (ex. 1)") {
                let modal = AnyModal(
                    transition: .move(edge: .trailing),
                    animation: .smooth,
                    alignment: .leading,
                    backgroundColor: Color.black.opacity(0.35),
                    dismissOnBackgroundTap: true,
                    ignoreSafeArea: false,
                    destination: {
                        modalView(width: nil, height: nil)
                            .padding(24)
                    }
                )
                router.showModal(modal: modal)
            }
        }
                
        Button("2 modals (layered)") {
            let modal1 = AnyModal(
                transition: AnyTransition.move(edge: .leading).animation(.easeInOut),
                backgroundColor: Color.blue.opacity(0.7),
                ignoreSafeArea: false,
                destination: {
                    Text("Sample")
                        .frame(width: 275, height: 450)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .offset(x: -100)
                        .onTapGesture {
                            router.dismissModal()
                        }
                        .accessibilityIdentifier("Modal_Alpha")
                }
            )
            
            let modal2 = AnyModal(
                transition: AnyTransition.move(edge: .trailing).animation(.easeInOut),
                backgroundColor: Color.red.opacity(0.7),
                ignoreSafeArea: false,
                destination: {
                    Text("Sample2")
                        .frame(width: 275, height: 450)
                        .background(Color.red)
                        .cornerRadius(10)
                        .offset(x: 100)
                        .onTapGesture {
                            router.dismissModal()
                        }
                        .accessibilityIdentifier("Modal_Beta")
                }
            )
            
            // Note: the background of the 2nd modal should be above the background of 1st modal
            router.showModals(modals: [modal1, modal2])
        }
        .accessibilityIdentifier("Button_2Modals")

    }
    
    @ViewBuilder
    var dismissModalButtons: some View {
        Button("Dismiss") {
            router.dismissModal()
        }
        .accessibilityIdentifier("Button_DismissModal")

        Button("Dismiss modal_1") {
            Task {
                triggerModal1()
                try? await Task.sleep(for: .seconds(2))
                router.dismissModal(id: "modal_1")
            }
        }
        .accessibilityIdentifier("Button_DismissModalId1")

        Button("Dismiss modal_1 (2)") {
            Task {
                triggerModal1()
                triggerModal3()
                try? await Task.sleep(for: .seconds(2))
                router.dismissModal(id: "modal_1")
            }
        }
        .accessibilityIdentifier("Button_DismissModalId1_under")

        Button("Dismiss to 2 modals") {
            Task {
                triggerModal1()
                triggerModal2()
                triggerModal3()
                try? await Task.sleep(for: .seconds(2))
                router.dismissModals(count: 2)
            }
        }
        .accessibilityIdentifier("Button_Dismiss2Modals")
        
        Button("Dismiss up to modal_1") {
            Task {
                triggerModal1()
                triggerModal2()
                triggerModal3()
                try? await Task.sleep(for: .seconds(2))
                router.dismissModals(upToModalId: "modal_1")
            }
        }
        .accessibilityIdentifier("Button_DismissModalsUpTo1")

        Button("Dismiss all modals") {
            Task {
                triggerModal1()
                triggerModal2()
                triggerModal3()
                try? await Task.sleep(for: .seconds(2))
                router.dismissAllModals()
            }
        }
        .accessibilityIdentifier("Button_DismissAllModals")
    }
    
    private func triggerTransition(transition: TransitionOption, allowsSwipeBack: Bool = true) {
        let screenNumber = screenNumber + 1
        let transition = AnyTransitionDestination(
            id: "\(screenNumber)",
            transition: transition,
            allowsSwipeBack: allowsSwipeBack
        ) { router in
            RecursiveRoutingView(
                router: router,
                screenNumber: screenNumber,
                viewState: viewState
            )
        }
        router.showTransition(transition: transition)
    }
                  
    @ViewBuilder
    var transitionButtons: some View {
        Button("trailing") {
            triggerTransition(transition: .trailing, allowsSwipeBack: false)
        }
        .accessibilityIdentifier("Button_TransitionTrailing")

        Button("trailing w/ swipe back") {
            triggerTransition(transition: .trailing)
        }
        Button("leading") {
            triggerTransition(transition: .leading, allowsSwipeBack: false)
        }
        .accessibilityIdentifier("Button_TransitionLeading")

        Button("leading w/ swipe back") {
            triggerTransition(transition: .leading)
        }
        Button("top") {
            triggerTransition(transition: .top)
        }
        .accessibilityIdentifier("Button_TransitionTop")

        Button("bottom") {
            triggerTransition(transition: .bottom)
        }
        Button("identity") {
            triggerTransition(transition: .identity)
        }
        
        Button("Transitions 3x + dismiss 2x") {
            Task {
                let transition = AnyTransitionDestination(id: "transition_1", transition: .trailing) { router in
                    Rectangle()
                        .fill(Color.green)
                        .ignoresSafeArea()
                        .onTapGesture {
                            router.dismissTransition()
                        }
                }
//                router.showTransition(transition: transition)
                
//                try? await Task.sleep(for: .seconds(1))
                
                let transition2 = AnyTransitionDestination(id: "transition_2", transition: .trailing) { router in
                    Rectangle()
                        .fill(Color.orange)
                        .ignoresSafeArea()
                        .onTapGesture {
                            router.dismissTransition()
                        }
                }
//                router.showTransition(transition: transition2)
                
//                try? await Task.sleep(for: .seconds(1))

                let transition3 = AnyTransitionDestination(id: "transition_3", transition: .trailing) { router in
                    Rectangle()
                        .fill(Color.red)
                        .ignoresSafeArea()
                        .onTapGesture {
                            router.dismissTransition()
                        }
                }
//                router.showTransition(transition: transition3)
                router.showTransitions(transitions: [transition, transition2, transition3])
                
                try? await Task.sleep(for: .seconds(1))

//                router.dismissTransitions(toScreenId: "transition_1")
//                router.dismissTransitions(count: 100)
//                router.dismissAllTransitions()
                router.dismissTransition()
                try? await Task.sleep(for: .seconds(1))
                router.dismissTransition()
                try? await Task.sleep(for: .seconds(1))
                router.dismissTransition()
            }
        }
//        .accessibilityIdentifier("Button_DismissModal")
//
        
        Button("2 Transitions") {
            let number1 = 700
            let transition1 = AnyTransitionDestination(
                id: "\(number1)",
                transition: .trailing,
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: number1,
                        viewState: viewState
                    )
                }
            )
            let number2 = number1 + 1
            let transition2 = AnyTransitionDestination(
                id: "\(number2)",
                transition: .trailing,
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: number2,
                        viewState: viewState
                    )
                }
            )
            
            // Note: the background of the 2nd modal should be above the background of 1st modal
            router.showTransitions(transitions: [transition1, transition2])
        }
        .accessibilityIdentifier("Button_2Transitions")
    }
    
    @ViewBuilder
    var dismissTransitionButtons: some View {
        Button("Dismiss transition") {
            router.dismissTransition()
        }
        .accessibilityIdentifier("Button_DismissTransition")

        Button("Dismiss transition 1") {
            router.dismissTransition(id: "1")
        }
        .accessibilityIdentifier("Button_DismissTransitionId1")

        Button("Dismiss up to transition 1") {
            router.dismissTransitions(upToId: "1")
        }
        .accessibilityIdentifier("Button_DismissupToTransition1")

        Button("Dismiss to 2 transitions") {
            router.dismissTransitions(count: 2)
        }
        .accessibilityIdentifier("Button_Dismiss2Transitions")

        Button("Dismiss all transitions") {
            router.dismissAllTransitions()
        }
        .accessibilityIdentifier("Button_DismissAllTransitions")
    }

    @ViewBuilder
    var transitionQueueButtons:  some View {
        Button("Append 1 transition to queue") {
            let number = 100
            let screen = AnyTransitionDestination(
                id: "\(number)",
                transition: .trailing,
                allowsSwipeBack: false,
                onDismiss: {
                    dismissAction(number)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: number,
                        viewState: viewState
                    )
                }
            )
            
            router.addTransitionToQueue(transition: screen)
        }
        .accessibilityIdentifier("Button_TransitionQueueAppend")

        Button("Append 3 push to queue") {
            let screen1Number = 300
            let screen1 = AnyTransitionDestination(
                id: "\(screen1Number)",
                transition: .trailing,
                allowsSwipeBack: false,
                onDismiss: {
                    dismissAction(screen1Number)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: screen1Number,
                        viewState: viewState
                    )
                }
            )
                        
            let screen2Number = 301
            let screen2 = AnyTransitionDestination(
                id: "\(screen2Number)",
                transition: .trailing,
                allowsSwipeBack: false,
                onDismiss: {
                    dismissAction(screen2Number)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: screen2Number,
                        viewState: viewState
                    )
                }
            )
            
            
            let screen3Number = 302
            let screen3 = AnyTransitionDestination(
                id: "\(screen3Number)",
                transition: .trailing,
                allowsSwipeBack: false,
                onDismiss: {
                    dismissAction(screen3Number)
                },
                destination: { router in
                    RecursiveRoutingView(
                        router: router,
                        screenNumber: screen3Number,
                        viewState: viewState
                    )
                }
            )
            
            router.addTransitionsToQueue(transitions: [screen1, screen2, screen3])
        }
        .accessibilityIdentifier("Button_TransitionQueueAppend3")
//
        Button("Remove transition 301 from queue") {
            router.removeTransitionFromQueue(id: "301")
        }
        .accessibilityIdentifier("Button_TransitionQueueRemove1")
        
        Button("Remove transitions 300 and 301 from queue") {
            router.removeTransitionsFromQueue(ids: ["300", "301"])
        }
        .accessibilityIdentifier("Button_TransitionQueueRemove2")

        Button("Clear screen queue") {
            router.removeAllTransitionsFromQueue()
        }
        .accessibilityIdentifier("Button_TransitionQueueClear")

        Button("Try to show next transition") {
            router.showNextTransition()
        }
        .accessibilityIdentifier("Button_TransitionQueueNext")
    }

    @ViewBuilder
    var moduleButtons: some View {
        Button("Switch to Onboarding Module") {
            Task {
                router.dismissAllScreens()

                try? await Task.sleep(for: .seconds(1))
                
                router.showModule(.trailing, id: "onboarding") { _ in
                    OnboardingView()
                }
            }
        }
    }
}

#Preview {
    ContentView2()
}
