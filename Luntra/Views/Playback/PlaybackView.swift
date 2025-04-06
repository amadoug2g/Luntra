//
//  PlaybackView.swift
//  Luntra
//
//  Created by Amadou on 04.04.2025.
//

import SwiftUI
import AVFoundation

struct PlaybackView: View {
    @ObservedObject var audioService: AudioServiceImpl
    var file: AudioFile
    
    @State private var selectedFile: AudioFile?
    @State private var newName: String = ""
    @State private var isRenaming = false
    
    @State private var tabSelection = 0

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(file.name)
                    .font(.headline)
            }.padding()
            
            Picker("Tabs", selection: $tabSelection) {
                Text("Cover").tag(0)
                Text("Transcript").tag(1)
            }
            .pickerStyle(.segmented)
            
            Spacer()
            
            Group {
                if tabSelection == 0 {
                    AlbumTabView()
                } else {
                    Text("Transcription TBI")
                }
            }
            .frame(height: 500)
            
            ZStack {
                Color.white.opacity(0.15)
                VStack {
                    PlayerSlider(audioService: audioService)
                        .padding(.top, 80)
                    
                    PlayerControls(audioService: audioService, file: file)
                        .padding(.bottom, 100)
                }.frame(height: 175)
            }
        }
        .navigationTitle("Playback")
        .onAppear() {
            audioService.initialize(url: file.url)

        }
        .onDisappear {
            audioService.stop()
        }
    }
}
