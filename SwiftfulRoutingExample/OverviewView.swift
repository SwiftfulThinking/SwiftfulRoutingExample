//
//  OverviewView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 3/29/25.
//

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
