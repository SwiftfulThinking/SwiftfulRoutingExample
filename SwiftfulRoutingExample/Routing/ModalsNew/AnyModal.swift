//
//  AnyModalWithDestination.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 3/12/25.
//

import Foundation
import SwiftUI

//public struct ModalConfiguration {
//    let transition: AnyTransition
//    let animation: Animation
//    let alignment: Alignment
//    let backgroundColor: Color?
//    let dismissOnBackgroundTap: Bool
//    let ignoreSafeArea: Bool
//    
//    static let `default` = ModalConfiguration(
//        transition: .move(edge: .bottom),
//        animation: .easeInOut,
//        alignment: .bottom,
//        backgroundColor: nil,
//        dismissOnBackgroundTap: true,
//        ignoreSafeArea: true
//    )
//}

struct AnyModal: Identifiable, Equatable {
    private(set) var id: String
    private(set) var transition: AnyTransition
    private(set) var animation: Animation
    private(set) var alignment: Alignment
    private(set) var backgroundColor: Color?
    private(set) var dismissOnBackgroundTap: Bool
    private(set) var ignoreSafeArea: Bool
    private(set) var destination: AnyView
    private(set) var onDismiss: (() -> Void)?
    private(set) var isRemoved: Bool = false
    
    init<T:View>(
        id: String = UUID().uuidString,
        transition: AnyTransition = .identity,
        animation: Animation = .smooth,
        alignment: Alignment = .center,
        backgroundColor: Color? = nil,
        dismissOnBackgroundTap: Bool = true,
        ignoreSafeArea: Bool = true,
        destination: @escaping () -> T,
        onDismiss: (() -> Void)? = nil
    ) {
        self.id = id
        self.transition = transition
        self.animation = animation
        self.alignment = alignment
        self.backgroundColor = backgroundColor
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.ignoreSafeArea = ignoreSafeArea
        self.destination = AnyView(
            destination()
        )
        self.onDismiss = onDismiss
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyModal, rhs: AnyModal) -> Bool {
        lhs.id == rhs.id
    }
    
    mutating func convertToEmptyRemovedModal() {
        id = "removed_\(id)"
        backgroundColor = nil
        dismissOnBackgroundTap = false
        destination = AnyView(
            EmptyView()
        )
        onDismiss = nil
        isRemoved = true
    }
}

/*
 struct AnyDestination: Identifiable, Hashable {
     let id: String
     let segue: SegueOption
     let location: SegueLocation
     let animates: Bool
     private(set) var destination: AnyView
     let onDismiss: (() -> Void)?

 */

//struct AnyModalWithDestination: Identifiable, Equatable {
//    let id: String
//    let configuration: ModalConfiguration
//    let destination: AnyDestination
//    private(set) var didDismiss: Bool = false
//    
//    static func == (lhs: AnyModalWithDestination, rhs: AnyModalWithDestination) -> Bool {
//        lhs.id == rhs.id && lhs.didDismiss == rhs.didDismiss
//    }
//    
//    mutating func dismiss() {
//        didDismiss = true
//    }
//    
//    static var origin: AnyModalWithDestination {
//        AnyModalWithDestination(
//            id: "origin_modal",
//            configuration: ModalConfiguration(
//                transition: .identity,
//                animation: .default,
//                alignment: .center,
//                backgroundColor: nil,
//                dismissOnBackgroundTap: true,
//                ignoreSafeArea: true
//            ),
//            destination: AnyDestination(id: "origin_destination", EmptyView())
//        )
//    }
//}

import SwiftfulRecursiveUI

struct ModalSupportView: View {
    
