//
//  AudioLibrary.swift
//  Luntra
//
//  Created by Amadou on 04.04.2025.
//

import Foundation
import AVFoundation

class AudioLibraryManager: ObservableObject {
    @Published var audioFiles: [AudioFile] = []
    @Published var selectedFile: AudioFile?
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        loadFilesFromDisk()
    }
    
    private func loadFilesFromDisk() {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let contents = try FileManager.default.contentsOfDirectory(at: documentsDir, includingPropertiesForKeys: nil)
            let audioExtensions = ["mp3", "m4a", "wav", "mp4", "mpga", "mpeg"]

            audioFiles = contents
                .filter { audioExtensions.contains($0.pathExtension.lowercased()) }
                .map { AudioFile(url: $0) }
        } catch {
            print("Failed to load audio files from disk:", error.localizedDescription)
        }
    }
    
    func addFile(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            print("❌ Could not access security scoped resource")
            return
        }

        defer { url.stopAccessingSecurityScopedResource() }

        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDir.appendingPathComponent(url.lastPathComponent)

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: url, to: destinationURL)

            let audioFile = AudioFile(url: destinationURL)
            audioFiles.append(audioFile)
            selectedFile = audioFile

        } catch {
            print("File copy failed:", error.localizedDescription)
        }
    }
    
    func updateTranscript(for file: AudioFile, transcript: String) {
        if let index = audioFiles.firstIndex(where: { $0.id == file.id }) {
            var updatedFile = audioFiles[index]
            updatedFile.transcript = transcript
            audioFiles[index] = updatedFile
        }
    }
    
    func rename(file: AudioFile, to newName: String) {
        let ext = file.url.pathExtension
        let newFileName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newFileName.isEmpty else { return }

        let newURL = file.url.deletingLastPathComponent().appendingPathComponent("\(newFileName).\(ext)")

        do {
            try FileManager.default.moveItem(at: file.url, to: newURL)
            loadFilesFromDisk()
        } catch {
            print("Rename failed:", error.localizedDescription)
        }
    }
    
    func deleteFile(at offsets: IndexSet) {
        for index in offsets {
            let file = audioFiles[index]
            do {
                try FileManager.default.removeItem(at: file.url)
            } catch {
                print("Failed to delete file:", error.localizedDescription)
            }
        }
        audioFiles.remove(atOffsets: offsets)
    }
    
    func deleteFile(_ file: AudioFile) {
        guard let index = audioFiles.firstIndex(where: { $0.id == file.id }) else { return }

        do {
            try FileManager.default.removeItem(at: file.url)
            audioFiles.remove(at: index)
        } catch {
            print("Failed to delete file:", error.localizedDescription)
        }
    }
}
