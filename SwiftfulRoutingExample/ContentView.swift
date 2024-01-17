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
        RouterView(addNavigationView: true) { router in
            MyView(router: router, count: 0)
        }
    }
}

struct MyView: View {
    
    // Pass reference to Router directly or pull from Environment
    @Environment(\.router) var router2
    let router: AnyRouter
    
    let count: Int
    @State private var sheetSelection: PresentationDetentTransformable = .fraction(0.3)
    @State private var lastDismiss: Int = 0
    
    var body: some View {
        List {
            screenStackSection
            segueSection
            alertSection
            modalSection
            
            if #available(iOS 14, *) {
                modulesSection
            }
        }
        .navigationModifers(title: "#\(count)")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing, content: {
                Text("#\(lastDismiss)")
                    .accessibilityIdentifier("last_dismiss")
            })
        })
    }
    
    private func dismissAction(_ number: Int) {
        print("DISMISS: \(number)")
        lastDismiss = number
    }

}

private extension View {
    
    @ViewBuilder func navigationModifers(title: String) -> some View {
        if #available(iOS 14, *) {
            self
                .navigationTitle(title)
                .listStyle(InsetGroupedListStyle())
        } else {
            self
                .navigationBarTitle(Text(title))
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension MyView {
    
    // MARK: SEGUE SECTION

    @MainActor
    private var segueSection: some View {
        Section {
            Button("Push") {
                router.showScreen(.push, onDismiss: {
                    dismissAction(count + 1)
                }) { router in
                    MyView(router: router, count: count + 1)
                }
                
//                router.showScreen(.push) {
//                    Text("Another screen")
//                }
            }
            
            if #available(iOS 16, *) {
                Button("Push Stack (3x)") {
                    let screen1 = PushRoute(onDismiss: {
                        dismissAction(count + 1)
                    }, destination: { router in
                        MyView(router: router, count: count + 1)
                    })
                    let screen2 = PushRoute(onDismiss: {
                        dismissAction(count + 2)
                    }, destination: { router in
                        MyView(router: router, count: count + 2)
                    })
                    let screen3 = PushRoute(onDismiss: {
                        dismissAction(count + 3)
                    }, destination: { router in
                        MyView(router: router, count: count + 3)
                    })

                    router.pushScreenStack(destinations: [screen1, screen2, screen3])
                }
            }

            Button("Sheet") {
                router2.showScreen(AnyRoute(.sheet, onDismiss: {
                    dismissAction(count + 1)
                }, destination: { router in
                    MyView(router: router, count: count + 1)
                }))
            }
            
            if #available(iOS 16, *) {
                Button("Resizable Sheet") {
                    router.showResizableSheet(
                        sheetDetents: [.medium, .large],
                        selection: nil,
                        showDragIndicator: true,
                        onDismiss: {
                            dismissAction(count + 1)
                        }
                    ) { router in
                            MyView(router: router, count: count + 1)
                        }
                }

                Button("Resizable Sheet w/ programatic") {
                    let detents: [PresentationDetentTransformable] = [
                        .fraction(0.3),
                        .fraction(0.85),
                        .height(150),
                        .height(750),
                        .medium,
                        .large
                    ]
                    sheetSelection = detents[0]
                    
                    router.showResizableSheet(
                        sheetDetents: Set(detents),
                        selection: $sheetSelection,
                        showDragIndicator: false,
                        onDismiss: {
                            dismissAction(count + 1)
                        }
                    ) { router in
                            ProgramaticSheetView(router: router, count: count + 1, detents: detents, selection: $sheetSelection)
                        }
                }
            }

            if #available(iOS 14, *) {
                Button("FullScreenCover") {
                    router.showScreen(.fullScreenCover, onDismiss: {
                        dismissAction(count + 1)
                    }) { router in
                        MyView(router: router, count: count + 1)
                    }
                }
            }
                        
            Button("Safari") {
                router.showSafari {
                    URL(string: "https://www.google.com")!
                }
            }
        } header: {
            Text("Segues")
        }
    }
    
    // MARK: SCREEN STACK SECTION
        
    @MainActor
    private var screenStackSection: some View {
        Section {
            Button("Show Screen") {
                let screen1 = { router in
                    MyView(router: router, count: 11111)
                }
                router2.showScreen(AnyRoute(.fullScreenCover, onDismiss: {
                    dismissAction(11111)
                }, destination: screen1))
            }
            
            Button("Enter Screen Flow") {
                let screen1 = { router in
                    MyView(router: router, count: 369)
                }
                let screen2 = { router in
                    MyView(router: router, count: 444)
                }
                let screen3 = { router in
                    MyView(router: router, count: 1000000)
                }
                let screen4 = { router in
                    MyView(router: router, count: 123)
                }
                
                router2.enterScreenFlow([
                    AnyRoute(.fullScreenCover, onDismiss: {
                        dismissAction(369)
                    }, destination: screen1),
                    AnyRoute(.push, onDismiss: {
                        dismissAction(444)
                    }, destination: screen2),
                    AnyRoute(.push, onDismiss: {
                        dismissAction(1000000)
                    }, destination: screen3),
                    AnyRoute(.push, onDismiss: {
                        dismissAction(123)
                    }, destination: screen4),
                ])
            }
            
            Button("Next Screen") {
                do {
                    try router.showNextScreen()
                } catch {
                    router.showBasicAlert(text: "No next screen set.")
                }
            }
            
            Button("Dismiss") {
                router.dismissScreen()
            }
            
            if #available(iOS 16, *) {
                Button("Dismiss Screen Stack") {
                    router.dismissScreenStack()
                }
            }
            
            Button("Dismiss Environment") {
                router.dismissEnvironment()
            }
            
            Button("Next Screen or Dismiss Environment") {
                router.showNextScreenOrDismissEnvironment()
            }
        } header: {
            Text("Screen Stack")
        }

    }
    
    // MARK: ALERT SECTION

    @MainActor
    private var alertSection: some View {
        Section {
            Button("Alert") {
                router.showAlert(.alert, title: "Title goes here", subtitle: "Subtitle goes here!", alert: {
                    alertButtonsiOS15
                }, buttonsiOS13: alertButtonsiOS13)
            }
            
            if #available(iOS 15, *) {
                Button("Alert2") {
                    router.showAlert(.alert, title: "Title goes here", subtitle: nil, alert: {
                        alertButtonsiOS15
                    })
                }
            }

            
            Button("Basic Alert") {
                router.showBasicAlert(text: "Title goes here")
            }

            Button("ConfirmationDialog") {
                router.showAlert(.confirmationDialog, title: "Title goes here", subtitle: "Subtitle goes here!", alert: {
                    alertButtonsiOS15
                }, buttonsiOS13: alertButtonsiOS13)
            }
        } header: {
            Text("Alerts")
        }
    }
    
    @ViewBuilder private var alertButtonsiOS15: some View {
        if #available(iOS 15.0, *) {
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
        } else {
            EmptyView()
        }
    }
    
    private var alertButtonsiOS13: [Alert.Button] {
        [
            Alert.Button.default(Text("Default"), action: {
                
            }),
            Alert.Button.cancel(Text("Cancel"), action: {
                
            }),
            Alert.Button.destructive(Text("Destructive"), action: {
                
            }),
        ]
    }
    
    // MARK: MODAL SECTION

    @MainActor
    private var modalSection: some View {
        Section {
            Button("Basic") {
                router.showBasicModal {
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
                router.showModal(
                    transition: .opacity,
                    backgroundColor: Color.black.opacity(0.001),
                    useDeviceBounds: false) {
                    Text("Sample")
                        .frame(width: 275, height: 450)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
            
            Button("Opacity w/ background color & blur") {
                router.showModal(
                    transition: .opacity,
                    backgroundColor: Color.black.opacity(0.3),
                    backgroundEffect: BackgroundEffect(
                        effect: UIBlurEffect(style: .systemMaterialDark),
                        opacity: 0.85)
                ) {
                    Text("Sample")
                        .frame(width: 275, height: 450)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            router.dismissModal()
                        }
                }
            }
            
            Button("Top") {
                router.showModal(transition: .move(edge: .top), animation: .easeInOut, alignment: .top, backgroundColor: Color.black.opacity(0.001), useDeviceBounds: true) {
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
                router.showModal(transition: .move(edge: .top), animation: .easeInOut, alignment: .top, backgroundColor: Color.black.opacity(0.001), useDeviceBounds: false) {
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
                router.showModal(transition: .move(edge: .trailing), animation: .easeInOut, alignment: .leading, backgroundColor: Color.black.opacity(0.001)) {
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
                router.showModal(transition: .scale, backgroundColor: Color.black.opacity(0.001), useDeviceBounds: false) {
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
    
    @available(iOS 14, *)
    @MainActor
    private var modulesSection: some View {
        Section {
            Button("MVVM w/ routing in View\n+ data service") {
                router.showScreen(.push) { router in
                    ExampleView(
                        router: router,
                        viewModel: ExampleViewModel(service: DataService())
                    )
                }
            }
            
            Button("MVVM w/ routing in ViewModel\n+ data service") {
                router.showScreen(.push) { router in
                    SampleView(viewModel: SampleViewModel(
                        router: router,
                        service: DataService())
                    )
                }
            }
            
            Button("MVVM w/ routing in ViewModel\n+ data service delegate") {
                let delegate = BasicViewModelDelegate_Production(service: DataService())
                
                router.showScreen(.push) { router in
                    BasicView(viewModel: BasicViewModel(
                        router: router,
                        delegate: delegate))
                }
            }
            
            Button("VIPER w/ routing in delegate\n+ data service delegate") {
                let interactor = HomeInteractor_Production(service: DataService())
                
                router.showScreen(.push) { router in
                    HomeView(presenter: HomePresenter(
                        router: HomeRouter_Production(router: router),
                        interactor: interactor))
                }
            }
        } header: {
            Text("Modules")
        }
    }

    
}

