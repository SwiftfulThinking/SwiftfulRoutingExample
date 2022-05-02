//
//  ContentView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 5/2/22.
//

import SwiftUI
import SwiftfulRouting

struct ContentView: View {
    var body: some View {
        RouterView {
            MyView(count: 0)
        }
    }
}

struct MyView: View {
    
    @EnvironmentObject private var router: Router
    let count: Int
    
    var body: some View {
        List {
            segueSection
            alertSection
            modalSection
        }
        .navigationBarHidden(true)
        .navigationTitle("#\(count)")
        .listStyle(InsetGroupedListStyle())
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension MyView {
    
    // MARK: SEGUE SECTION

    private var segueSection: some View {
        Section {
            Button("Push") {
                router.showScreen(.push) {
                    MyView(count: count + 1)
                }
            }

            Button("Sheet") {
                router.showScreen(.sheet) {
                    MyView(count: count + 1)
                }
            }

            Button("FullScreenCover") {
                router.showScreen(.fullScreenCover) {
                    MyView(count: count + 1)
                }
            }
            
            Button("Dismiss") {
                router.dismissScreen()
            }
        } header: {
            Text("Segues")
        }
    }
    
    // MARK: ALERT SECTION

    private var alertSection: some View {
        Section {
            Button("Alert") {
                router.showAlert(.alert, title: "Title goes here") {
                    alertButtons
                }
            }

            Button("ConfirmationDialog") {
                router.showAlert(.confirmationDialog, title: "Title goes here") {
                    alertButtons
                }
            }
        } header: {
            Text("Alerts")
        }
    }
    
    @ViewBuilder private var alertButtons: some View {
        Button(role: .none) {
            
        } label: {
            Text("Default")
        }
        Button(role: .cancel) {
            
        } label: {
            Text("Cancel")
        }
        Button(role: .destructive) {
            
        } label: {
            Text("Destructive")
        }
    }
    
    // MARK: MODAL SECTION

    private var modalSection: some View {
        Section {
            Button("Top") {
                router.showModal(transition: .move(edge: .top), animation: .easeInOut, alignment: .top, backgroundColor: nil, useDeviceBounds: true) {
                    Text("Sample")
                        .frame(maxWidth: .infinity)
                        .frame(height: 70, alignment: .bottom)
                        .padding()
                        .background(Color.blue)
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
            
            Button("Top 2") {
                router.showModal(transition: .move(edge: .top), animation: .easeInOut, alignment: .top, backgroundColor: nil, useDeviceBounds: false) {
                    Text("Sample")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
            
            Button("Bottom") {
                router.showModal(transition: .move(edge: .bottom), animation: .easeInOut, alignment: .bottom, backgroundColor: Color.black.opacity(0.35), useDeviceBounds: true) {
                    Text("Sample")
                        .frame(maxWidth: .infinity)
                        .frame(height: 350)
                        .background(Color.blue)
                        .cornerRadius(30)
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
            
            Button("Bottom 2") {
                router.showModal(transition: .move(edge: .bottom), animation: .spring(), alignment: .center, backgroundColor: Color.black.opacity(0.35), useDeviceBounds: false) {
                    Text("Sample")
                        .frame(width: 275, height: 450)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
            
            Button("Leading") {
                router.showModal(transition: .move(edge: .leading), animation: .easeInOut, alignment: .leading, backgroundColor: Color.black.opacity(0.35), useDeviceBounds: true) {
                    Text("Sample")
                        .frame(maxHeight: .infinity)
                        .frame(width: 200)
                        .background(Color.blue)
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
            
            Button("Trailing") {
                router.showModal(transition: .move(edge: .trailing), animation: .easeInOut, alignment: .leading) {
                    Text("Sample")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
            
            Button("Scale") {
                router.showModal(transition: .scale, useDeviceBounds: false) {
                    Text("Sample")
                        .frame(width: 275, height: 450)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
            
            Button("Opacity") {
                router.showModal(transition: .opacity, backgroundColor: Color.black.opacity(0.35), useDeviceBounds: false) {
                    Text("Sample")
                        .frame(width: 275, height: 450)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
        } header: {
            Text("Modal Examples")
        }
    }
    
}
