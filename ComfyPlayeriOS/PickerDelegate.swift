//
//  PickerDelegate.swift
//  ComfyPlayer
//
//  Created by Aryan Rogye on 5/17/25.
//

import UIKit
import PhotosUI

final class PickerDelegate: NSObject, PHPickerViewControllerDelegate {
    var onPick: (URL?) -> Void

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
                    self.onPick(nil)
                    return
                }

                let destURL = FileManager.default.temporaryDirectory.appendingPathComponent(srcURL.lastPathComponent)

                do {
                    if FileManager.default.fileExists(atPath: destURL.path) {
                        try FileManager.default.removeItem(at: destURL)
                    }
                    try FileManager.default.copyItem(at: srcURL, to: destURL)
                    DispatchQueue.main.async {
                        self.onPick(destURL)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.onPick(nil)
                    }
                }
            }
        } else {
            onPick(nil)
        }
    }
}
