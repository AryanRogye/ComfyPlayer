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
                        Text(FileManager.default.fileExists(atPath: video.path) ? "✅ Exists" : "❌ Missing")
                        dropDown(for: video)
                    }
                    /// Add A Button In Same Format To Add A New Video
                }
                Spacer()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func dropDown(for video: URL) -> some View {
        DisclosureGroup {
            HStack {
                Text(video.lastPathComponent)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Spacer()
                VideoPreviewView(player: AVPlayer(url: video))
                    .frame(minHeight: 400)
                    .cornerRadius(12)
                    .padding()
            }
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
                libsModel.libraries.remove(at: index)
                libsModel.saveLibraries()
                selectedSidebarItem = .media(.videoPlayer)
            }
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
    }
}
