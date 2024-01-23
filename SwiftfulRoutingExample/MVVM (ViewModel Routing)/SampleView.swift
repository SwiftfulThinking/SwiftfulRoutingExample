//
//  SampleView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/29/23.
//

import SwiftUI
import SwiftfulRouting

@available(iOS 14, *)
struct SampleView: View {
    
    @StateObject var viewModel: SampleViewModel

    var body: some View {
        List {
            Button("Configure") {
                // Task can start in ViewModel
                viewModel.configure()
            }
            
            Button("Fetch w/ error") {
                // Task can start in View
                Task {
                    await viewModel.loadMoreInfo()
                }
            }
            
            Button("Push") {
                viewModel.continueButtonPressed()
            }
        }
        .navigationTitle(viewModel.title ?? "Click to start")
        .navigationBarTitleDisplayMode(.large)
    }
}

@available(iOS 14, *)
struct SampleView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView { (router, lastModuleId) in
            SampleView(viewModel: SampleViewModel(
                router: router,
                service: DataService()))
        }
    }
}
