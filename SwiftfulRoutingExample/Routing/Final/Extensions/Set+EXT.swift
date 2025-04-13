//
//  Set_EXT.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/13/25.
//

import Foundation

extension Set {
    func setMap<U>(_ transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.lazy.map(transform))
    }
}
