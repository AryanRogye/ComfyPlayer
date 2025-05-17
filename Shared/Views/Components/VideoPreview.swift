//
//  VideoPreview.swift
//  Stillr
//
//  Created by Aryan Rogye on 5/15/25.
//

import SwiftUI
import AVKit

struct VideoPreviewView: View {
    let player: AVPlayer

    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .frame(minHeight: 400)
                .cornerRadius(12)
                .padding()
                .onAppear {
                    player.play()
                }
        }
    }
}

#if os(macOS)
struct VideoPlayer: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .floating
        view.player = player
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if nsView.player != player {
            nsView.player = player
        }
    }
}
#elseif os(iOS)
struct VideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player != player {
            uiViewController.player = player
        }
    }
}
#endif
