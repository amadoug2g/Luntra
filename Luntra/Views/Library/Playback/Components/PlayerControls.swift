//
//  PlayerControls.swift
//  LuntraMVP
//
//  Created by Amadou on 05.04.2025.
//

import SwiftUI
import AVFoundation

struct PlayerControls: View {
    @ObservedObject var audioService: AudioServiceImpl
    let file: AudioFile
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: {
                audioService.skipBackward(seconds: 5)
            }) {
                Image(systemName: "5.arrow.trianglehead.counterclockwise")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            
            if (audioService.isPlayingState) {
                Button(action: {
                    audioService.pause()
                }) {
                    Image(systemName: "pause.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            } else {
                Button(action: {
                    audioService.play(url: file.url)
                }) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            }
            
            Button(action: {
                audioService.skipForward(seconds: 5)
            }) {
                Image(systemName: "5.arrow.trianglehead.clockwise")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
        }
    }
}
