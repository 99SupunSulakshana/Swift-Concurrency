//
//  Photo.swift
//  swift-concurrency
//
//  Created by S Sulakshana on 2026-10-04.
//

import Foundation
struct Photo: Identifiable, Sendable {
    let id: String
    let author: String
    let imageData: Data
}
