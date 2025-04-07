//
//  SegueOption.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 2/17/25.
//

public struct FullScreenCoverConfig {
    var background: EnvironmentBackgroundOption

    public init(
        background: EnvironmentBackgroundOption = .automatic
    ) {
        self.background = background
    }
}

public enum EnvironmentBackgroundOption {
    case automatic
    case clear
    case custom(any ShapeStyle)
}

public struct ResizableSheetConfig {
    var detents: Set<PresentationDetentTransformable>
    var selection: Binding<PresentationDetentTransformable>?
    var dragIndicator: Visibility
    var background: EnvironmentBackgroundOption
    var cornerRadius: CGFloat?
    var backgroundInteraction: PresentationBackgroundInteraction
    var contentInteraction: PresentationContentInteraction

    public init(
        detents: Set<PresentationDetentTransformable> = [.large],
        selection: Binding<PresentationDetentTransformable>? = nil,
        dragIndicator: Visibility = .automatic,
        background: EnvironmentBackgroundOption = .automatic,
        cornerRadius: CGFloat? = nil,
        backgroundInteraction: PresentationBackgroundInteraction = .automatic,
        contentInteraction: PresentationContentInteraction = .automatic
    ) {
        self.detents = detents
        self.selection = selection
        self.dragIndicator = dragIndicator
        self.background = background
        self.cornerRadius = cornerRadius
        self.backgroundInteraction = backgroundInteraction
        self.contentInteraction = contentInteraction
    }
}

public enum SegueOption: Equatable, CaseIterable, Hashable {
    case push
    case fullScreenCover(config: FullScreenCoverConfig = FullScreenCoverConfig())
    case sheet(config: ResizableSheetConfig = ResizableSheetConfig())
    
    public static var allCases: [SegueOption] {
        [.push, .fullScreenCover(), .sheet()]
    }
    
//    @available(iOS 14.0, *)
//    case
//    
//    @available(iOS 16.0, *)
//    case resizableSheet(config: ResizableSheetConfig = ResizableSheetConfig())
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(stringValue)
    }
    
    public static func == (lhs: SegueOption, rhs: SegueOption) -> Bool {
        lhs.stringValue == rhs.stringValue
    }
    
    var codeString: String {
        switch self {
        case .push:
            return ".push"
        case .sheet:
            return ".sheet()"
        case .fullScreenCover:
            return ".fullScreenCover()"
//        case .resizableSheet:
//            return "resizableSheet"
        }
    }
    
    var stringValue: String {
        switch self {
        case .push:
            return "push"
        case .sheet:
            return "sheet"
        case .fullScreenCover:
            return "fullScreenCover"
//        case .resizableSheet:
//            return "resizableSheet"
        }
    }
    
    var presentsNewEnvironment: Bool {
        switch self {
        case .push:
            return false
        case .sheet, .fullScreenCover:
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
