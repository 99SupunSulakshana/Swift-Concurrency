//
//  SnapGridModel.swift
//  swift-concurrency
//
//  Created by S Sulakshana on 2026-10-11.
//

import Observation

@Observable
final class SnapGridModel {
    private(set) var photos: [Photo] = []
    private(set) var isLoading = false
    private let service = PhotoService()
    
    let ids = ["0", "2", "4", "5", "10", "20", "100", "200", "239", "40", "3"]
    
    func loadFirst() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let  raw = try await service.loadImageData(id: "239")
            let data = await ImageDownSampler.downsample(raw)
            photos = [Photo(id: "239", author: "Sample", imageData: data)]
        } catch {
            print("load failed", error )
        }
    }
    
    func loadGrid() async {
        isLoading = true
        defer { isLoading = false }
        photos = []
        do {
            try await withThrowingTaskGroup(of: Photo.self){ group in
                for id in ids {
                    group.addTask {
                        try Task.checkCancellation()
                        return try await self.service.loadPhoto(id: id)
                    }
                }
                for try await photo in group {
                    photos.append(photo)
                }
            }
        }  catch {
            print("Grid load failed", error)
        }
    }
}
