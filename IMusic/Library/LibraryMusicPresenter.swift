//
//  LibraryMusicPresenter.swift
//  IMusic
//
//  Created by Alexandr on 01.06.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol LibraryMusicPresentationLogic {
  func presentData(response: LibraryMusic.Model.Response.ResponseType)
}

class LibraryMusicPresenter: LibraryMusicPresentationLogic {
  weak var viewController: LibraryMusicDisplayLogic?
  
  func presentData(response: LibraryMusic.Model.Response.ResponseType) {
    switch response {
    case .presentTracks(let tracks):
        let model = convertInSearchViewModel(tracks: tracks ?? [])
        viewController?.displayData(viewModel: LibraryMusic.Model.ViewModel.ViewModelData.displayTracks(searchViewModel: model))
    }
    
  }
    
    func convertInSearchViewModel(tracks: [SearchViewModel.Cell]) -> SearchViewModel {
        var cells: [SearchViewModel.Cell] = []
        for cell  in tracks {
            cells.append(cell)
        }
        return SearchViewModel.init(cells: cells)
    }
    
}
