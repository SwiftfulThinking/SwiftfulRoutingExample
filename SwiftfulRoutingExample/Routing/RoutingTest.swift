////
////  RoutingTest.swift
////  SwiftfulRoutingExample
////
////  Created by Nick Sarno on 1/19/25.
////
//
//import SwiftUI
//
//struct RoutingTest: View {
//    var body: some View {
//        RouterView(logger: true) { router in
//            Button("Click me 1") {
//                
//                let destination = AnyDestination(
////                    id: T##String,
//                    segue: .sheet,
////                    location: T##SegueLocation,
////                    animates: T##Bool,
////                    onDismiss: T##(() -> Void)?##(() -> Void)?##() -> Void,
//                    destination: { router in
//                        Color.red.ignoresSafeArea()
//                    }
//                )
//                
//                router.showScreen(destination)
//                
////                var firstRouter: AnyRouter? = nil
////                let screen1 = AnyDestination(id: "screen_1", segue: .push, destination: { router in
////                    firstRouter = router
////                    return Color.red.ignoresSafeArea()
////                })
////
////                let screen2 = AnyDestination(id: "screen_2", segue: .sheet, destination: { router in
////                    Color.blue.ignoresSafeArea()
////                        .onTapGesture {
////                            firstRouter?.showScreen(id: "adsf", segue: .push, location: .insert, destination: { _ in
////                                Color.orange.ignoresSafeArea()
////                                    .onTapGesture {
////                                        router.dismissLastScreen()
////                                    }
////                            })
////                        }
////                })
//                
////                let screen3 = AnyDestination(id: "screen_3", segue: .fullScreenCover, { router in
////                    Color.orange.ignoresSafeArea()
////                }, onDismiss: nil)
////                
////                let screen4 = AnyDestination(id: "screen_4", segue: .push, { router in
////                    Color.pink.ignoresSafeArea()
////                }, onDismiss: nil)
//
//
////                router.showScreens(destinations: [screen1, screen2]) // screen3, screen4
//                
//                
//                
////                let destination1 = AnyDestination(id: "screen_2", segue: .sheet, { router2 in
////                    Button("Click me 2") {
////                        let destination2 = AnyDestination(id: "screen_3", segue: .push, { router3 in
////                            Button("Click me 3") {
////                                let destination3 = AnyDestination(id: "screen_4", segue: .push, { router4 in
////                                    Button("Click me 4") {
////                                        router4.dismissPushStack()
////                                    }
////                                    
////                                }, onDismiss: nil)
////                                
////                                router3.showScreen(destination: destination3)
////                            }
////                        }, onDismiss: nil)
////                        
////                        router2.showScreen(destination: destination2)
////                    }
////                }, onDismiss: nil)
////                
////                router.showScreen(destination: destination1)
//            }
//        }
//                
////                router.showScreen(segue: .sheet, id: "screen_2") { router2 in
////                    Button("Click me 2") {
//////                        router2.dismissScreen()
////                        router2.showScreen(segue: .push, id: "screen_3") { router3 in
////                            Button("Click me 3") {
////                                router3.showScreen(segue: .push, id: "screen_4") { router4 in
////                                    Button("Click me 4") {
//////                                        router2.dismissScreen()
//////                                        router4.dismissScreen()
//////                                        router2.dismissLastScreen()
//////                                        router4.dismissScreens(to: "screen_2")
//////                                        router4.dismissScreens(count: 2)
////                                        router4.dismissPushStack()
////                                        //                                        router4.dismissScreen()
////                                    }
////                                }
////                            }
////                        }
////                    }
////                }
////            }
////        }
//    }
//}
//
//#Preview {
//    RoutingTest()
//}
//
////struct NavigationStackIfNeeded<Content:View>: View {
////    
////    @Bindable var viewModel: RouterViewModel
////    let addNavigationStack: Bool
////    var routerId: String
////    @ViewBuilder var content: Content
////    
////    @ViewBuilder var body: some View {
////        if addNavigationStack {
////            // The routerId would be the .sheet, so bind to the next .push stack after
////            NavigationStack(path: Binding(stack: viewModel.activeScreenStacks, routerId: routerId, onDidDismiss: <#T##(AnyDestination?) -> Void##(AnyDestination?) -> Void##(_ lastRouteRemaining: AnyDestination?) -> Void#>)) {
////                content
////            }
////        } else {
////            content
////        }
////    }
////}
//
//
//
//
//
////struct NavigationDestinationViewModifier: ViewModifier {
////    
////    var addNavigationDestination: Bool
////
////    func body(content: Content) -> some View {
////        if addNavigationDestination {
////            content
////                .navigationDestination(for: AnyDestination.self) { value in
////                    value.destination
////                }
////        } else {
////            content
////        }
////    }
////}
////
////extension View {
////    
////    func navigationDestinationIfNeeded(addNavigationDestination: Bool) -> some View {
////        modifier(NavigationDestinationViewModifier(addNavigationDestination: addNavigationDestination))
////    }
////}
//
//
//
////struct FullScreenCoverViewModifier: ViewModifier {
////    
////    @Bindable var viewModel: RouterViewModel
////    var routeId: String
////
////    func body(content: Content) -> some View {
////        content
////            .fullScreenCover(item: Binding(stack: viewModel.activeScreenStacks, routerId: routeId, segue: .fullScreenCover), onDismiss: nil) { destination in
////                destination.destination
////            }
////    }
////}
///*
// ZStack {
//     if let loadedDestination {
//         loadedDestination.destination
//     }
// }
// .onAppear {
//     loadedDestination = destination
// }
// */
//
////struct SheetViewModifier: ViewModifier {
////    
////    @Bindable var viewModel: RouterViewModel
////    var routeId: String
////
////    func body(content: Content) -> some View {
////        content
////            .sheet(item: Binding(stack: viewModel.activeScreenStacks, routerId: routeId, segue: .sheet), onDismiss: nil) { destination in
////                destination.destination
////            }
////    }
////}
////
////struct AlertViewModifier: ViewModifier {
////    
////    let alert: Binding<AnyAlert?>
////
////    func body(content: Content) -> some View {
////        let value = alert.wrappedValue
////        
////        return content
////            .alert(value?.title ?? "", isPresented: Binding(ifNotNil: Binding(if: option, is: .alert, value: item))) {
////                item.wrappedValue?.buttons
////            } message: {
////                if let subtitle = item.wrappedValue?.subtitle {
////                    Text(subtitle)
////                }
////            }
////    }
////}
//
//
//
