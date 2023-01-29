//
//  DataService.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/29/23.
//

import Foundation

final class DataService {
    
    func fetchTitle() async throws -> String {
        "Hello, world!"
    }
    
    func fetchSubtitle() async throws -> String {
        throw URLError(.badURL)
    }
    
    func fetchNextScreenTitle() async throws -> String {
        "My next screen!"
    }
}
