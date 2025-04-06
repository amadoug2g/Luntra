//
//  AudioManager.swift
//  Luntra
//
//  Created by Amadou on 02.04.2025.
//

import Foundation
import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject {
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isPlayingState: Bool = false
    @Published var isLoadingState: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    func initialize(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.isLoadingState = true
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                DispatchQueue.main.async {
                    self.audioPlayer = player
                    self.duration = player.duration
                    self.currentTime = player.currentTime
                    self.isPlayingState = player.isPlaying
                    self.isLoadingState = false
                }
            } catch {
                self.isLoadingState = false
                DispatchQueue.main.async {
                    print("Audio initialization failed:", error.localizedDescription)
                }
            }
        }
    }
    
    func play(url: URL) {
        if audioPlayer == nil {
            initialize(url: url)
        }
        audioPlayer?.play()
        isPlayingState = audioPlayer?.isPlaying ?? false
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlayingState = audioPlayer?.isPlaying ?? false
        stopTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlayingState = false
        currentTime = 0
        stopTimer()
    }
    
    func skip5Forward() {
        if let player = audioPlayer {
            player.currentTime = min(player.duration, player.currentTime + 5)
            currentTime = player.currentTime
        }
    }
    
    func skip5Backward() {
        if let player = audioPlayer {
            player.currentTime = max(0, player.currentTime - 5)
            currentTime = player.currentTime
        }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
            self.isPlayingState = player.isPlaying
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
}
