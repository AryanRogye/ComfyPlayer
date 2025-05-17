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
    
    var body: some View {
        ScrollView {
            VStack {
                /// Top Row: Delete Button
                /// Add A Delete Button
                HStack {
                    Spacer()
                    deleteButton()
                }
                Text("\(libs.title)")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                
                VStack {
                    ForEach(libs.videos, id: \.self) { video in
                        Text(video.path)
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
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    func deleteButton() -> some View {
        Button {
            // Delete The Library
            if let index = libsModel.libraries.firstIndex(of: libs) {
                let libToDelete : Library = libsModel.libraries[index]
                libsModel.deleteLibrary(libToDelete)
                selectedSidebarItem = .media(.videoPlayer)
            }
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
    }
}
