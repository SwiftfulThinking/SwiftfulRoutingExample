//
//  SwiftfulRoutingExampleApp.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 5/2/22.
//
import SwiftUI
import SwiftfulRouting
import SwiftfulLogging

@main
struct SwiftfulRoutingExampleApp: App {
    
    @State private var lastModuleId = UserDefaults.lastModuleId
    
    init() {
        setConfigureApplicationSettings()
        configureLogging()
    }
    
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }
    
    var body: some Scene {
        WindowGroup {
            if isUITesting {
                ContentView2()
            } else {
                if lastModuleId == "onboarding" {
                    RouterView(addModuleSupport: true) { router in
                        OnboardingView()
                    }
                } else {
                    RouterView(id: "home", addModuleSupport: true) { router in
                        OverviewView()
                    }
                }
            }
        }
    }
    
    private func setConfigureApplicationSettings() {
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // There's a bug on iOS 17 where sheet may not load with large title, even if modifiers are set, which causes some tests to fail
        // https://stackoverflow.com/questions/77253122/swiftui-navigationstack-title-loads-inline-instead-of-large-when-sheet-is-pres
        UINavigationBar.appearance().prefersLargeTitles = true
    }
    
    private func configureLogging() {
        // Use internal logger:
        // SwiftfulRoutingLogger.enableLogging(level: .analytic, printParameters: true)
        
        
        // or use SwiftfulRouting:
        let logManager = LogManager(services: [ConsoleService(printParameters: true)])
        SwiftfulRoutingLogger.enableLogging(logger: logManager)
    }
}




struct OnboardingView: View {
    
    @Environment(\.router) var router
    
    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea()
            
            VStack {
                Text("Onboarding Module")
                
                Text("Tap to enter")
            }
        }
        .onTapGesture {
            router.showModule(.trailing, id: "home_screen") { _ in
                OverviewView()
            }
        }
    }
}
