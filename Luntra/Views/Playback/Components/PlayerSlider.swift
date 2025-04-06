//
//  PlayerSlider.swift
//  Luntra
//
//  Created by Amadou on 05.04.2025.
//

import SwiftUI
import AVFoundation

struct PlayerSlider: View {
    @ObservedObject var audioService: AudioServiceImpl
    
    var body: some View {
        VStack(spacing: 0) {
            Slider(value: Binding(
                get: { audioService.currentTime },
                set: { newValue in
                    audioService.seek(to: newValue)
                }
            ), in: 0...audioService.duration)
            HStack {
                Text(formatTime(audioService.currentTime))
                    .font(.caption)
                
                Spacer()
                
                Text(formatTime(audioService.duration))
                    .font(.caption)
            }.padding(.top, 10)
        }.padding(.horizontal, 20)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
