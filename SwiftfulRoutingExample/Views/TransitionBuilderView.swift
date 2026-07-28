//
//  TransitionBuilderView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/8/25.
//
import SwiftfulRouting
import SwiftUI

struct TransitionBuilderView: View {
    
    @Environment(\.router) var router
    
    @State private var selectedIndex: Int = 0

    private let transitionOptions: [TransitionOption] = TransitionOption.allCases

    private var transition: TransitionOption {
        transitionOptions[selectedIndex]
    }

    var body: some View {
        VStack {
            List {
                Picker("Option", selection: $selectedIndex) {
                    ForEach(transitionOptions.indices, id: \.self) { index in
                        Text(displayName(for: transitionOptions[index]))
                            .tag(index)
                    }
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
    
    private var destinationView: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            Text("Tap to dismiss")
                .foregroundStyle(.white)
                .font(.headline)
        }
        .onTapGesture {
            router.dismissTransition()
        }
    }
    
    private func displayName(for option: TransitionOption) -> String {
        switch option {
        case .trailing:
            return "trailing"
        case .leading:
            return "leading"
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        case .identity:
            return "identity"
        }
    }

    private var codeString: String {
return """
router.showTransition(
  .\(displayName(for: transition)),
  destination: { router in
    destinationView
  }
)
"""
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
            router.showTransition(
                transition,
                destination: { _ in
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
        
        router.showBasicAlert(text: "Copied!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            router.dismissAlert()
        }
    }
}

#Preview {
    RouterView { _ in
        TransitionBuilderView()
    }
}
