//
//  ContentView.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedSidebarItem: SidebarSelection?
    @StateObject private var libs = LibrariesModel.shared
    
    
    var body: some View {
        ZStack {
            NavigationSplitView {
                List(selection: $selectedSidebarItem) {
                    Section("Media") {
                        ForEach(ComfySection.allCases, id: \.self) { section in
                            Text(section.rawValue)
                                .tag(SidebarSelection.media(section))
                        }
                    }

                    Section("Libraries") {
                        ForEach(libs.libraries, id: \.self) { library in
                            Text(library.title)
                                .tag(SidebarSelection.library(library.title))
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
                case .library(let title):
                    Text("Selected Library: \(title)")
                        .font(.largeTitle)
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
    case library(String)
}



#Preview {
    ContentView()
}
