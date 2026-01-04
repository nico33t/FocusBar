//
//  FocusBarApp.swift
//  FocusBar
//
//  Created by Nicola Tomassini on 05/01/26.
//

import SwiftUI

@main
struct FocusBarApp: App {
    var body: some Scene {
        // MenuBarExtra crea l'icona nella barra in alto
        MenuBarExtra("FocusBar", systemImage: "timer") {
            TimerView()
        }
        .menuBarExtraStyle(.window) // Questo rende la finestra un pop-up moderno stile iOS
    }
}
