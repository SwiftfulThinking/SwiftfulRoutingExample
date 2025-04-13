//
//  AnyDestinationStack.swift
//  SwiftfulRoutingExample
//
//  Created by Nick Sarno on 2/17/25.
//
import SwiftUI

struct AnyDestinationStack: Equatable {
    private(set) var segue: SegueOption
    var screens: [AnyDestination]
}

extension Array where Element == AnyDestinationStack {
    
    func lastIndexWhereChildStackContains(routerId: String) -> Int? {
        self.lastIndex { stack in
            return stack.screens.contains(where: { $0.id == routerId })
        }
    }
    
    var allScreens: [AnyDestination] {
        flatMap({ $0.screens })
    }
}

/*
 
 AnyDestinationStack is an array that will contain either:
 - 1 .sheet
 - 1 .fullScreenCover
 - any number of .push
 
 When the user goes to a new environment (a sheet or fullScreenCover), the system will add 2 AnyDestinationStacks to the heirarchy.
 First will be the environment stack (ie. [.sheet]), followed by a push stack that begins as a blank array.
 
 A typical new environment would looke like:
 
 [
    [.fullScreenCover]
    []
 ]
 
 If the user segues via .push, then the push stack will populate.
 
 [
    [.fullScreenCover]
    [.push, .push, .push, .push]
 ]
 
 This will continue until the user enters another new environment.
 
 [
    [.fullScreenCover]
    [.push, .push, .push, .push]
    [.sheet]
    []
 ]
 
 And the pattern continues indefinately...
 
 [
    [.fullScreenCover]
    [.push, .push, .push, .push]
    [.sheet]
    []                         <- these empty stacks in-between would be for .pushes that never occured
    [.sheet]
    [.push]
    [.fullScreenCover]
    [.push, .push]
 ]
 
 
 Here are some more examples:
 
 STACK: .fullScreenCover, .push, .push, .push:
 
 [
     [.fullScreenCover]
     [.push, .push, .push]
 ]
 
 
 STACK .fullScreenCover, .push, .push, .sheet, .push:
 
 [
     [.fullScreenCover]
     [.push, .push]
     [.sheet]
     [.push]
 ]
 
 STACK .fullScreenCover, .sheet, .push, .sheet:
 
 [
     [.fullScreenCover]
     []
     [.sheet]
     [.push]
     [.sheet]
     []
 ]
 
 STACK .fullScreenCover, .fullScreenCover, .fullScreenCover:
 
 [
     [.fullScreenCover]
     []
     [.fullScreenCover]
     []
     [.fullScreenCover]
     []
 ]
 */
