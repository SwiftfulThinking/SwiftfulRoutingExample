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
    
    static var root: AnyTransitionDestination {
        AnyTransitionDestination(id: "root", transition: .trailing, destination: { _ in
            EmptyView()
        })
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyTransitionDestination, rhs: AnyTransitionDestination) -> Bool {
        lhs.id == rhs.id
    }
}

enum TransitionMemoryBehavior {
    case removePreviousFromMemory
    case keepPreviousInMemory
    
    var allowSimultaneous: Bool {
        switch self {
        case .removePreviousFromMemory:
            return false
        case .keepPreviousInMemory:
            return true
        }
    }
    
//    var allowSwipeBack: Bool {
//        switch self {
//        case .removePreviousFromMemory:
//            return false
//        case .keepPreviousInMemory(let allowSwipeBack):
//            return allowSwipeBack
//        }
//    }
}

struct TransitionSupportView2<Content:View>: View {
    
    var behavior: TransitionMemoryBehavior = .keepPreviousInMemory
    let router: AnyRouter
    let transitions: [AnyTransitionDestination]
    @ViewBuilder var content: (AnyRouter) -> Content
    let currentTransition: TransitionOption
    
    @State private var viewFrame: CGRect = .zero

    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: behavior.allowSimultaneous, selection: transitions.last, items: transitions) { data in
                let dataIndex: Double = Double(transitions.firstIndex(where: { $0.id == data.id }) ?? 99)
                
                if data == transitions.first {
                    return content(router)
                        .transition(
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: .customRemoval(behavior: behavior, direction: currentTransition.reversed, frame: viewFrame)
                            )
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(-1)
                } else {
                    return data.destination(router)
                        .transition(
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: .customRemoval(behavior: behavior, direction: currentTransition.reversed, frame: viewFrame)
                            )
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(dataIndex)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(currentTransition.animation, value: (transitions.last?.id ?? "") + currentTransition.rawValue)
        .ifSatisfiesCondition(viewFrame == .zero, transform: { content in
            content
                .readingFrame(onChange: { frame in
                    self.viewFrame = frame
                })
        })
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
    var behavior: TransitionMemoryBehavior
    let option: TransitionOption?
    var frame: CGRect

    func body(content: Content) -> some View {
        content
            .offset(x: xOffset, y: yOffset)
    }
    
    private var xOffset: CGFloat {
        switch option {
        case .trailing:
            return frame.width
        case .leading:
            return -frame.width
        default:
            return 0
        }
    }
    
    private var yOffset: CGFloat {
        switch option {
        case .top:
            return -frame.height
        case .bottom:
            return frame.height
        default:
            return 0
        }
    }
}

//struct CustomOffset: ViewModifier {
//    let option: TransitionOption?
//    var frame: CGRect
//
//    func body(content: Content) -> some View {
//        content
//            .offset(x: xOffset, y: yOffset)
//    }
//    
//    private var xOffset: CGFloat {
//        switch option {
//        case .trailing:
//            return frame.width
//        case .leading:
//            return -frame.width
//        default:
//            return 0
//        }
//    }
//    
//    private var yOffset: CGFloat {
//        switch option {
//        case .top:
//            return -frame.height
//        case .bottom:
//            return frame.height
//        default:
//            return 0
//        }
//    }
//}

extension AnyTransition {
    
    static func customRemoval(
        behavior: TransitionMemoryBehavior,
        direction: TransitionOption,
        frame: CGRect
    ) -> AnyTransition {
        .modifier(
            active: CustomRemovalTransition(behavior: behavior, option: direction, frame: frame),
            identity: CustomRemovalTransition(behavior: behavior, option: nil, frame: frame)
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
