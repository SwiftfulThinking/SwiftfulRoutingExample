//
//  SwiftfulRoutingExampleApp.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 5/2/22.
//

import SwiftUI
//import SwiftfulRouting

@main
struct SwiftfulRoutingExampleApp: App {
    
    init() {
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // There's a bug on iOS 17 where sheet may not load with large title, even if modifiers are set, which causes some tests to fail
        // https://stackoverflow.com/questions/77253122/swiftui-navigationstack-title-loads-inline-instead-of-large-when-sheet-is-pres
        UINavigationBar.appearance().prefersLargeTitles = true
    }
    
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }
    
    var body: some Scene {
        WindowGroup {
            if isUITesting {
                ContentView2()
            } else {
                RouterView(addNavigationStack: true, logger: true) { router in
                    OverviewView()
                }
            }
        }
    }
}
