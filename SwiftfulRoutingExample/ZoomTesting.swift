//
//  ZoomTesting.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 3/9/25.
//

import SwiftUI

@available(iOS 18, *)
struct ZoomTesting: View {
    @Namespace private var namespace
    
    var body: some View {
        RouterView(addNavigationStack: true) { router in
            SourceView()
                .matchedTransitionSource(id: "abc", in: namespace)
                .onTapGesture {
                    router.showScreen(.push, id: "abc") { router2 in
                        DetailView()
                            .navigationTransition(.zoom(sourceID: "abc", in: namespace))
                    }
                }
        }
    }
}

struct DetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.black)
//            .frame(width: 250, height: 200)
            .navigationBarHidden(true)
            .onTapGesture {
                dismiss()
            }
    }
}

struct SourceView: View {
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.black)
            .frame(width: 250, height: 200)
            
            .overlay {
                Text("Create with Swift")
                    .font(.title)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
            }
            .navigationBarHidden(true)
    }
    
}

@available(iOS 18, *)
#Preview {
    ZoomTesting()
}
