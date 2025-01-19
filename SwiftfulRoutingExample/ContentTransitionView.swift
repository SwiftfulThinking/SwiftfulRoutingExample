////
////  ContentTransitionView.swift
////  SwiftfulRoutingExample
////
////  Created by Nicholas Sarno on 8/22/24.
////
//
//import SwiftUI
//import SwiftfulRouting
//
//// TransitionSupportViewBuilder will be integrated into RouterView in a future release
//// Currently available as a separate component
//
//struct ContentTransitionView: View {
//    var body: some View {
//        RouterView { router in
//            TransitionSupportViewBuilder(router: router) { transitionRouter in
//                Rectangle().fill(Color.blue)
//                    .onTapGesture {
//                        transitionRouter.showTransition(transition: .trailing) { router2 in
//                            Rectangle().fill(Color.red)
//                                .onTapGesture {
//                                    transitionRouter.dismissTransition()
//                                }
//                        }
//                    }
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentTransitionView()
//}
