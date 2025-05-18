//
//  SettingsView.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/18/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            showDeleteAllCloudKitDB()
            Spacer()
        }
    }
    
    @ViewBuilder
    func showDeleteAllCloudKitDB() -> some View {
        Button("Delete All CloudKit DB") {
            clearICloudFiles()
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    
    func clearICloudFiles() {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.aryanrogye.ComfyPlayer") else { return }
        let docsURL = containerURL.appendingPathComponent("Documents", isDirectory: true)

        if let contents = try? FileManager.default.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: nil) {
            for file in contents {
                try? FileManager.default.removeItem(at: file)
                print("🗑️ Deleted: \(file.lastPathComponent)")
            }
        }
    }
}


#Preview {
    SettingsView()
}
