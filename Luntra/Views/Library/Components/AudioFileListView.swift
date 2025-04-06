//
//  AudioFileListView.swift
//  LuntraMVP
//
//  Created by Amadou on 05.04.2025.
//

import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct AudioFileListView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var audioService: AudioServiceImpl

    var body: some View {
        List {
            ForEach(audioService.audioFiles) { file in
                NavigationLink(destination: PlaybackView(audioService: audioService, file: file)
                    .environment(\.managedObjectContext, moc)
                ) {
                    Text(file.name)
                }
            }
        }
    }
}
