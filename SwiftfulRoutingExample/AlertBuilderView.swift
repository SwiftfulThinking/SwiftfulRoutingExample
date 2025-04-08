//
//  AlertBuilderView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 4/7/25.
//

import SwiftUI

struct AlertBuilderView: View {
    
    @Environment(\.router) var router
    
    @State private var style: AlertStyle = .alert
    @State private var showSubtitle: Bool = false
    @State private var showMultipleButtons: Bool = false
    @State private var showTextfield: Bool = false

    var body: some View {
        VStack {
            List {
                Picker("Style", selection: $style) {
                    ForEach(AlertStyle.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                
                Toggle("Show subtitle: \(showSubtitle.description)", isOn: $showSubtitle)
                Toggle("Multiple buttons: \(showMultipleButtons.description)", isOn: $showMultipleButtons)
                
                if style == .alert {
                    Toggle("Textfield: \(showTextfield.description)", isOn: $showTextfield)
                }
            }
            
            codeView
            
            HStack(spacing: 12) {
                actionButton
                copyButton
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Alert Builder")
        .padding(.bottom, 8)
    }
    
    private var codeString: String {
        var string = """
router.showAlert(
  \(style.codeString),
  title: "Title"
"""
        if showSubtitle {
            string += """
,
  subtitle: "Subtitle"
"""
        }
        
        if showTextfield || showMultipleButtons {
                string += """
,
  buttons: {
"""
            
            if showMultipleButtons {
                string += """

    Button("One", role: .none, action: { })
    Button("Two", role: .destructive, action: { })
    Button("Cancel", role: .cancel, action: { })
"""
            }
            
            if showTextfield {
                string += """
    
    TextField("Hello...", text: $textFieldText)
    Button("Submit", action: { })
"""
            }
            
            string += """

  }
)
"""
        } else {
            string += """

)
"""
        }
        
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
            if showTextfield || showMultipleButtons {
                var textfieldText: String = ""
                router.showAlert(
                    style,
                    title: "Title",
                    subtitle: showSubtitle ? "Subtitle" : nil,
                    buttons: {
                        if showMultipleButtons {
                            Button("One", role: .none, action: {
                                
                            })
                            Button("Two", role: .destructive, action: {
                                
                            })
                            Button("Cancel", role: .cancel, action: {
                                
                            })
                        }
                        if showTextfield {
                            TextField("Enter your name", text: Binding(get: {
                                textfieldText
                            }, set: { newValue in
                                textfieldText = newValue
                            }))
                            
                            Button("Submit", action: {
                                print(textfieldText)
                            })
                        }
                    }
                )
            } else {
                router.showAlert(
                    style,
                    title: "Title",
                    subtitle: showSubtitle ? "Subtitle" : nil
                )
            }
        }, label: {
            Text("Trigger alert")
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
        AlertBuilderView()
    }
}
