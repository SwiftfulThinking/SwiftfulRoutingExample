//
//  SwiftfulRoutingExampleApp.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 5/2/22.
//

import SwiftUI

@main
struct SwiftfulRoutingExampleApp: App {
    
    init() {
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
