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
    
    func saveLibraries() {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.aryanrogye.ComfyPlayer") else {
            print("❌ iCloud container not available")
            return
        }
        let docsURL = containerURL.appendingPathComponent("Documents", isDirectory: true)
        try? FileManager.default.createDirectory(at: docsURL, withIntermediateDirectories: true)
        let dbURL = docsURL.appendingPathComponent("libraries.json")
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(libraries)
            try data.write(to: dbURL, options: .atomic)
            print("✅ Saved libraries to iCloud: \(dbURL)")
        } catch {
            print("❌ Failed to save libraries to iCloud: \(error.localizedDescription)")
        }
    }
}
