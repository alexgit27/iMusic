//
//  SearchResponse.swift
//  IMusic
//
//  Created by Alexandr on 27.03.2021.
//

import Foundation

struct SearchResponse: Decodable {
    var resultCount: Int
    var results: [Track]
}

struct Track: Decodable {
    var trackName: String
    var artistName: String
    let collectionName: String?
    let artworkUrl100: String?
    let previewUrl: String?
}
