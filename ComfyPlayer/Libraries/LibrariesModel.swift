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
        let defaults = UserDefaults.standard
        
        if let data = defaults.data(forKey: "libraries") {
            let decoder = JSONDecoder()
            do {
                let libraries = try decoder.decode([Library].self,
                                                   from: data)
                self.libraries = libraries
            } catch {
                print("There Was An Error Loading Libraries: \(error.localizedDescription)")
            }
        }
        
        // At the End Just Print The Libraries
        for library in libraries {
            print("Library: \(library.title)")
            for video in library.videos {
                print("Video: \(video.lastPathComponent)")
            }
        }
    }
    
    func saveLibraries() {
        let defaults = UserDefaults.standard
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(libraries)
            defaults.set(data, forKey: "libraries")
        } catch {
            print("There Was An Error Saving Libraries: \(error.localizedDescription)")
        }
    }
}
