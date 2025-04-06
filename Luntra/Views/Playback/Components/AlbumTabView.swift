//
//  AlbumTabView.swift
//  Luntra
//
//  Created by Amadou on 05.04.2025.
//

import SwiftUI
import AVFoundation

struct AlbumTabView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.3))
                .frame(width: 350, height: 350)
                .cornerRadius(10)
         
            Image(systemName: "music.note")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .foregroundColor(.accentColor)
                .padding()
        }
    }
}
