//
//  UserDefaults.swift
//  IMusic
//
//  Created by Alexandr on 31.03.2021.
//

import Foundation

extension UserDefaults {
    static let favouriteTrackKey = "favouriteTrackKey"
    
    func getTracks() -> [SearchViewModel.Cell] {
        let defaults = UserDefaults.standard
        
        guard let savedTracks = defaults.object(forKey: UserDefaults.favouriteTrackKey) as? Data else { return [] }
        guard let decodedTracks = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedTracks) as? [SearchViewModel.Cell] else { return [] }
        return decodedTracks
    }
}
