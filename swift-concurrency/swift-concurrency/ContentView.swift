//
//  ContentView.swift
//  swift-concurrency
//
//  Created by S Sulakshana on 2026-10-03.
//

import SwiftUI

struct ContentView: View {
    
    @State private var model = SnapGridModel()
    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 4)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4){
                ForEach(model.photos) {
                    photo in
                    if let ui = UIImage(data:
                                            photo.imageData){
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 110)
                            .clipped()
                    }
                }
            }
            .padding(4)
        }
        .task {
            await model.loadGrid()
        }
        .overlay { if model.isLoading && model.photos.isEmpty {
            ProgressView()
        }}
    }
}

#Preview {
    ContentView()
}
