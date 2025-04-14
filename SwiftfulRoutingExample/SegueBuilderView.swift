//
//  SegueBuilderView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/6/25.
//

import SwiftUI

struct SegueBuilderView: View {
    
    @Environment(\.router) var router
    
    @State private var segue: SegueOption = .push
    @State private var animates: Bool = true
    
    var body: some View {
        VStack {
            List {
                Picker("Option", selection: $segue) {
                    ForEach(SegueOption.allCases, id: \.self) { option in
                        Text(option.stringValue)
                    }
                }
                
                Toggle("Animate: \(animates.description)", isOn: $animates)
            }
            
            codeView
            
            HStack(spacing: 12) {
                actionButton
                copyButton
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Segue Builder")
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
            router.dismissLastScreen(animates: animates)
        }
    }
    
    private var codeString: String {
"""
router.showScreen(
  segue: \(segue.codeString),
  animates: \(animates.description),
  destination: { router in
    NextScreen()
  }
)
"""
    }
    
    private var codeView: some View {
        Text(codeString)
            .font(.system(.body, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Color(.systemGray6))
            .padding(12)
    }
    
    private var actionButton: some View {
        Button(action: {
            router.showScreen(segue, animates: animates, destination: { router in
                destinationView
            }
            )
        }, label: {
            Text("Perform Segue")
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
        SegueBuilderView()
    }
}
