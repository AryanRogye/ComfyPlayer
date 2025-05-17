//
//  LibrariesModel.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/16/25.
//

import Foundation

class LibrariesModel: ObservableObject {
    static let shared = LibrariesModel()
    @Published var libraries: [Library] = []
    
    init() {}
    
    /// Update Library will only be used to Add/Update Because We will Check At Every "Update" if
    /// The Library Already Exists and add to that or else we add a new one
    func updateLibrary(_ library: Library) {
        /// We Can Check The Libaries ID for Uniqueness
        if let index = libraries.firstIndex(where: { $0.id == library.id }) {
            libraries[index] = library
        } else {
            libraries.append(library)
        }
        /// Save Libraries to Disk
        saveLibraries()
    }
    
    func deleteLibrary(_ library: Library) {
        if let index = libraries.firstIndex(where: { $0.id == library.id }) {
            libraries.remove(at: index)
        }
        /// Save Libraries to Disk
        saveLibraries()
    }
    
    /// Load Libraries That Were Saved On Disk
    func loadLibraries() {
        guard FileManager.default.ubiquityIdentityToken != nil else {
            print("⚠️ User is not signed into iCloud")
            return
        }
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.aryanrogye.ComfyPlayer") else {
            print("❌ iCloud container not available")
            return
        }
        let dbURL = containerURL.appendingPathComponent("Documents/libraries.json")
        
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: dbURL)
            let libraries = try decoder.decode([Library].self, from: data)
            self.libraries = libraries
        } catch {
            print("❌ Failed to load libraries from iCloud: \(error.localizedDescription)")
        }
        
        // At the End Just Print The Libraries
        for library in libraries {
            print("Library: \(library.title)")
            for video in library.videos {
                print("Video: \(video.path)")
            }
        }
    }
    
    func resolveVideoURL(_ originalURL: URL) -> URL? {
        guard let container = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.aryanrogye.ComfyPlayer") else {
            print("❌ iCloud container not found")
            return nil
        }

        let filename = originalURL.lastPathComponent
        let resolvedURL = container
            .appendingPathComponent("Documents/Videos")
            .appendingPathComponent(filename)

        print("Resolving video URL: \(filename) → \(resolvedURL.path)")

        // iOS iCloud download status handling
        #if os(iOS)
        let downloadStatusKey = URLResourceKey("NSURLUbiquitousItemDownloadingStatusKey")
        let statusCurrent = "NSURLUbiquitousItemDownloadingStatusCurrent"

        do {
            let values = try resolvedURL.resourceValues(forKeys: [downloadStatusKey])
            if let status = values.allValues[downloadStatusKey] as? String {
                print("📦 Download status: \(status)")
                if status != statusCurrent {
                    try FileManager.default.startDownloadingUbiquitousItem(at: resolvedURL)
                    print("📥 Started downloading \(filename)")
                    return nil // Still downloading
                }
            }
        } catch {
            print("❌ Error checking/downloading iCloud file: \(error.localizedDescription)")
            return nil
        }
        #endif

        return resolvedURL
    }
    
    func saveLibraries() {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.aryanrogye.ComfyPlayer") else {
            print("❌ iCloud container not available")
            return
        }
        let docsURL = containerURL.appendingPathComponent("Documents", isDirectory: true)
        let videosURL = docsURL.appendingPathComponent("Videos", isDirectory: true)
        
        /// Creating the Documents And Videos Directory If It Doesn't Exist
        if !FileManager.default.fileExists(atPath: docsURL.path) {
            try? FileManager.default.createDirectory(at: docsURL, withIntermediateDirectories: true)
        }
        if !FileManager.default.fileExists(atPath: videosURL.path) {
            try? FileManager.default.createDirectory(at: videosURL, withIntermediateDirectories: true)
        }
        
        let normalizedLibraries = normalizeLibraries(videosURL: videosURL)
        
        let dbURL = docsURL.appendingPathComponent("libraries.json")
        /// Encoding the Libraries to JSON
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(normalizedLibraries)
            try data.write(to: dbURL, options: .atomic)
            print("✅ Saved libraries to iCloud: \(dbURL)")
        } catch {
            print("❌ Failed to save libraries to iCloud: \(error.localizedDescription)")
        }
    }
    
    func normalizeLibraries(videosURL: URL) -> [Library] {
        var normLibs: [Library] = []
        
        for library in libraries {
            var newVideoURLs: [URL] = []
            
            /// Loop Through the libraries videos and copy them to the iCloud folder
            for originalURL in library.videos {
                let destination = videosURL.appendingPathComponent(originalURL.lastPathComponent)
                
                if originalURL != destination {
                    // Copy the video into iCloud folder if it's not already there
                    try? FileManager.default.copyItem(at: originalURL, to: destination)
                }
                newVideoURLs.append(destination)
            }
            let newLib = Library(title: library.title, videos: newVideoURLs, id: library.id)
            normLibs.append(newLib)
        }
        return normLibs
    }
}
