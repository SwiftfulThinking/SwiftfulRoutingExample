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
    
//    case trailingCover, leadingCover, topCover, bottomCover
    
    var animation: Animation? {
        switch self {
        case .identity:
            return .none
        default:
            return .easeInOut
        }
    }
    
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
            // Note: This will NOT work with .identity (idk why)
            // SwiftUI renders .identity differently than .move transitions
            // Instead, we keep this as .move(.leading) and will set animation = .none
            // to get the same result!
            return .move(edge: .leading)
        }
    }
    
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
    
    var asAlignment: Alignment {
        switch self {
        case .trailing:
            return .trailing
//        case .trailingCover:
//            return .trailing
        case .leading:
            return .leading
//        case .leadingCover:
//            return .leading
        case .top:
            return .top
//        case .topCover:
//            return .top
        case .bottom:
            return .bottom
//        case .bottomCover:
//            return .bottom
        case .identity:
            return .center
        }
    }
    
    var asAxis: Axis.Set {
        switch self {
        case .trailing:
            return .horizontal
//        case .trailingCover:
//            return .horizontal
        case .leading:
            return .horizontal
//        case .leadingCover:
//            return .horizontal
        case .top:
            return .vertical
//        case .topCover:
//            return .vertical
        case .bottom:
            return .vertical
//        case .bottomCover:
//            return .vertical
        case .identity:
            return .horizontal
        }
    }

}

