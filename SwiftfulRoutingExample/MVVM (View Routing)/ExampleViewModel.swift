//
//  ExampleViewModel.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/29/23.
//

import Foundation

@MainActor
final class ExampleViewModel: ObservableObject {

    private let service: DataService

    @Published private(set) var title: String? = nil
    @Published private(set) var subtitle: String? = nil
        
    init(service: DataService) {
        self.service = service
    }
    
    func configure() async throws {
//        title = try await service.fetchTitle()
    }
    
    func loadMoreInfo() async throws {
//        subtitle = try await service.fetchSubtitle()
    }
    
    func continueButtonPressed() async throws -> String {
//        try await service.fetchNextScreenTitle()
        ""
    }
}
