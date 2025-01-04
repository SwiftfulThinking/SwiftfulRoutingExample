//
//  BasicView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/29/23.
//

import SwiftUI

@available(iOS 14, *)
struct BasicView: View {
    
    @StateObject var viewModel: BasicViewModel

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

//import SwiftfulRouting

@available(iOS 14, *)
struct BasicView_Previews: PreviewProvider {
    
    static let delegate = BasicViewModelDelegate_Production(service: DataService())
    
    static var previews: some View {
        RouterView { router in
            BasicView(viewModel: BasicViewModel(
                router: router,
                delegate: delegate))
        }
    }
    
}
