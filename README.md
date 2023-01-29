# Example project for SwiftfulRouting framework 🚀

SwiftfulRouting is a native, declarative framework for programmatic navigation (routing) in SwiftUI applications, fully decoupled from the View.

**Sample project:** https://github.com/SwiftfulThinking/SwiftfulRouting

## Overview

`ContentView` is a showcase of all routing methods.

<img src="https://user-images.githubusercontent.com/44950578/215352124-e4f68b93-38fc-4d08-a6e7-fa8489c8fe74.png" width="300">

## Architectures

Included in the project are a few sample architectures that work well with the SwiftUI + SwiftfulRouting frameworks.

### 1. MVVM (View Routing)

This is a simple MVVM approach where the View remains in control of the routing.

### 2. MVVM (ViewModel Routing)

Another MVVM approach where the router is injected into the ViewModel.

### 3. MVVM (ViewModel Routing + Delegate)

Same as previous, except it adds a delegate for the data service. This is a stepping stone between #2 & #4.

### 4. VIPER (Delegate Routing)

A VIPER module that is native to SwiftUI that allows for injection of data and routing layers. The 'ViewModel' in MVVM becomes the 'Presenter' in VIPER. 
