//
//  HomeView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/29/23.
//

import SwiftUI

@available(iOS 14, *)
struct HomeView: View {
    
    @StateObject var presenter: HomePresenter
    
    var body: some View {
        List {
            Button("Configure") {
                // Task can start in ViewModel
                presenter.configure()
            }
            
            Button("Fetch w/ error") {
                // Task can start in View
                Task {
                    await presenter.loadMoreInfo()
                }
            }
            
            Button("Push") {
                presenter.continueButtonPressed()
            }
        }
        .navigationTitle(presenter.title ?? "Click to start")
        .navigationBarTitleDisplayMode(.large)
    }
}

import SwiftfulRouting

@available(iOS 14, *)
struct HomeView_Previews: PreviewProvider {
    static let interactor = HomeInteractor_Production(service: DataService())
    
    static var previews: some View {
        RouterView { (router, lastModuleId) in
            HomeView(presenter: HomePresenter(
                router: HomeRouter_Production(router: router),
                interactor: interactor))
        }
    }
}
