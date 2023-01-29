//
//  BasicViewModelDelegate.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/29/23.
//

import Foundation

protocol BasicViewModelDelegate {
    func fetchTitle() async throws -> String
    func fetchSubtitle() async throws -> String
    func fetchNextScreenTitle() async throws -> String
}

struct BasicViewModelDelegate_Production: BasicViewModelDelegate {
    let service: DataService
    
    func fetchTitle() async throws -> String {
        try await service.fetchTitle()
    }
    
    func fetchSubtitle() async throws -> String {
        try await service.fetchSubtitle()
    }
    
    func fetchNextScreenTitle() async throws -> String {
        try await service.fetchNextScreenTitle()
    }
}

struct BasicViewModelDelegate_Mock: BasicViewModelDelegate {
    func fetchTitle() async throws -> String {
        "Alpha"
    }
    
    func fetchSubtitle() async throws -> String {
        "Beta"
    }
    
    func fetchNextScreenTitle() async throws -> String {
        "Gamma"
    }
}
