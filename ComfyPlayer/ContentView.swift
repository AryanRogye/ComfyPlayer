//
//  ContentView.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedSidebarItem: SidebarSelection?
    @StateObject private var libsModel = LibrariesModel.shared
    
    
    var body: some View {
        ZStack {
            NavigationSplitView {
                Button(action: {
                    Task {
                        await MainActor.run {
                            libsModel.loadLibraries()
                        }
                    }
                }) {
                    /// Refresh
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
                List(selection: $selectedSidebarItem) {
                    Section("Media") {
                        ForEach(ComfySection.allCases, id: \.self) { section in
                            Text(section.rawValue)
                                .tag(SidebarSelection.media(section))
                        }
                    }

                    Section("Libraries") {
                        ForEach(libsModel.libraries, id: \.self) { library in
                            Text(library.title)
                                .tag(SidebarSelection.library(library))
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            } detail: {
                
                switch selectedSidebarItem {
                case .media(.videoPlayer):
                    VideoPlayerView()
                case .media(.settings):
                    SettingsView()
                case .library(let library):
                    if let index = libsModel.libraries.firstIndex(of: library) {
                        NavigationStack {
                            LibraryView(
                                libs: $libsModel.libraries[index],
                                selectedSidebarItem: $selectedSidebarItem
                            )
                        }
                    }
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

enum SidebarSelection: Hashable {
    case media(ComfySection)
    case library(Library)
}



#Preview {
    ContentView()
}
