//
//  ComfyPlayerApp.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/16/25.
//

import SwiftUI

@main
struct ComfyPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    LibrariesModel.shared.loadLibraries()
                }
        }
    }
}
