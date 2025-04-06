//
//  AudioFile.swift
//  Luntra
//
//  Created by Amadou on 06.04.2025.
//

import Foundation
import SwiftData

@Model
class AudioFile: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var url: URL
    var transcript: String?
    var importedAt: Date
    
    init(url: URL) {
        self.url = url
        self.name = url.deletingPathExtension().lastPathComponent
        self.importedAt = Date()
    }
}
