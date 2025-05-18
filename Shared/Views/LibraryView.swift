//
//  LibraryView.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/16/25.
//

import SwiftUI
import AVKit

struct LibraryView: View {
    
    @StateObject private var libsModel = LibrariesModel.shared
    @Binding var libs: Library
    @Binding var selectedSidebarItem: SidebarSelection?
    @State private var expandedVideo: URL?
    @State private var downloadTrigger = UUID()
    
    /// Toolbar Controls
    @State private var showFullPath = false
    @State private var startReordering = false
    @State private var localVideos: [URL] = []
    
    var body: some View {
        VStack {
            Text("\(libs.title)")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            if !startReordering {
                ScrollView {
                    listItemsView()
                    Spacer()
                }
            } else {
                VStack {
                    reorderItemsView()
                    Spacer()
                    HStack {
                        showSaveReorderButton()
                        showCancelReorderButton()
                    }
                }
            }
        }
        .padding()
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                reorderButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                menuButton()
            }
        }
        #elseif os(macOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                reorderButton()
            }
            ToolbarItem(placement: .primaryAction) {
                menuButton()
            }
        }
        #endif
    }
    
    @ViewBuilder
    func showSaveReorderButton() -> some View {
        Button("Save Reorder") {
            saveReorderedVideos()
        }
        .buttonStyle(.bordered)
        .padding()
    }
    
    func saveReorderedVideos() {
        withAnimation {
            startReordering = false
        }

        DispatchQueue.main.async {
            libs.videos = localVideos
            libsModel.updateLibrary(libs)
            selectedSidebarItem = .library(libs)
        }
    }
    
    @ViewBuilder
    func showCancelReorderButton() -> some View {
        Button("Cancel Reorder") {
            withAnimation(.easeInOut(duration: 0.3)) {
                startReordering = false
            }
            localVideos = libs.videos
        }
        .buttonStyle(.bordered)
        .padding()
    }
    
    @ViewBuilder
    func listItemsView() -> some View {
        ForEach(libs.videos, id: \.self) { video in
            Text(showFullPath ? video.path : video.lastPathComponent)
                .font(.title3)
                .foregroundStyle(.secondary)
            dropDown(for: video)
        }
        /// Add A Button In Same Format To Add A New Video
    }
    
    @ViewBuilder
    func reorderItemsView() -> some View {
        List {
            ForEach(localVideos, id: \.self) { video in
                Text(showFullPath ? video.path : video.lastPathComponent)
                    .padding()
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .draggable(video)
            }
            .onMove { indices, newOffset in
                localVideos.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        #elseif os(macOS)
        .environment(\.appearsActive, true)
        #endif
    }
    
    @ViewBuilder
    func draggableLibrary(lib: Library) -> some View {
        VStack {
            Text(lib.title)
            Text("\(lib.id)")
        }
        .draggable(lib)
    }
    
    @ViewBuilder
    func reorderButton() -> some View {
        Menu {
            Button("Reorder", action: {
                localVideos = libs.videos
                withAnimation(.easeInOut(duration: 0.3)) {
                    startReordering = true
                }
            })
        } label: {
            Label("Reorder", systemImage: "arrow.up.arrow.down")
                .labelStyle(.iconOnly)
                .foregroundStyle(.primary)
                .contentShape(Rectangle())
        }
        .help("Reorder Items")
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    func menuButton() -> some View {
        Menu {
            Toggle("Show Full Path", isOn: $showFullPath)
            Divider()
            Button("Delete", role: .destructive, action: delete)
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    func ensureFileIsDownloaded(_ url: URL, completion: @escaping (Bool) -> Void) {
        let isDownloadedKey = URLResourceKey("NSURLUbiquitousItemIsDownloadedKey")
        
        do {
            let values = try url.resourceValues(forKeys: [
                .isUbiquitousItemKey,
                isDownloadedKey
            ])

            if values.isUbiquitousItem == true {
                if let downloaded = values.allValues[isDownloadedKey] as? Bool, downloaded {
                    print("✅ Already downloaded: \(url.lastPathComponent)")
                    completion(true)
                } else {
                    print("⏳ Not downloaded yet, requesting...")
                    try FileManager.default.startDownloadingUbiquitousItem(at: url)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        ensureFileIsDownloaded(url, completion: completion)
                    }
                }
            } else {
                print("ℹ️ Not an iCloud item — assuming local")
                completion(true)
            }
        } catch {
            print("❌ Error checking/download: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    @ViewBuilder
    func dropDown(for video: URL) -> some View {
        DisclosureGroup {
            VStack {
                Text(video.lastPathComponent)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Spacer()
                if let resolved = libsModel.resolveVideoURL(video) {
                    VideoPreviewView(player: AVPlayer(url: resolved))
                } else {
                    Button("📥 Download from iCloud") {
                        ensureFileIsDownloaded(video) { success in
                            print(success ? "✅ Downloaded!" : "❌ Still missing")
                            downloadTrigger = UUID()
                        }
                    }
                    .padding()
                }
            }
            .id(downloadTrigger)
        } label: {
            Text(video.lastPathComponent)
        }
        .padding([.horizontal, .vertical], 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    func delete() {
        if let index = libsModel.libraries.firstIndex(of: libs) {
            let libToDelete : Library = libsModel.libraries[index]
            libsModel.deleteLibrary(libToDelete)
            selectedSidebarItem = .media(.videoPlayer)
        }
    }
}

#Preview {
    NavigationStack {
        LibraryView(
            libs: Binding.constant(Library(
                title: "New Library",
                /// Array of URLs
                videos: [
                    URL(string: "https://example.com/video1.mp4")!,
                    URL(string: "https://example.com/video2.mp4")!
                ],
                id: UUID()
            )),
            selectedSidebarItem: Binding.constant(nil)
        )
    }
}
