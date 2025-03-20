//
//  AnyTransitionWithDestination.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 3/18/25.
//
import SwiftUI
import SwiftfulRecursiveUI

struct AnyTransitionDestination: Identifiable, Equatable {
    private(set) var id: String
    private(set) var transition: TransitionOption
    private(set) var onDismiss: (() -> Void)?
    private(set) var destination: (AnyRouter) -> any View
    //     private(set) var destination: AnyView

    
    static var root: AnyTransitionDestination {
        AnyTransitionDestination(id: "root", transition: .trailing, destination: { _ in
            EmptyView()
        })
    }
    
//    init<T:View>(
//        id: String = UUID().uuidString,
//        transition: TransitionOption = .trailingCover,
//        onDismiss: (() -> Void)? = nil,
//        destination: @escaping (AnyRouter) -> T
//    ) {
//        self.id = id
//        self.transition = transition
//        self.destination = AnyView(
//            RouterViewInternal(
//                routerId: id,
//                addNavigationStack: segue != .push,
//                content: destination
//            )
//        )
//        self.onDismiss = onDismiss
//    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyTransitionDestination, rhs: AnyTransitionDestination) -> Bool {
        lhs.id == rhs.id
    }
}

struct TransitionSupportView2<Content:View>: View {
    
    let router: AnyRouter
    let transitions: [AnyTransitionDestination]
    @ViewBuilder var content: (AnyRouter) -> Content
    let currentTransition: TransitionOption
    
    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: false, selection: transitions.last, items: transitions) { data in
                let dataIndex: Double = Double(transitions.firstIndex(where: { $0.id == data.id }) ?? 99)
                
                if data == transitions.first {
                    return content(router)
                        .transition(
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: .customRemoval(direction: currentTransition.reversed)
                            )
                        )
                        .zIndex(-1)
                } else {
                    return data.destination(router)
                        .transition(
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: .customRemoval(direction: currentTransition.reversed)
                            )
                        )
                        .zIndex(dataIndex)
                }
            }
        }
        .animation(.easeInOut, value: (transitions.last?.id ?? "") + currentTransition.rawValue)
    }
}

//struct TransitionSupportView<Content:View>: View {
//    
//    let router: AnyRouter
//    @Binding var selection: AnyTransitionDestination
//    let transitions: [AnyTransitionDestination]
//    @ViewBuilder var content: (AnyRouter) -> Content
//    let currentTransition: TransitionOption
//    
//    var body: some View {
//        ZStack {
//            LazyZStack(allowSimultaneous: false, selection: selection, items: transitions) { data in
//                if data == transitions.first {
//                    content(router)
//                        .transition(
//                            .asymmetric(
//                                insertion: currentTransition.insertion,
//                                removal: .customRemoval(direction: currentTransition.reversed)
//                            )
//                        )
//                } else {
//                    data.destination(router)
//                        .transition(
//                            .asymmetric(
//                                insertion: currentTransition.insertion,
//                                removal: .customRemoval(direction: currentTransition.reversed)
//                            )
//                        )
//                }
//            }
//            .animation(.easeInOut, value: selection.id)
//        }
//    }
//}

struct CustomRemovalTransition: ViewModifier {
    let option: TransitionOption?
    @State private var frame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .readingFrame { frame in
                self.frame = frame
            }
            .offset(x: xOffset, y: yOffset)
    }
    
    private var xOffset: CGFloat {
        switch option {
        case .trailing:
            return frame.width
//        case .trailingCover:
//            return 0
        case .leading:
            return -frame.width
//        case .leadingCover:
//            return 0
        case .top:
            return 0
//        case .topCover:
//            return 0
        case .bottom:
            return 0
//        case .bottomCover:
//            return 0
        case .identity:
            return 0
        case nil:
            return 0
        }
    }
    
    private var yOffset: CGFloat {
        switch option {
        case .trailing:
            return 0
//        case .trailingCover:
//            return 0
        case .leading:
            return 0
//        case .leadingCover:
//            return 0
        case .top:
            return -frame.height
//        case .topCover:
//            return 0
        case .bottom:
            return frame.height
//        case .bottomCover:
//            return 0
        case .identity:
            return 0
        case nil:
            return 0
        }
    }
}

extension AnyTransition {
    
    static func customRemoval(direction: TransitionOption) -> AnyTransition {
        .modifier(
            active: CustomRemovalTransition(option: direction),
            identity: CustomRemovalTransition(option: nil)
        )
    }
    
}

@available(iOS 14, *)
/// Adds a transparent View and read it's frame.
///
/// Adds a GeometryReader with infinity frame.
public struct FrameReader: View {
    
    let coordinateSpace: CoordinateSpace
    let onChange: (_ frame: CGRect) -> Void
    
    public init(coordinateSpace: CoordinateSpace, onChange: @escaping (_ frame: CGRect) -> Void) {
        self.coordinateSpace = coordinateSpace
        self.onChange = onChange
    }

    public var body: some View {
        GeometryReader { geo in
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear(perform: {
                    onChange(geo.frame(in: coordinateSpace))
                })
                .onChange(of: geo.frame(in: coordinateSpace), perform: onChange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 14, *)
extension View {
    
    /// Get the frame of the View
    ///
    /// Adds a GeometryReader to the background of a View.
    func readingFrame(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (_ frame: CGRect) -> ()) -> some View {
        background(FrameReader(coordinateSpace: coordinateSpace, onChange: onChange))
    }
}
