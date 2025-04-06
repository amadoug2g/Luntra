//
//  AudioServiceImpl.swift
//  Luntra
//
//  Created by Amadou on 05.04.2025.
//

import Foundation
import CoreData

class AudioServiceImpl: AudioService, ObservableObject {
    private let libraryManager: AudioLibraryManager
    private let playerManager: AudioPlayerManager
    private let transcriptionService = TranscriptionService()
    
    @Published var isPlayingState: Bool = false
    @Published var currentTime: TimeInterval = 0
    
    init(
        libraryManager: AudioLibraryManager = AudioLibraryManager(),
        playerManager: AudioPlayerManager = AudioPlayerManager(),
    ) {
        self.libraryManager = libraryManager
        self.playerManager = playerManager

        self.playerManager.$currentTime
            .receive(on: RunLoop.main)
            .assign(to: &$currentTime)
    }
    
    var audioFiles: [AudioFile] {
        libraryManager.audioFiles
    }
    
    var duration: TimeInterval {
        playerManager.duration
    }
    
    // MARK: File Management
    func addFile(_ url: URL) {
        libraryManager.addFile(url)
    }
    
    // MARK: Playback Controls
    func initialize(url: URL) {
        playerManager.initialize(url: url)
    }
    
    func play(url: URL) {
        playerManager.play(url: url)
        isPlayingState = playerManager.isPlayingState
    }
    
    func pause() {
        playerManager.pause()
        isPlayingState = playerManager.isPlayingState
    }
    
    func stop() {
        playerManager.stop()
    }
    
    func skipForward(seconds: Int) {
        playerManager.skip5Forward()
    }
    
    func skipBackward(seconds: Int) {
        playerManager.skip5Backward()
    }
    
    func seek(to time: TimeInterval) {
        playerManager.seek(to: time)
    }
    
    func updateTranscript(for file: AudioFile, transcript: String) {
        libraryManager.updateTranscript(for: file, transcript: transcript)
    }
}

/*
extension AudioServiceImpl {
    /// Fetches the transcript for the given file from Core Data, or transcribes it if not available.
    func fetchOrTranscribe(file: AudioFile, context: NSManagedObjectContext, completion: @escaping (Result<String, Error>) -> Void) {
        let request: NSFetchRequest<AudioFileEntity> = AudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "fileURL == %@", file.url.absoluteString)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first, let transcript = entity.transcript, !transcript.isEmpty {
                // Cached transcript found, return it.
                completion(.success(transcript))
            } else {
                // No transcript available; call the transcription service.
                transcriptionService.transcribe(audioURL: file.url) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let transcribedText):
                            // Update or create the entity with the new transcript.
                            if let entity = results.first {
                                entity.transcript = transcribedText
                            } else {
                                let newEntity = AudioFileEntity(context: context)
                                newEntity.id = file.id
                                newEntity.name = file.name
                                newEntity.fileURL = file.url.absoluteString
                                newEntity.importedAt = file.importedAt
                                newEntity.transcript = transcribedText
                            }
                            do {
                                try context.save()
                                completion(.success(transcribedText))
                            } catch {
                                completion(.failure(error))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func saveTranscript(for file: AudioFile, transcript: String, context: NSManagedObjectContext) {
        let request: NSFetchRequest<AudioFileEntity> = AudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "fileURL == %@", file.url.absoluteString)

        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.transcript = transcript
            } else {
                let newEntity = AudioFileEntity(context: context)
                newEntity.id = file.id
                newEntity.name = file.name
                newEntity.fileURL = file.url.absoluteString
                newEntity.importedAt = file.importedAt
                newEntity.transcript = transcript
            }
            try context.save()
        } catch {
            print("❌ Failed to save transcript:", error.localizedDescription)
        }
    }
}
*/
