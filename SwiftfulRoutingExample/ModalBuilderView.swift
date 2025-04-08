//
//  ModalBuilderView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/7/25.
//

import SwiftUI

struct ModalBuilderView: View {
    
    @Environment(\.router) var router
    
    @State private var transition: SampleTransitionOption = .bottom
    @State private var animation: SampleAnimationOption = .smooth
    @State private var duration: Double = 0.3
    @State private var alignment: SampleAlignmentOption = .center
    @State private var showBackground: Bool = false
    @State private var backgroundColor: Color = Color.black.opacity(0.3)
    @State private var dismissOnBackgroundTap: Bool = false
    @State private var ignoreSafeArea: Bool = true
    @State private var example: SampleModalOption = .regular

    var body: some View {
        VStack {
            List {
                Picker("Modal example", selection: $example) {
                    ForEach(SampleModalOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                
                Picker("Option", selection: $transition) {
                    ForEach(SampleTransitionOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                
                Picker("Animation", selection: $animation) {
                    ForEach(SampleAnimationOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                
                Stepper(value: $duration, step: 0.1, label: {
                    Text("Animation duration: \(String(format: "%.1f", duration))")
                })
                
                Picker("Alignment", selection: $alignment) {
                    ForEach(SampleAlignmentOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                Toggle("Ignore safe area: \(ignoreSafeArea.description)", isOn: $ignoreSafeArea)

                Toggle("Show background: \(showBackground.description)", isOn: $showBackground)
                
                if showBackground {
                    ColorPicker("Background color", selection: $backgroundColor, supportsOpacity: true)
                    
                    Toggle("Dismiss background tap: \(dismissOnBackgroundTap.description)", isOn: $dismissOnBackgroundTap)
                }
            }
            
            codeView
            
            HStack(spacing: 12) {
                actionButton
                copyButton
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Modal Builder")
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch example {
        case .regular:
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue)
                .frame(width: 300, height: 400)
                .overlay(
                    Text("Tap to dismiss")
                        .foregroundStyle(.white)
                        .font(.headline)
                )
                .onTapGesture {
                    router.dismissModal()
                }
        case .sheet:
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue)
                .frame(height: 400)
                .overlay(
                    Text("Tap to dismiss")
                        .foregroundStyle(.white)
                        .font(.headline)
                )
                .onTapGesture {
                    router.dismissModal()
                }
        case .pallete:
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue)
                .frame(height: 100)
                .overlay(
                    Text("Tap to dismiss")
                        .foregroundStyle(.white)
                        .font(.headline)
                )
                .onTapGesture {
                    router.dismissModal()
                }
                .padding(24)
        case .fullScreen:
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue)
                .overlay(
                    Text("Tap to dismiss")
                        .foregroundStyle(.white)
                        .font(.headline)
                )
                .onTapGesture {
                    router.dismissModal()
                }
        }
    }
    
    private var codeString: String {
var string = """
router.showModal(
  transition: \(transition.codeString(animation: animation)),
  animation: \(animation.codeString(duration: duration)),
  alignment: \(alignment.codeString)
"""
        
        if showBackground {
            string += """

  ,
  backgroundColor: Color.background
"""
        }
        
        if dismissOnBackgroundTap {
            string += """

  ,
  dismissOnBackgroundTap: \(dismissOnBackgroundTap.description)
"""
        }
        
        if ignoreSafeArea {
            string += """
,
  ignoreSafeArea: \(ignoreSafeArea.description)
"""
        }
        
        string += """
,
  destination: {
    destinationView
  }
)
"""
    
        return string
    }
    
    private var codeView: some View {
        Text(codeString)
            .font(.system(size: 10, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Color(.systemGray6))
            .padding(12)
    }
    
    private var actionButton: some View {
        Button(action: {
            router.showModal(
                transition: transition.transition,
                animation: animation.animation(duration: duration),
                alignment: alignment.alignment,
                backgroundColor: showBackground ? backgroundColor : nil,
                dismissOnBackgroundTap: dismissOnBackgroundTap,
                ignoreSafeArea: ignoreSafeArea,
                destination: {
                    destinationView
                }
            )
        }, label: {
            Text("Trigger Modal")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(Color.blue)
                .cornerRadius(12)
        })
    }
    
    private var copyButton: some View {
        Button(action: {
            copyToClipboard()
        }, label: {
            Image(systemName: "doc.on.doc.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 55, height: 55)
                .background(Color.blue)
                .cornerRadius(12)
        })
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = codeString
        
        router.showSimpleAlert(text: "Copied!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            router.dismissAlert()
        }
    }
}

#Preview {
    RouterView { _ in
        ModalBuilderView()
    }
}

private enum SampleTransitionOption: String, CaseIterable, Hashable {
    case leading, trailing, top, bottom, opacity, scale, slide, identity
    
    var transition: AnyTransition {
        switch self {
        case .leading:
            return .move(edge: .leading)
        case .trailing:
            return .move(edge: .trailing)
        case .top:
            return .move(edge: .top)
        case .bottom:
            return .move(edge: .bottom)
        case .opacity:
            return .opacity
        case .scale:
            return .scale
        case .slide:
            return .slide
        case .identity:
            return .identity
        }
    }
    
    func codeString(animation: SampleAnimationOption) -> String {
        switch self {
        case .leading:
            return ".move(edge: .leading)"
        case .trailing:
            return ".move(edge: .trailing)"
        case .top:
            return ".move(edge: .top)"
        case .bottom:
            return ".move(edge: .bottom)"
        case .opacity:
            return ".opacity"
        case .scale:
            return ".scale" // fix me?
        case .slide:
            return ".slide"
        case .identity:
            return ".identity"
        }
    }
}

private enum SampleAnimationOption: String, CaseIterable, Hashable {
    case linear, easeIn, easeOut, easeInOut, spring, bouncy, snappy, smooth
    
    func animation(duration: Double) -> Animation {
        switch self {
        case .linear:
            return .linear(duration: duration)
        case .easeIn:
            return .easeIn(duration: duration)
        case .easeOut:
            return .easeOut(duration: duration)
        case .easeInOut:
            return .easeInOut(duration: duration)
        case .spring:
            return .spring(duration: duration)
        case .bouncy:
            return .bouncy(duration: duration)
        case .snappy:
            return .snappy(duration: duration)
        case .smooth:
            return .smooth(duration: duration)
        }
    }
    
    func codeString(duration: Double) -> String {
        switch self {
        case .linear:
            return ".linear(duration: \(duration)"
        case .easeIn:
            return ".easeIn(duration: \(duration))"
        case .easeOut:
            return ".easeOut(duration: \(duration))"
        case .easeInOut:
            return ".easeInOut(duration: \(duration))"
        case .spring:
            return ".spring(duration: \(duration))"
        case .bouncy:
            return ".bouncy(duration: \(duration))"
        case .snappy:
            return ".snappy(duration: \(duration))"
        case .smooth:
            return ".smooth(duration: \(duration))"
        }
    }
}

private enum SampleAlignmentOption: String, CaseIterable, Hashable {
    case center, top, bottom, leading, trailing
    
    var alignment: Alignment {
        switch self {
        case .center:
            return .center
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
    
    var codeString: String {
        switch self {
        case .center:
            return ".center"
        case .top:
            return ".top"
        case .bottom:
            return ".bottom"
        case .leading:
            return ".leading"
        case .trailing:
            return ".trailing"
        }
    }
}


private enum SampleModalOption: String, CaseIterable, Hashable {
    case regular, sheet, pallete, fullScreen
}
