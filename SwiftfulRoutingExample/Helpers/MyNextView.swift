//
//  MyNextView.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 1/29/23.
//

import SwiftUI

struct MyNextView: View {
    
    let title: String
    
    var body: some View {
        Text(title)
    }
}

struct MyNextView_Previews: PreviewProvider {
    static var previews: some View {
        MyNextView(title: "Hello, world!")
    }
}
