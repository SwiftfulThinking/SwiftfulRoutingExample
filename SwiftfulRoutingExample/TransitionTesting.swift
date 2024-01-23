//
//  TransitionTesting.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/21/24.
//

import SwiftUI
//import SwiftfulUI
import SwiftfulRouting

struct TransitionTesting: View {
    
    @State private var showScreen: Bool = false
    @State private var removal: TransitionOption = .trailing
    @State private var appearCount: Int = 0
    
    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: false, selection: showScreen) { (shouldshow: Bool) in
                Rectangle()
                    .fill(shouldshow ? .red : Color.black)
                    .ignoresSafeArea()
//                    .frame(width: 200, height: 200)
//                    .transition(.move(edge: .trailing))
                    .onAppear {
                        appearCount += 1
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(direction: removal))
                    )
                    .opacity(shouldshow ? 0.1 : 1)
            }
            .animation(.linear, value: showScreen)
        }
        .overlay(
            Text("\(appearCount)")
                .offset(y: 200)
                .foregroundColor(.red)
        )
        .onTapGesture {
            removal = .top
            
            
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 0)
                showScreen.toggle()
            }
        }
    }
}

#Preview {
    TransitionTesting()
}

// Needs to change x,y offset while on screen without chaning the Transition?

struct MoveTransition: ViewModifier {
    let x: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .offset(x: x, y: y)
    }
}

struct CustomTransition: ViewModifier {
    let option: TransitionOption?
    @State private var frame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .readingFrame { frame in
                self.frame = frame
            }
            .offset(x: xOffset, y: yOffset)
            .overlay(
                Text(frame.debugDescription)
                    .foregroundColor(.white)
            )
//            .offset(x: x, y: y)
    }
    
    private var xOffset: CGFloat {
        switch option {
        case .trailing:
            return frame.width
        case .trailingCover:
            return 0
        case .leading:
            return -frame.width
        case .leadingCover:
            return 0
        case .top:
            return 0
        case .topCover:
            return 0
        case .bottom:
            return 0
        case .bottomCover:
            return 0
        case nil:
            return 0
        }
    }
    
    private var yOffset: CGFloat {
        switch option {
        case .trailing:
            return 0
        case .trailingCover:
            return 0
        case .leading:
            return 0
        case .leadingCover:
            return 0
        case .top:
            return -frame.height
        case .topCover:
            return 0
        case .bottom:
            return frame.height
        case .bottomCover:
            return 0
        case nil:
            return 0
        }
    }
}

extension AnyTransition {
    
    static func move(direction: TransitionOption) -> AnyTransition {
        .modifier(
            active: CustomTransition(option: direction),
            identity: CustomTransition(option: nil)
        )
    }
    
//    static func move(x: CGFloat = 0, y: CGFloat = 0) -> AnyTransition {
//        .modifier(
//            active: MoveTransition(x: x, y: y),
//            identity: MoveTransition(x: 0, y: 0)
//        )
//    }
}
