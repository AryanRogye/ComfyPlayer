//
//  Library.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/16/25.
//
import Foundation

struct Library: Encodable, Decodable, Identifiable, Hashable {
    let title: String
    let videos: [URL]
    let id: UUID
}
