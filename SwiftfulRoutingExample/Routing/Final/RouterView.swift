//
//  RouterView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/9/25.
//
import SwiftUI

struct RouterView<Content: View>: View {
    
    @StateObject private var viewModel: RouterViewModel = RouterViewModel()
    var addNavigationStack: Bool = true
    var logger: Bool = false
    var content: (AnyRouter) -> Content

    var body: some View {
        RouterViewInternal(
            routerId: RouterViewModel.rootId,
            addNavigationStack: addNavigationStack,
            logger: logger,
            content: content
        )
        .environmentObject(viewModel)
    }
}

// Tabbar builder from course
// Add actions for tabbar selection
// Switch tabs from router
//
// ModuleBuilder
//
// enum for - one stack per screen or one per module


// How to showModule

// showModule
// ModuleBuilder

// Can I switch tabs from router?
// Can I switch modules from router?

// Logging from RouterView, remove all prints


//struct MyAppBeginnerTest: View {
//
//    @AppStorage("last_module_id") private var lastModuleId: String = ""
//    
//    var body: some View {
//        ModuleBaseView {
//            switch lastModuleId {
//            case "home":
//                ModuleBuilder {
//                    [
//                        tab1,
//                        tab2,
//                        tab3
//                        router.showModule(id: String) {
//                            ModuleBuilder {
//                                [
//                                    onboardingView
//                                ]
//                            }
//                        }
//                    ]
//                }
//            default:
//                ModuleBuilder {
//                    [
//                        onboarding
//                    ]
//                }
//            }
//        }
//    }
//}
//
//struct SampleHeirarchyView: View {
//
//    @State private var showOnboarding: Bool = false
//    
//    var body: some View {
//        ZStack {
//            if showOnboarding {
//                TabView {
//                    RouterView { router in
//                        Text("Screen 1")
//                    }
//                    RouterView { router in
//                        Text("Screen 2")
//                    }
//                    RouterView { router in
//                        Text("Screen 3")
//                    }
//                }
//            }
//            if !showOnboarding {
//                RouterView { router in
//                    Text("Welcome")
//                }
//            }
//        }
//    }
//}
//
//struct SampleHeirarchyView2: View {
//
//    @State private var showOnboarding: Bool = false
//    
//    var body: some View {
//        ZStack {
//            if showOnboarding {
//                RouterView { router in
//                    TabView {
//                        Text("Screen 1")
//                        Text("Screen 2")
//                        Text("Screen 3")
//                    }
//                }
//            }
//            if !showOnboarding {
//                RouterView { router in
//                    Text("Welcome")
//                }
//            }
//        }
//    }
//}
