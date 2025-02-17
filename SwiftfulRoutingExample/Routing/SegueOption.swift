//
//  SegueOption.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 2/17/25.
//


public enum SegueOption: String, Equatable {
    case push, sheet, fullScreenCover
    
//    @available(iOS 14.0, *)
//    case
//    
//    @available(iOS 16.0, *)
//    case sheetDetents
    
    
    var presentsNewEnvironment: Bool {
        switch self {
        case .push:
            return false
        case .sheet, .fullScreenCover:
            return true
        }
    }
}