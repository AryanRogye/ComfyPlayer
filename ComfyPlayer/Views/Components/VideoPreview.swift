//
//  VideoPreview.swift
//  Stillr
//
//  Created by Aryan Rogye on 5/15/25.
//

import SwiftUI
import AVKit

struct VideoPreviewView: View {
    let videoURL: URL

    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .frame(minHeight: 400)
            .cornerRadius(12)
            .padding()
    }
}

struct VideoPlayer: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .floating
        view.player = player
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        nsView.player = player
    }
}
