////
////  BasicViewModel.swift
////  SwiftfulRoutingExample
////
////  Created by Nick Sarno on 1/29/23.
////
//
//import Foundation
//import SwiftfulRouting
//
//// This is the same as SampleViewModel, except data flows through a delegate to decouple ViewModel from DataService
//
//@MainActor
//final class BasicViewModel: ObservableObject {
//
//    private let router: AnyRouter
//    private let delegate: BasicViewModelDelegate
//    private var tasks: [Task<Void, Never>] = []
//
//    @Published private(set) var title: String? = nil
//    @Published private(set) var subtitle: String? = nil
//        
//    init(router: AnyRouter, delegate: BasicViewModelDelegate) {
//        self.router = router
//        self.delegate = delegate
//    }
//    
//    deinit {
//        tasks.forEach({ $0.cancel() })
//    }
//    
//    func configure() {
//        let task = Task {
//            do {
//                title = try await delegate.fetchTitle()
//            } catch {
//                showAlert(text: "Error on config.")
//            }
//        }
//        tasks.append(task)
//    }
//    
//    func loadMoreInfo() async {
//        do {
//            subtitle = try await delegate.fetchSubtitle()
//        } catch {
//            showAlert(text: "Error on fetch.")
//        }
//    }
//    
//    func continueButtonPressed() {
//        let task = Task {
//            do {
//                let title = try await delegate.fetchNextScreenTitle()
//                goToNextScreen(title: title)
//            } catch {
//                showAlert(text: "Error on push.")
//            }
//        }
//        tasks.append(task)
//    }
//    
//    private func showAlert(text: String) {
//        router.showBasicAlert(text: text)
//    }
//    
//    private func goToNextScreen(title: String) {
//        router.showScreen(.push) { router in
//            MyNextView(title: title)
//        }
//    }
//}
