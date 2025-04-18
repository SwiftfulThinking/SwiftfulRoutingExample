//
//  ModuleSupportView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/16/25.
//


import Foundation
import SwiftUI
import SwiftfulRecursiveUI

struct ModuleSupportView<Content:View>: View {
    
    @StateObject private var viewModel = ModuleViewModel()

    let addNavigationStack: Bool
    @ViewBuilder var content: (AnyRouter) -> Content

    @State private var viewFrame: CGRect = UIScreen.main.bounds

    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: false, selection: viewModel.modules.last, items: viewModel.modules) { data in
                let dataIndex: Double = Double(viewModel.modules.firstIndex(where: { $0.id == data.id }) ?? 99)

                return Group {
                    if data == viewModel.modules.first {
                        RouterViewModelWrapper {
                            RouterViewInternal(
                                routerId: RouterViewModel.rootId,
                                addNavigationStack: addNavigationStack,
                                content: content
                            )
                        }
                    } else {
                        RouterViewModelWrapper {
                            RouterViewInternal(
                                routerId: RouterViewModel.rootId,
                                addNavigationStack: addNavigationStack,
                                content: { router in
                                    AnyView(data.destination(router))
                                }
                            )
                        }
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: viewModel.currentTransition.insertion,
                        removal: .customRemoval(
                            behavior: .removePrevious,
                            direction: viewModel.currentTransition.reversed,
                            frame: viewFrame
                        )
                    )
                )
                .zIndex(dataIndex)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(viewModel.currentTransition.animation, value: (viewModel.modules.last?.id ?? "") + viewModel.currentTransition.rawValue)
        .environmentObject(viewModel)
    }
}

//struct ModuleSupportView<Content:View>: View {
//    
//    let addNavigationView: Bool
//    let moduleDelegate: ModuleDelegate
//    let screens: Binding<[AnyDestination]>?
//
//    @Binding var selection: AnyTransitionWithDestination
//    let modules: [AnyTransitionWithDestination]
//    @ViewBuilder var content: (AnyRouter) -> Content
//    let currentTransition: TransitionOption
//    
//    var body: some View {
//        ZStack {
//            LazyZStack(allowSimultaneous: false, selection: selection, items: modules) { data in
//                if data == modules.first {
//                    RouterViewInternal(
//                        addNavigationView: addNavigationView,
//                        moduleDelegate: moduleDelegate,
//                        screens: screens,
//                        route: nil,
//                        routes: nil,
//                        environmentRouter: nil,
//                        content: content
//                    )
//                    .transition(
//                        .asymmetric(
//                            insertion: currentTransition.insertion,
//                            removal: .customRemoval(direction: currentTransition.reversed)
//                        )
//                    )
//                } else {
//                    RouterViewInternal(
//                        addNavigationView: addNavigationView,
//                        moduleDelegate: moduleDelegate,
//                        screens: screens,
//                        route: nil,
//                        routes: nil,
//                        environmentRouter: nil,
//                        content: { router in
//                            data.destination(router).destination
//                        }
//                    )
//                    .transition(
//                        .asymmetric(
//                            insertion: currentTransition.insertion,
//                            removal: .customRemoval(direction: currentTransition.reversed)
//                        )
//                    )
//                }
//            }
//            .animation(.easeInOut, value: selection.id)
//        }
//    }
//}
