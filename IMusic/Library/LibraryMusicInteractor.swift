//
//  LibraryMusicInteractor.swift
//  IMusic
//
//  Created by Alexandr on 01.06.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol LibraryMusicBusinessLogic {
  func makeRequest(request: LibraryMusic.Model.Request.RequestType)
}

class LibraryMusicInteractor: LibraryMusicBusinessLogic {

  var presenter: LibraryMusicPresentationLogic?
  var service: LibraryMusicService?
  
  func makeRequest(request: LibraryMusic.Model.Request.RequestType) {
    if service == nil {
      service = LibraryMusicService()
    }
    
    switch request {
    case .getTracksFromUserDefaults:
        let tracks = UserDefaults.standard.getTracks()
        
        presenter?.presentData(response: LibraryMusic.Model.Response.ResponseType.presentTracks(tracks: tracks))
    }
  }    
}
