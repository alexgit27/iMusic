//
//  MainTabBarControllerDelegate.swift
//  IMusic
//
//  Created by Alexandr on 02.06.2021.
//

import Foundation

protocol MainTabBarControllerDelegate: class {
    func minimazeTrackViewController()
    func maximazeTrackViewController(viewModel: SearchViewModel.Cell?)
}
