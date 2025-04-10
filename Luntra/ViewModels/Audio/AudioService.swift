//
//  AudioService.swift
//  Luntra
//
//  Created by Amadou on 05.04.2025.
//

import Foundation

protocol AudioService {
    // MARK: File Management
    func addFile(_ url: URL)
    func updateTranscript(for file: AudioFile, transcript: String)
    
    // MARK: Playback Controls
    func initialize(url: URL)
    func play(url: URL)
    func pause()
    func stop()
    func skipForward(seconds: Int)
    func skipBackward(seconds: Int)
    func seek(to time: TimeInterval)
}
