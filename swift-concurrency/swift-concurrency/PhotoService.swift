//
//  PhotoService.swift
//  swift-concurrency
//
//  Created by S Sulakshana on 2026-10-10.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ImageDownSampler {
    @Sendable
    
    static func downsample(_ data: Data, to maxPixel: Int = 400) async -> Data {
        let opts = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                             kCGImageSourceThumbnailMaxPixelSize: maxPixel,
                      kCGImageSourceCreateThumbnailWithTransform: true
        ] as CFDictionary
        
        guard let src = CGImageSourceCreateWithData(data as CFData, nil),
              let thumb = CGImageSourceCreateImageAtIndex(src, 0, opts),
              let out = CFDataCreateMutable(nil, 0),
              let dest = CGImageDestinationCreateWithData(out, UTType.jpeg.identifier as CFString, 1, nil)
        else { return data }
        CGImageDestinationAddImage(dest, thumb, nil)
        CGImageDestinationFinalize(dest)
        return out as Data
    }
}

struct PhotoService {
    func loadImageData(id: String) async throws -> Data {
        let url = URL(string: "https://picsum.photos/id/\(id)/200/300")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

struct PhotoInfo: Decodable, Sendable {
    let id: String
    let author: String
}

extension PhotoService {
    func loadInfo(id: String) async throws -> PhotoInfo {
        let url = URL(string: "https://picsum.photos/id/\(id)/info")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(PhotoInfo.self, from: data)
    }
    
    func loadPhoto(id: String) async throws -> Photo {
        async let bytes = loadImageData(id: id)
        async let info = loadInfo (id: id)
        let small = await ImageDownSampler.downsample(try await bytes)
        return Photo(id: id, author: try await info.author, imageData: small)
    }
}
