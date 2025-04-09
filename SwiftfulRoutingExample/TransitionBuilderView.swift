//
//  TransitionBuilderView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/8/25.
//

import SwiftUI

struct TransitionBuilderView: View {
    
    @Environment(\.router) var router
    
    @State private var transition: TransitionOption = .trailing

    var body: some View {
        VStack {
            List {
                Picker("Option", selection: $transition) {
                    ForEach(TransitionOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
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
            try? router.dismissTransition()
        }
    }
    
    private var codeString: String {
return """
router.showTransition(
  .\(transition.rawValue),
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
        
        router.showSimpleAlert(text: "Copied!")
        
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
