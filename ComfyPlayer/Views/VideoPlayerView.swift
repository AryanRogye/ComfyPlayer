//
//  VideoPlayerView.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/16/25.
//
import SwiftUI
import UniformTypeIdentifiers

struct VideoPlayerView: View {
    
    @State private var libraryName: String = ""
    @State private var libraryVideos: [URL] = []
    
    @State private var selectedVideo: URL? = nil
    @State private var isDroppingFiles: Bool = false
    
    @State private var libraryID: UUID = UUID()
    
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
                ///  - Add Video Button
                HStack {
                    pickLibraryName()
                    pickVideo()
                }
                .padding([.horizontal, .top], 10)
                

                HStack {
                    
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
                    
                    Divider()
                        .frame(maxHeight: .infinity)
                    
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
        VideoPreviewView(videoURL: video)
    }
    
    @ViewBuilder
    func showSelectedPath(_ video: URL) -> some View {
        Text("Selected: \(video.lastPathComponent)")
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
        .onDrop(of: [UTType.fileURL.identifier, UTType.image.identifier], isTargeted: $isDroppingFiles) { providers in
            handleDrop(providers: providers)
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
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedVideo = panel.url
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        
        let fm = FileManager.default
        let sessionDir = fm.temporaryDirectory.appendingPathComponent("FileDropperSession-\(UUID().uuidString)", isDirectory: true)
        try? fm.createDirectory(at: sessionDir, withIntermediateDirectories: true)
        
        for provider in providers {
            /// ---------- Finder files ----------
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                
                provider.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.fileURL.identifier) {
                    url, inPlace, _ in
                    guard let srcURL = url else { return }

                    let fileName = UUID().uuidString + ".mov" // Default fallback extension
                    let dstURL = sessionDir.appendingPathComponent(fileName)

                    do {
                        try FileManager.default.copyItem(at: srcURL, to: dstURL)

                        if let typeID = try? dstURL.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier,
                           let type = UTType(typeID),
                           type.conforms(to: .movie) {
                            print("🎥 Accepted video file: \(fileName)")
                            processFile(at: dstURL, copyIfNeeded: false, sessionDir: sessionDir)
                        } else {
                            print("❌ File is not a recognized video type: \(fileName)")
                        }
                    } catch {
                        print("❌ Failed to copy temp file: \(error.localizedDescription)")
                    }
                }
                
            // ---------- Images / screenshots ----------
            } else if provider.canLoadObject(ofClass: NSImage.self) {
                _ = provider.loadObject(ofClass: NSImage.self) { object, _ in
                    guard let img = object as? NSImage,
                          let tiff = img.tiffRepresentation,
                          let rep  = NSBitmapImageRep(data: tiff),
                          let png  = rep.representation(using: .png, properties: [:])
                    else { return }
                    
                    let tmpURL = sessionDir.appendingPathComponent(
                        "DroppedImage-\(UUID()).png")
                    
                    Task.detached(priority: .utility) {
                        try? png.write(to: tmpURL)   // fast, one write
                        await processFile(at: tmpURL,
                                          copyIfNeeded: false,
                                          sessionDir: sessionDir)
                    }
                }
            }
            
            // ---------- Promised files ----------
            else if provider.registeredTypeIdentifiers.contains("com.apple.filepromise") {
                provider.loadDataRepresentation(forTypeIdentifier: "com.apple.filepromise") { _, error in
                    if let error = error {
                        print("❌ Failed to receive file promise: \(error)")
                        return
                    }
                    print("ℹ️ File promise received — but not handled in this version")
                }
            }
        }
        
        return true
    }
    
    private func processFile(at url: URL,
                             copyIfNeeded: Bool,
                             sessionDir: URL) {
        /// We now know the file is a video we can set the URL
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedVideo = url
        }
    }

}

#Preview {
    VideoPlayerView(
        selectedVideo: URL(string: "/Users/aryanrogye/Downloads/StillrOutput_NewLogo.mp4")
    )
}
