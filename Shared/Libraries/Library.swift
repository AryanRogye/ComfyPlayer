//
//  Library.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/16/25.
//
import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct Library: Codable ,Identifiable, Hashable, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .libraryTask)
    }
    
    let title: String
    var videos: [URL]
    let id: UUID
}

extension UTType {
    static var libraryTask: UTType { UTType(exportedAs: "com.aryanrogye.ComfyPlayer.library") }
}
