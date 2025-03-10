//
//  SegueOption.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 2/17/25.
//


public struct ResizableSheetConfig {
    var detents: Set<PresentationDetentTransformable>
    var selection: Binding<PresentationDetentTransformable>?
    var dragIndicator: Visibility
    
    public init(
        detents: Set<PresentationDetentTransformable> = [.medium, .large],
        selection: Binding<PresentationDetentTransformable>? = nil,
        dragIndicator: Visibility = .visible
    ) {
        self.detents = detents
        self.selection = selection
        self.dragIndicator = dragIndicator
    }
}

public enum SegueOption: Equatable {
    case push, sheet, fullScreenCover
    
//    @available(iOS 14.0, *)
//    case
//    
//    @available(iOS 16.0, *)
    case resizableSheet(config: ResizableSheetConfig = ResizableSheetConfig())
    
    public static func == (lhs: SegueOption, rhs: SegueOption) -> Bool {
        lhs.stringValue == rhs.stringValue
    }
    
    var stringValue: String {
        switch self {
        case .push:
            return "push"
        case .sheet:
            return "sheet"
        case .fullScreenCover:
            return "fullScreenCover"
        case .resizableSheet:
            return "resizableSheet"
        }
    }
    
    var presentsNewEnvironment: Bool {
        switch self {
        case .push:
            return false
        case .sheet, .fullScreenCover, .resizableSheet:
            return true
        }
    }
}

import SwiftUI

public enum PresentationDetentTransformable: Hashable {
    case medium
    case large
    case height(CGFloat)
    case fraction(CGFloat)
    case unknown
    
    init(detent: PresentationDetent) {
        // FIXME: Unable to convert .height(CGFloat) and .fraction(CGFloat) back from PresentationDetent to PresentationDetentTransformable
        switch detent {
        case .medium:
            self = .medium
        case .large:
            self = .large
        default:
            self = .unknown
        }
    }
    
    var asPresentationDetent: PresentationDetent {
        switch self {
        case .medium:
            return .medium
        case .large:
            return .large
        case .height(let height):
            return .height(height)
        case .fraction(let fraction):
            return .fraction(fraction)
        case .unknown:
            return .large
        }
    }
    
    public var title: String {
        switch self {
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        case .height(let height):
            return "Height: \(height) px"
        case .fraction(let fraction):
            return "Fraction: \((fraction * 100))%"
        case .unknown:
            return "unknown"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
