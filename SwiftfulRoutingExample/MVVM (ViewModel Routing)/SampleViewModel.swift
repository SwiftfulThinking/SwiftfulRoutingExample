////
////  SampleViewModel.swift
////  SwiftfulRoutingExample
////
////  Created by Nick Sarno on 1/29/23.
////
//
//import Foundation
//import SwiftfulRouting
//
//@MainActor
//final class SampleViewModel: ObservableObject {
//
//    private let router: AnyRouter
//    private let service: DataService
//    private var tasks: [Task<Void, Never>] = []
//
//    @Published private(set) var title: String? = nil
//    @Published private(set) var subtitle: String? = nil
//        
//    init(router: AnyRouter, service: DataService) {
//        self.router = router
//        self.service = service
//    }
//    
//    deinit {
//        tasks.forEach({ $0.cancel() })
//    }
//    
//    func configure() {
//        let task = Task {
//            do {
//                title = try await service.fetchTitle()
//            } catch {
//                showAlert(text: "Error on config.")
//            }
//        }
//        tasks.append(task)
//    }
//    
//    func loadMoreInfo() async {
//        do {
//            subtitle = try await service.fetchSubtitle()
//        } catch {
//            showAlert(text: "Error on fetch.")
//        }
//    }
//    
//    func continueButtonPressed() {
//        let task = Task {
//            do {
//                let title = try await service.fetchNextScreenTitle()
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
