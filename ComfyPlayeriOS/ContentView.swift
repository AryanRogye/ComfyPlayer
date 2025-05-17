//
//  ContentView.swift
//  ComfyPlayeriOS
//
//  Created by Aryan Rogye on 5/17/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedSidebarItem: SidebarSelection?
    @StateObject private var libsModel = LibrariesModel.shared
    
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
                case .library(let library):
                    if let index = libsModel.libraries.firstIndex(of: library) {
                        LibraryView(
                            libs: $libsModel.libraries[index],
                            selectedSidebarItem: $selectedSidebarItem
                        )
                    }
                default:
                    Text("Please Select A Library")
                }
            }
            .navigationSplitViewStyle(.prominentDetail)
        }
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
