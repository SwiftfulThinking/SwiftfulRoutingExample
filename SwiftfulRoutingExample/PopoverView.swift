//
//  PopoverView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 8/28/23.
//

import SwiftUI

@available(iOS 16.4, *)
struct PopoverView: View {
    
    @State private var showPopover: Bool = false

    var body: some View {
        Button("CLICK ME") {
            showPopover.toggle()
        }
        .frame(width: 200, height: 200)
        .background(Color.red)
        .popover(
            isPresented: $showPopover,
            attachmentAnchor: .point(.bottomTrailing),
            arrowEdge: .top) {
//                AnotherView()
                Text("This is a popover 😎")
                    .padding()
                    .presentationCompactAdaptation(.popover)
            }
    }
}

@available(iOS 16.4, *)
struct AnotherView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button("Hi") {
            dismiss()
        }
        //.presentationCompactAdaptation(horizontal: PresentationAdaptation, vertical: PresentationAdaptation)
        .presentationCompactAdaptation(.fullScreenCover)
    }
}

@available(iOS 16.4, *)
struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
    }
}