    let modals: [AnyModal]
    let onDismissModal: (AnyModal) -> Void

    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: true, selection: nil, items: modals) { (modal: AnyModal) in
                let dataIndex: Double = Double(modals.firstIndex(where: { $0.id == modal.id }) ?? 99)
                
                return LazyZStack(allowSimultaneous: true, selection: true) { (showView1: Bool) in
                    if showView1 {
                        modal.destination
                            .modalFrame(ignoreSafeArea: modal.ignoreSafeArea, alignment: modal.alignment)
                            .transition(modal.transition.animation(modal.animation))
                            .zIndex(dataIndex + 2)
                    } else {
                        if let backgroundColor = modal.backgroundColor {
                            backgroundColor
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
                                
                                // Only add backgound tap gesture if needed
                                .ifSatisfiesCondition(modal.dismissOnBackgroundTap, transform: { content in
                                    content
                                        .onTapGesture {
                                            onDismissModal(modal)
                                        }
                                })
                                .zIndex(dataIndex + 1)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
            .animation(modals.last?.animation ?? .default, value: (modals.last?.id ?? "") + "\(modals.count)")
        }
//        .onFirstAppear {
//            activeModal = modals.last
//        }
//        .onChange(of: modals, perform: { newValue in
//            Task { @MainActor in
//                try? await Task.sleep(nanoseconds: 0)
//                if let new = newValue.last(where: { !$0.didDismiss }), self.selection?.id != new.id {
//                    self.selection = new
//                }
//            }
//        })
    }

}

fileprivate extension View {
    
    @ViewBuilder
    func modalFrame(ignoreSafeArea: Bool, alignment: Alignment) -> some View {
        if ignoreSafeArea {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
                .ignoresSafeArea()
        } else {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        }
    }
    
}


//struct ModalSupportView: View {
//    
//    @State private var selection: AnyModalWithDestination? = nil
//
//    let transitions: [AnyModalWithDestination]
//    let onDismissModal: (AnyModalWithDestination) -> Void
//        
//    var body: some View {
//        ZStack {
//            LazyZStack(allowSimultaneous: true, selection: selection, items: transitions) { (data: AnyModalWithDestination) in
//                let dataIndex: Double = Double(transitions.firstIndex(where: { $0.id == data.id }) ?? 99)
//
//                return LazyZStack(allowSimultaneous: true, selection: true) { (showView1: Bool) in
//                    if showView1 {
//                        data.destination.destination
//                            .frame(configuration: data.configuration)
//                            .transition(data.configuration.transition)
//                            .zIndex(dataIndex + 2)
//                    } else {
//                        if let backgroundColor = data.configuration.backgroundColor {
//                            backgroundColor
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .edgesIgnoringSafeArea(.all)
//                                .transition(AnyTransition.opacity.animation(.easeInOut))
//                                // Only add backgound tap gesture if needed
//                                .ifSatisfiesCondition(data.configuration.dismissOnBackgroundTap, transform: { content in
//                                    content
//                                        .onTapGesture {
//                                            onDismissModal(data)
//                                        }
//                                })
//                                .zIndex(dataIndex + 1)
//                        } else {
//                            EmptyView()
//                        }
//                    }
//                }
//            }
//            .animation(transitions.last?.configuration.animation ?? .default, value: (selection?.id ?? "") + "\(transitions.count)")
//        }
//        .onFirstAppear {
//            selection = transitions.last
//        }
//        .onChange(of: transitions, perform: { newValue in
//            Task { @MainActor in
//                try? await Task.sleep(nanoseconds: 0)
//                if let new = newValue.last(where: { !$0.didDismiss }), self.selection?.id != new.id {
//                    self.selection = new
//                }
//            }
//        })
//    }
//}

public enum TransitionOption: String, CaseIterable {
    case trailing, trailingCover, leading, leadingCover, top, topCover, bottom, bottomCover // identity //, scale, opacity, slide, slideCover
    
    var insertion: AnyTransition {
        switch self {
        case .trailing, .trailingCover:
            return .move(edge: .trailing)
        case .leading, .leadingCover:
            return .move(edge: .leading)
        case .top, .topCover:
            return .move(edge: .top)
        case .bottom, .bottomCover:
            return .move(edge: .bottom)
//        case .scale:
//            return .scale.animation(.default)
//        case .opacity:
//            return .opacity.animation(.default)
//        case .slide, .slideCover:
//            return .slide.animation(.default)
//        case .identity:
//            return .identity
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
        case .trailingCover: return .leading
        case .leading: return .trailing
        case .leadingCover: return .trailing
        case .top: return .bottom
        case .topCover: return .bottom
        case .bottom: return .top
        case .bottomCover: return .top
//        case .identity: return .identity
        }
    }
    
    var asAlignment: Alignment {
        switch self {
        case .trailing:
            return .trailing
        case .trailingCover:
            return .trailing
        case .leading:
            return .leading
        case .leadingCover:
            return .leading
        case .top:
            return .top
        case .topCover:
            return .top
        case .bottom:
            return .bottom
        case .bottomCover:
            return .bottom
        }
    }
    
    var asAxis: Axis.Set {
        switch self {
        case .trailing:
            return .horizontal
        case .trailingCover:
            return .horizontal
        case .leading:
            return .horizontal
        case .leadingCover:
            return .horizontal
        case .top:
            return .vertical
        case .topCover:
            return .vertical
        case .bottom:
            return .vertical
        case .bottomCover:
            return .vertical
        }
    }
}

