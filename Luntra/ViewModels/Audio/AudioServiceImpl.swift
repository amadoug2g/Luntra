//
//  AudioServiceImpl.swift
//  LuntraMVP
//
//  Created by Amadou on 05.04.2025.
//

import Foundation
import CoreData

class AudioServiceImpl: AudioService, ObservableObject {
    private let libraryManager: AudioLibraryManager
    private let playerManager: AudioPlayerManager
    private let transcriptionService = TranscriptionService()
    //private let context: NSManagedObjectContext
    
    @Published var isPlayingState: Bool = false
    @Published var currentTime: TimeInterval = 0
    
    init(
        libraryManager: AudioLibraryManager = AudioLibraryManager(),
        playerManager: AudioPlayerManager = AudioPlayerManager(),
        //context: NSManagedObjectContext
    ) {
        self.libraryManager = libraryManager
        self.playerManager = playerManager
        //self.context = context

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

extension AudioServiceImpl {
    func generateDummyTranscript(for file: AudioFile, context: NSManagedObjectContext, completion: @escaping (Result<String, Error>) -> Void) {
        let dummyTranscript = "This is a dummy transcript for debugging."
        print("DEBUG: Generating dummy transcript for file: \(file.name)")
        print("DEBUG: File URL used as key: \(file.url.absoluteString)")
        
        let request: NSFetchRequest<AudioFileEntity> = AudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "fileURL == %@", file.url.absoluteString)
        print("DEBUG: Predicate: \(request.predicate?.predicateFormat ?? "nil")")
        
        do {
            let results = try context.fetch(request)
            print("DEBUG: Found \(results.count) matching entities")
            if let entity = results.first {
                print("DEBUG: Updating existing entity transcript")
                entity.transcript = dummyTranscript
            } else {
                print("DEBUG: No entity found, creating new one")
                let newEntity = AudioFileEntity(context: context)
                newEntity.id = file.id
                newEntity.name = file.name
                newEntity.fileURL = file.url.absoluteString
                newEntity.importedAt = file.importedAt
                newEntity.transcript = dummyTranscript
            }
            try context.save()
            print("DEBUG: Context saved successfully")
            completion(.success(dummyTranscript))
        } catch {
            print("DEBUG: Error saving dummy transcript: \(error)")
            completion(.failure(error))
        }
    }
    
    /// Debug version: Fetches the transcript from Core Data or simulates transcription without making a real API call.
    func debugFetchOrTranscribe(file: AudioFile,
                                context: NSManagedObjectContext,
                                simulate: Bool = true,
                                completion: @escaping (Result<String, Error>) -> Void) {
        print("DEBUG: Starting debugFetchOrTranscribe for file: \(file.name)")
        print("DEBUG: File URL: \(file.url.absoluteString)")
        
        let request: NSFetchRequest<AudioFileEntity> = AudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "fileURL == %@", file.url.absoluteString)
        print("DEBUG: Using predicate: \(request.predicate?.predicateFormat ?? "nil")")
        
        do {
            let results = try context.fetch(request)
            print("DEBUG: Fetch returned \(results.count) result(s)")
            if let entity = results.first {
                print("DEBUG: Found entity with transcript: \(entity.transcript ?? "nil")")
            } else {
                print("DEBUG: No entity found for file")
            }
            
            if let entity = results.first, let transcript = entity.transcript, !transcript.isEmpty {
                print("DEBUG: Cached transcript found: \(transcript)")
                completion(.success(transcript))
            } else {
                // If simulation mode is on, don't call the transcription service
                if simulate {
                    let simulatedTranscript = "Simulated transcript for debugging purposes."
                    print("DEBUG: Simulating transcription, returning: \(simulatedTranscript)")
                    // Optionally, update Core Data here if desired:
                    if let entity = results.first {
                        entity.transcript = simulatedTranscript
                    } else {
                        let newEntity = AudioFileEntity(context: context)
                        newEntity.id = file.id
                        newEntity.name = file.name
                        newEntity.fileURL = file.url.absoluteString
                        newEntity.importedAt = file.importedAt
                        newEntity.transcript = simulatedTranscript
                    }
                    try context.save()
                    completion(.success(simulatedTranscript))
                } else {
                    // No cached transcript; perform real transcription.
                    transcriptionService.transcribe(audioURL: file.url) { result in
                        DispatchQueue.main.async {
                            print("DEBUG: Transcription service returned result: \(result)")
                            switch result {
                            case .success(let transcribedText):
                                print("DEBUG: Transcribed text: \(transcribedText)")
                                // Re-fetch to update the latest entity.
                                do {
                                    let freshResults = try context.fetch(request)
                                    print("DEBUG: Fresh fetch returned \(freshResults.count) result(s)")
                                    if let entity = freshResults.first {
                                        print("DEBUG: Updating existing entity with new transcript")
                                        entity.transcript = transcribedText
                                    } else {
                                        print("DEBUG: Creating new entity for file with transcript")
                                        let newEntity = AudioFileEntity(context: context)
                                        newEntity.id = file.id
                                        newEntity.name = file.name
                                        newEntity.fileURL = file.url.absoluteString
                                        newEntity.importedAt = file.importedAt
                                        newEntity.transcript = transcribedText
                                    }
                                    try context.save()
                                    print("DEBUG: Context saved successfully")
                                    completion(.success(transcribedText))
                                } catch {
                                    print("DEBUG: Error during fresh fetch or context save: \(error)")
                                    completion(.failure(error))
                                }
                            case .failure(let error):
                                print("DEBUG: Transcription service error: \(error)")
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        } catch {
            print("DEBUG: Initial fetch error: \(error)")
            completion(.failure(error))
        }
    }
    
    /// Fetches the transcript for the given file from Core Data, or transcribes it if not available.
    func fetchOrTranscribe(file: AudioFile, context: NSManagedObjectContext, completion: @escaping (Result<String, Error>) -> Void) {
        // Create a fetch request for AudioFileEntity matching the file's unique id.
        let request: NSFetchRequest<AudioFileEntity> = AudioFileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "fileURL == %@", file.url.absoluteString)
        
        do {
            let results = try context.fetch(request)
            print("Fetch results count: \(results.count)")
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
