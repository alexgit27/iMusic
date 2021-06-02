//
//  TrackMmovingDelegate.swift
//  IMusic
//
//  Created by Alexandr on 02.06.2021.
//

import Foundation

protocol TrackMmovingDelegate {
    func moveBackTrack() -> SearchViewModel.Cell?
    func moveForwardTrack() -> SearchViewModel.Cell?
}
