//
//  LibraryMusicModels.swift
//  IMusic
//
//  Created by Alexandr on 01.06.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

enum LibraryMusic {
   
  enum Model {
    struct Request {
      enum RequestType {
        case getTracksFromUserDefaults
      }
    }
    struct Response {
      enum ResponseType {
        case presentTracks(tracks: [SearchViewModel.Cell]?)
      }
    }
    struct ViewModel {
      enum ViewModelData {
        case displayTracks(searchViewModel: SearchViewModel)
      }
    }
  }
  
}
