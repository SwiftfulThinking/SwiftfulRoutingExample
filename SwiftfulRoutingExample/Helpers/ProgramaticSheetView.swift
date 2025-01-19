////
////  ProgramaticSheetView.swift
////  SwiftfulRoutingExample
////
////  Created by Nick Sarno on 1/29/23.
////
//
//import SwiftUI
//import SwiftfulRouting
//
//@available(iOS 16, *)
//struct ProgramaticSheetView: View {
//    
//    let router: AnyRouter
//    let count: Int
//    
//    let detents: [PresentationDetentTransformable]
//    @Binding var selection: PresentationDetentTransformable
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            ForEach(detents, id: \.self) { detent in
//                Button(detent.title) {
//                    selection = detent
//                }
//            }
//            Button("Push") {
////                router.showScreen(.push) { router in
////                    MyView(router: router, count: count + 1)
////                }
//            }
//            Button("Dismiss") {
//                router.dismissScreen()
//            }
//        }
//    }
//
//}
//
//@available(iOS 16, *)
//struct ProgramaticSheetView_Previews: PreviewProvider {
//    
//    struct PreviewView: View {
//        
//        let detents: [PresentationDetentTransformable] = [.medium, .large, .height(150)]
//        @State private var selection: PresentationDetentTransformable = .medium
//        
//        var body: some View {
//            RouterView { router in
//                Button("Show sheet") {
//                    router.showResizableSheet(
//                        sheetDetents: Set(detents),
//                        selection: $selection,
//                        showDragIndicator: true
//                    ) { router in
//                            ProgramaticSheetView(router: router, count: 1, detents: detents, selection: $selection)
//                        }
//                }
//            }
//        }
//    }
//    
//    static var previews: some View {
//        PreviewView()
//    }
//}
