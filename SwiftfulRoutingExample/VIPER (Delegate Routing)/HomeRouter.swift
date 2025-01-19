////
////  HomeRouter.swift
////  SwiftfulRoutingExample
////
////  Created by Nick Sarno on 1/29/23.
////
//
//import Foundation
//import SwiftfulRouting
//
//protocol HomeRouter {
//    func showAlert(text: String)
//    func goToNextScreen(title: String)
//}
//
//struct HomeRouter_Production: HomeRouter {
//    let router: AnyRouter
//    
//    func showAlert(text: String) {
//        router.showBasicAlert(text: text)
//    }
//    
//    func goToNextScreen(title: String) {
//        router.showScreen(.push) { router in
//            MyNextView(title: title)
//        }
//    }
//}
//
//struct HomeRouter_Mock: HomeRouter {
//    let router: AnyRouter
//    
//    func showAlert(text: String) {
//        router.showBasicAlert(text: text)
//    }
//    
//    func goToNextScreen(title: String) {
//        router.showScreen(.push) { router in
//            MyNextView(title: title)
//        }
//    }
//}
