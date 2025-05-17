//
//  PickerDelegate.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/17/25.
//

import UIKit
import PhotosUI

class PickerDelegate: NSObject, PHPickerViewControllerDelegate {
    let onPick: (URL?) -> Void

    init(onPick: @escaping (URL?) -> Void) {
        self.onPick = onPick
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else {
            onPick(nil)
            return
        }

        if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                guard let srcURL = url else {
                    print("❌ Failed to load video: \(error?.localizedDescription ?? "unknown")")
                    self.onPick(nil)
                    return
                }

                // Copy to temp directory
                let filename = srcURL.lastPathComponent
                let destURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

                do {
                    if FileManager.default.fileExists(atPath: destURL.path) {
                        try FileManager.default.removeItem(at: destURL)
                    }
                    try FileManager.default.copyItem(at: srcURL, to: destURL)
                    DispatchQueue.main.async {
                        self.onPick(destURL)
                    }
                } catch {
                    print("❌ Failed to copy video: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.onPick(nil)
                    }
                }
            }
        } else {
            print("❌ Not a video")
            onPick(nil)
        }
    }
}
