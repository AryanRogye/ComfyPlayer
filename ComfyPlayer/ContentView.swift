//
//  ContentView.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMediaSection: ComfySection? = .videoPlayer
    @State private var selectedLibraryTitle: String?
    @StateObject private var libs = LibrariesModel.shared
    
    
    var body: some View {
        ZStack {
            NavigationSplitView {
                List(selection: $selectedMediaSection) {
                    Section("Media") {
                        ForEach(ComfySection.allCases, id: \.self) { section in
                            Text(section.rawValue)
                                .tag(section)
                        }
                    }
                    Section("Libraries") {
                        ForEach(libs.libraries, id: \.self) { library in
                            Text(library.title)
                                .tag(library.title)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                .navigationTitle("Comfy Player")
                
            } detail: {
                switch selectedMediaSection {
                case .videoPlayer:
                    VideoPlayerView()
                case .settings:
                    SettingsView()
                default:
                    Text("Select a section")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationSplitViewStyle(.balanced)
        }
        .frame(minWidth: 750, minHeight: 600)
    }
}

enum ComfySection: String, CaseIterable, Identifiable {
    case videoPlayer = "Video Player"
    case settings = "Settings"
    
    var id: String { rawValue }
}

extension ComfySection {
    static var mediaSections: [ComfySection] = [.videoPlayer, .settings]
    static var librarySections: [ComfySection] = []
}



#Preview {
    ContentView()
}
