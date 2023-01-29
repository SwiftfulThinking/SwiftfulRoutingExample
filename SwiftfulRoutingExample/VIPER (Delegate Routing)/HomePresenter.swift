//
//  HomePresenter.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/29/23.
//

import Foundation
import SwiftfulRouting

// Presenter in VIPER == ViewModel in MVVM

@MainActor
final class HomePresenter: ObservableObject {

    private let router: HomeRouter
    private let interactor: HomeInteractor
    private var tasks: [Task<Void, Never>] = []

    @Published private(set) var title: String? = nil
    @Published private(set) var subtitle: String? = nil
        
    init(router: HomeRouter, interactor: HomeInteractor) {
        self.router = router
        self.interactor = interactor
    }
    
    deinit {
        tasks.forEach({ $0.cancel() })
    }
    
    func configure() {
        let task = Task {
            do {
                title = try await interactor.fetchTitle()
            } catch {
                router.showAlert(text: "Error on config.")
            }
        }
        tasks.append(task)
    }
    
    func loadMoreInfo() async {
        do {
            subtitle = try await interactor.fetchSubtitle()
        } catch {
            router.showAlert(text: "Error on fetch.")
        }
    }
    
    func continueButtonPressed() {
        let task = Task {
            do {
                let title = try await interactor.fetchNextScreenTitle()
                router.goToNextScreen(title: title)
            } catch {
                router.showAlert(text: "Error on push.")
            }
        }
        tasks.append(task)
    }
}
