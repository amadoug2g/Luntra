//
//  EmptyStateView.swift
//  LuntraMVP
//
//  Created by Amadou on 05.04.2025.
//

import SwiftUI
import AVFoundation

struct EmptyLibraryView: View {
    var body: some View {
        Spacer()        
        Text("Import an audio file to get started.")
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding()
        Spacer()
    }
}
