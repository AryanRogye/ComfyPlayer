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
    
    @State private var showMenu = false
    @State private var showFullPath = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text("\(libs.title)")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                VStack {
                    ForEach(libs.videos, id: \.self) { video in
                        Text(showFullPath ? video.path : video.lastPathComponent)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        dropDown(for: video)
                    }
                    /// Add A Button In Same Format To Add A New Video
                }
                Spacer()
            }
            .padding()
        }
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
    func reorderButton() -> some View {
        Button(action: {}) {
            Label("Reorder", systemImage: "arrow.up.arrow.down")
                .labelStyle(.iconOnly)
                .foregroundStyle(.primary)
                .contentShape(Rectangle()) // helps with tap area
        }
        .help("Reorder Items") // shows tooltip on macOS
        .buttonStyle(.borderless) // blends well in toolbars or context menus
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
