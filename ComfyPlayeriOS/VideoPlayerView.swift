//
//  VideoPlayerView.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/17/25.
//

import SwiftUI
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
                            imageDropper()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    /// Currently Added Videos Paths In Library
                    VStack {
                        ForEach(self.libraryVideos, id: \.self) { video in
                            Text(video.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
                                .fill(Color.gray.opacity(0.1))
                        )
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Library name can't be empty", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Photo Library Access Denied", isPresented: $showPhotoAlertDenied) {
            Button("OK", role: .cancel) { }
        }
    }
    
    /// Onboarding Video Controls
    @ViewBuilder
    func showVideoControls(for video: URL) -> some View {
        showSelectedPath(video)
        showSelectedVideo(video)
        addCurrentVideo(video)
        clearCurrentVideo(video)
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
    func showSelectedVideo(_ video: URL) -> some View {
//        VideoPreviewView(player: AVPlayer(url: video))
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
            .padding(8)
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
    func imageDropper() -> some View {
        ZStack {
            Button(action: openVideoPicker ) {
                Text("Add Video Here")
                    .font(.system(size: 17, weight: .regular, design: .monospaced))
                    .padding(25)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .opacity(0.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.25))
                    )
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
//       Mark: -  Use Later When Saving We Asked
//        let readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
//        
//        if readWriteStatus == .notDetermined {
//            
//        }
//        else if readWriteStatus == .denied {
//            showPhotoAlertDenied = true
//            return
//        } else if readWriteStatus == .restricted {
//            showPhotoAlertDenied = true
//            return
//        } else if readWriteStatus == .authorized {
//            openPicker()
//        }
        
    
    func openPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .videos

        let delegate = PickerDelegate { url in
            if let url = url {
                selectedVideo = url
            }
        }
        pickerDelegate = delegate // ✅ retain it

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = delegate

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(picker, animated: true)
        }
    }
}

#Preview {
    VideoPlayerView()
}
