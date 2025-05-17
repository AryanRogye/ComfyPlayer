//
//  ComfyPlayeriOSApp.swift
//  ComfyPlayeriOS
//
//  Created by Aryan Rogye on 5/17/25.
//

import SwiftUI

@main
struct ComfyPlayeriOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    LibrariesModel.shared.loadLibraries()
                }
        }
    }
}
