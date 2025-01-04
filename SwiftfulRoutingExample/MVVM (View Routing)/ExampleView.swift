//
//  ExampleView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/29/23.
//

import SwiftUI
//import SwiftfulRouting

@available(iOS 14, *)
struct ExampleView: View {
    
    let router: AnyRouter
    @StateObject var viewModel: ExampleViewModel

    var body: some View {
        List {
            Button("Configure") {
                Task {
                    do {
                        try await viewModel.configure()
                    } catch {
                        showAlert(text: "Error on config.")
                    }
                }
            }
            
            Button("Fetch w/ error") {
                Task {
                    do {
                        try await viewModel.loadMoreInfo()
                    } catch {
                        showAlert(text: "Error on fetch.")
                    }
                }
            }
            
            Button("Push") {
                Task {
                    do {
                        let title = try await viewModel.continueButtonPressed()
                        goToNextScreen(title: title)
                    } catch {
                        showAlert(text: "Error on push.")
                    }
                }
            }
        }
        .navigationTitle(viewModel.title ?? "Click to start")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func showAlert(text: String) {
        router.showBasicAlert(text: text)
    }
    
    private func goToNextScreen(title: String) {
        router.showScreen(.push) { router in
            Text(title)
        }
    }
}

@available(iOS 14, *)
struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView { router in
            ExampleView(
                router: router,
                viewModel: ExampleViewModel(service: DataService())
            )
        }
    }
}
