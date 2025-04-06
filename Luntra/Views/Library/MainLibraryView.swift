//
//  MainLibraryView.swift
//  Luntra
//
//  Created by Amadou on 06.04.2025.
//

import Foundation
import SwiftUI

struct MainLibraryView: View {
    @State private var isPickerPresented = false
    @StateObject private var audioService = AudioServiceImpl()

    var body: some View {
        NavigationStack {
            VStack {
                if audioService.audioFiles.isEmpty {
                    ContentUnavailableView(label: {
                        Label("No Audio Files", systemImage: "music.note")
                    }, description: {
                        Text("Start adding images to your list.")
                    }, actions: {
                        Button("Import Files", action: {
                            isPickerPresented = true
                        })
                    })
                    .offset(y: -50)
                } else {
                    AudioFileListView(audioService: audioService)
                }
            }
            .navigationTitle("Luntra")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: false
            ) { result in
                if case .success(let urls) = result, let url = urls.first {
                    audioService.addFile(url)
                }
            }
        }
    }
}
