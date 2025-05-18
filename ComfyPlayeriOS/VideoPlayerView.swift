//
//  VideoPlayerView.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/17/25.
//

import SwiftUI
import UIKit
import AVKit
import UniformTypeIdentifiers
import PhotosUI

struct VideoPlayerView: View {
    
    @State private var libraryName: String = ""
    @State private var libraryVideos: [URL] = []
    
    @State private var selectedVideo: URL? = nil
    @State private var isDroppingFiles: Bool = false
    
    @State private var libraryID: UUID = UUID()
    @State var showAlert: Bool = false
    @State var showPhotoAlertDenied: Bool = false
    @State private var pickerDelegate: PickerDelegate? = nil
    @State private var currentPlayer: AVPlayer? = nil
    
    init(
        libraryName: String = "",
        libraryVideos: [URL] = [],
        selectedVideo: URL? = nil,
        isDroppingFiles: Bool = false
    ) {
        _libraryName = State(initialValue: libraryName)
        _libraryVideos = State(initialValue: libraryVideos)
        _selectedVideo = State(initialValue: selectedVideo)
        _isDroppingFiles = State(initialValue: isDroppingFiles)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                /// Top Bar
                ///  - Library Name
                HStack {
                    pickLibraryName()
                }
                .padding([.horizontal, .top], 10)
                

                VStack {
                    /// Getting Added Video
                    VStack {
                        if let video = selectedVideo {
                            /// If Video Is Added
                            showVideoControls(for: video)
                        } else {
                            /// Show Outline To Drop Video
                            addVideo()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    /// Currently Added Videos Paths In Library
                    ForEach(self.libraryVideos, id: \.self) { video in
                        Text(video.lastPathComponent)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.1))
                            )
                            .padding(.horizontal, 10)
                    }
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                /// Save Library Button
                Button(action: {
                    if libraryName.isEmpty || libraryVideos.isEmpty {
                        /// Show Alert on screen
                        showAlert = true
                        return
                    }
                    LibrariesModel.shared.updateLibrary(Library(
                        title: libraryName,
                        videos: libraryVideos,
                        id: libraryID
                    ))
                    libraryName = ""
                    libraryVideos = []
                    selectedVideo = nil
                    libraryID = UUID()
                }) {
                    Text("Save Library")
                        .font(.callout)
                        .padding([.vertical, .horizontal], 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.1))
                        )
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("No Videos or Library Name Not Provided", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Photo Library Access Denied", isPresented: $showPhotoAlertDenied) {
            Button("OK", role: .cancel) { }
        }
    }
    
    // Mark: - View's
    @ViewBuilder
    func showVideoControls(for video: URL) -> some View {
        if let player = currentPlayer, let video = selectedVideo {
            showSelectedPath(video)
            VideoPreviewView(player: player)
            addCurrentVideo(video)
            clearCurrentVideo(video)
        }
    }
    
    @ViewBuilder
    func addCurrentVideo(_ video: URL) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                libraryVideos.append(video)
                selectedVideo = nil
            }
        }) {
            Text("Add Video")
                .font(.caption)
                .padding([.vertical, .horizontal], 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    func clearCurrentVideo(_ video: URL) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedVideo = nil
            }
        }) {
            Text("Clear Video")
                .font(.caption)
                .padding([.vertical, .horizontal], 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    func showSelectedPath(_ video: URL) -> some View {
        Text("Selected: \(video.path)")
            .font(.subheadline)
            .foregroundColor(.gray)
    }
    
    @ViewBuilder
    func pickLibraryName() -> some View {
        TextField("Library Name", text: $libraryName)
            .textFieldStyle(PlainTextFieldStyle())
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.1))
            )
    }
    
    @ViewBuilder
    func addVideo() -> some View {
        ZStack {
            Button(action: openVideoPicker ) {
                Text("Add Video")
                    .font(.system(size: 17, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.gray.opacity(0.06))
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    func pickVideo() -> some View {
        Button(action: openVideoPicker ) {
            Text("Add Videos")
                .font(.callout)
                .padding([.vertical, .horizontal], 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
    
    // Mark: - Functions
    
    func openVideoPicker() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    openPicker()
                case .denied, .restricted:
                    showPhotoAlertDenied = true
                default:
                    break
                }
            }
        }
    }
    
    func openPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        config.filter = .videos

        let picker = PHPickerViewController(configuration: config)
        let delegate = PickerDelegate { url in
            if let url = url {
                self.currentPlayer = AVPlayer(url: url)
                self.selectedVideo = url
            }
        }
        picker.delegate = delegate
        self.pickerDelegate = delegate
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController {
            rootVC.present(picker, animated: true)
        }
    }
}


#Preview {
    VideoPlayerView()
}
