//
//  TransitionOption.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 3/18/25.
//
import SwiftUI

public enum TransitionOption: String, CaseIterable {
    // identity, scale, opacity, slide, slideCover
    case trailing, leading, top, bottom, identity
    // trailingCover, leadingCover, topCover, bottomCover
    
    var insertion: AnyTransition {
        switch self {
        case .trailing:
            return .move(edge: .trailing)
        case .leading:
            return .move(edge: .leading)
        case .top:
            return .move(edge: .top)
        case .bottom:
            return .move(edge: .bottom)
//        case .trailingCover:
//            return .move(edge: .trailing)
//        case .leadingCover:
//            return .move(edge: .leading)
//        case .topCover:
//            return .move(edge: .top)
//        case .bottomCover:
//            return .move(edge: .bottom)
//        case .scale:
//            return .scale.animation(.default)
//        case .opacity:
//            return .opacity.animation(.default)
//        case .slide, .slideCover:
//            return .slide.animation(.default)
        case .identity:
            return .identity
        }
    }
//    
//    var removal: AnyTransition {
//        switch self {
//        case .trailingCover, .leadingCover, .topCover, .bottomCover:
//            return AnyTransition.opacity.animation(.easeInOut.delay(1))
//        case .trailing:
//            return .move(edge: .leading)
//        case .leading:
//            return .move(edge: .trailing)
//        case .top:
//            return .move(edge: .bottom)
//        case .bottom:
//            return .move(edge: .top)
////        case .scale:
////            return .scale.animation(.easeInOut)
////        case .opacity:
////            return .opacity.animation(.easeInOut)
////        case .slide:
////            return .slide.animation(.easeInOut)
////        case .identity:
////            return .identity
//
//        }
//    }
    
    var reversed: TransitionOption {
        switch self {
        case .trailing: return .leading
//        case .trailingCover: return .leading
        case .leading: return .trailing
//        case .leadingCover: return .trailing
        case .top: return .bottom
//        case .topCover: return .bottom
        case .bottom: return .top
//        case .bottomCover: return .top
        case .identity: return .identity
        }
    }
}

