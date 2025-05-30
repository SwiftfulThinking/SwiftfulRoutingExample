//
//  OverviewView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 3/29/25.
//
import SwiftfulRouting
import SwiftUI

struct OverviewView: View {
    
    @Environment(\.router) var router
    
    var body: some View {
        List {
            Section {
                Button("Segue Examples") {
                    let destination = AnyDestination(
                        segue: .push,
                        destination: { router in
                            RecursiveRoutingView(router: router, screenNumber: 0, viewState: .segueExamples)
                        }
                    )
                    
                    router.showScreen(destination)
                }
                
                Button("Segue Builder") {
                    let destination = AnyDestination(
                        segue: .push,
                        destination: { router in
                            SegueBuilderView()
                        }
                    )
                    router.showScreen(destination)
                }
            } header: {
                Text("Segues")
            }

            Section {
                Button("Alert Examples") {
                    let destination = AnyDestination(
                        segue: .push,
                        destination: { router in
                            RecursiveRoutingView(router: router, screenNumber: 0, viewState: .alertExamples)
                        }
                    )
                    
                    router.showScreen(destination)
                }
                
                Button("Alert Builder") {
                    let destination = AnyDestination(
                        segue: .push,
                        destination: { router in
                            AlertBuilderView()
                        }
                    )
                    router.showScreen(destination)
                }
            } header: {
                Text("Alerts")
            }
            
            Section {
                Button("Modal Examples") {
                    let destination = AnyDestination(
                        segue: .push,
                        destination: { router in
                            RecursiveRoutingView(router: router, screenNumber: 0, viewState: .modalExamples)
                        }
                    )
                    
                    router.showScreen(destination)
                }
                Button("Modal Builder") {
                    let destination = AnyDestination(
                        segue: .push,
                        destination: { router in
                            ModalBuilderView()
                        }
                    )
                    router.showScreen(destination)
                }
            } header: {
                Text("Modals")
            }

            Section {
                Button("Transition Examples (keepPrevious)") {
                    let destination = AnyDestination(
                        segue: .push,
                        destination: { router in
                            RecursiveRoutingView(router: router, screenNumber: 0, viewState: .transitionExamples)
                        }
                    )
                    
                    router.showScreen(destination)
                }
                Button("Transition Builder (keepPrevious)") {
                    let destination = AnyDestination(
                        segue: .push,
                        transitionBehavior: .keepPrevious,
                        destination: { router in
                            TransitionBuilderView()
                        }
                    )
                    router.showScreen(destination)
                }
                Button("Transition Examples (removePrevious)") {
                    let destination = AnyDestination(
                        segue: .push,
                        transitionBehavior: .removePrevious,
                        destination: { router in
                            RecursiveRoutingView(router: router, screenNumber: 0, viewState: .transitionExamples)
                        }
                    )
                    
                    router.showScreen(destination)
                }
                Button("Transition Builder (removePrevious)") {
                    let destination = AnyDestination(
                        segue: .push,
                        transitionBehavior: .removePrevious,
                        destination: { router in
                            TransitionBuilderView()
                        }
                    )
                    router.showScreen(destination)
                }
            } header: {
                Text("Transitions")
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.3)
        .navigationTitle("Overview")
    }
}

#Preview {
    RouterView { _ in
        OverviewView()
    }
}
