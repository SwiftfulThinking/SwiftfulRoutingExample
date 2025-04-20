//
//  NewAppView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/20/25.
//

import SwiftUI
import SwiftfulRouting

struct AppRootView1: View {
    
    var body: some View {
        RouterView(addModuleSupport: true) { _ in
            Text("Hello, world!")
        }
    }
}



struct NewAppView: View {
    var body: some View {
        
        RouterView(addModuleSupport: true) { _ in
            RouterView(addNavigationStack: true, addModuleSupport: false, content: { _ in
                TabView {
                    Text("Screen1")
                        .tabItem { Label("Home", systemImage: "house.fill") }
                    
                    Text("Screen2")
                        .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    
                    Text("Screen3")
                        .tabItem { Label("Profile", systemImage: "person.fill") }
                }
            })
        }
        
    }
}

struct AppRootView: View {
    
    @State private var lastModuleId = UserDefaults.lastModuleId

    @ViewBuilder
    var body: some View {
        if lastModuleId == "onboarding" {
            RouterView(id: "onboarding", addModuleSupport: true) { router in
                OnboardingView()
            }
        } else {
            RouterView(id: "tabbar", addNavigationStack: false, addModuleSupport: true) { _ in
                AppTabbarView()
            }
        }
    }
}

struct AppTabbarView: View {
    
    var body: some View {
        TabView {
            RouterView(addNavigationStack: true, addModuleSupport: false, content: { _ in
                Text("Screen1")
            })
            .tabItem { Label("Home", systemImage: "house.fill") }
            
            RouterView(addNavigationStack: true, addModuleSupport: false, content: { _ in
                Text("Screen2")
            })
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            
            RouterView(addNavigationStack: true, addModuleSupport: false, content: { _ in
                Text("Screen3")
            })
            .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

#Preview {
    NewAppView()
}
