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
