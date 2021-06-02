//
//  LibraryMusicViewController.swift
//  IMusic
//
//  Created by Alexandr on 01.06.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol LibraryMusicDisplayLogic: class {
  func displayData(viewModel: LibraryMusic.Model.ViewModel.ViewModelData)
}

class LibraryMusicViewController: UIViewController, LibraryMusicDisplayLogic {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    var tabBar: MainTabBarController!
//    var searchViewModel = SearchViewModel.init(cells: [])
    
    private var track: SearchViewModel.Cell!
    private var tracks: [SearchViewModel.Cell]!

    var interactor: LibraryMusicBusinessLogic?
    var router: (NSObjectProtocol & LibraryMusicRoutingLogic)?

    @IBAction func playButtonAction(_ sender: UIButton) {
        tabBar.trackDetailView.trackMovingDelegate = self
        
//        track = searchViewModel.cells[0]
        track = tracks[0]
        
        tabBarDelegate?.maximazeTrackViewController(viewModel: track)
    }
    @IBAction func refreshButtonAction(_ sender: UIButton) {
        interactor?.makeRequest(request: LibraryMusic.Model.Request.RequestType.getTracksFromUserDefaults)
        table.reloadData()
//        table.scrollToRow(at: IndexPath(row: searchViewModel.cells.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
        table.scrollToRow(at: IndexPath(row: tracks.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    
  // MARK: Object lifecycle
  
//  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    setup()
//  }
//
//  required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//    setup()
//  }
//
  // MARK: Setup
  
  private func setup() {
    let viewController        = self
    let interactor            = LibraryMusicInteractor()
    let presenter             = LibraryMusicPresenter()
    let router                = LibraryMusicRouter()
    viewController.interactor = interactor
    viewController.router     = router
    interactor.presenter      = presenter
    presenter.viewController  = viewController
    router.viewController     = viewController
  }

  // MARK: View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
    interactor?.makeRequest(request: LibraryMusic.Model.Request.RequestType.getTracksFromUserDefaults)
    
    setupTableView()
    setupButtons()
    
    let keyWindow = UIApplication.shared.connectedScenes.filter ({
        $0.activationState == .foregroundActive
    }).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
    tabBar = keyWindow?.rootViewController as? MainTabBarController
    
//    tracks = searchViewModel.cells
    
  }
  
  func displayData(viewModel: LibraryMusic.Model.ViewModel.ViewModelData) {
    switch viewModel {
    case .displayTracks(let searchViewModel):
//        self.searchViewModel = searchViewModel
        self.tracks = searchViewModel.cells
        print(tracks.count)
    }
  }
  
    private func setupButtons() {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        refreshButton.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.tintColor = #colorLiteral(red: 0.9921568627, green: 0.1764705882, blue: 0.3333333333, alpha: 1)
        playButton.backgroundColor = #colorLiteral(red: 0.9531342387, green: 0.9490900636, blue: 0.9562709928, alpha: 1)
        refreshButton.tintColor = #colorLiteral(red: 0.9921568627, green: 0.1764705882, blue: 0.3333333333, alpha: 1)
        refreshButton.backgroundColor = #colorLiteral(red: 0.9531342387, green: 0.9490900636, blue: 0.9562709928, alpha: 1)
        playButton.layer.cornerRadius = 10
        refreshButton.layer.cornerRadius = 10
    }
    
    private func refreshData() {
        interactor?.makeRequest(request: LibraryMusic.Model.Request.RequestType.getTracksFromUserDefaults)
        
    }
}

// MARK: - Configure TableView
extension LibraryMusicViewController {
    private func setupTableView() {
        table.delegate = self
        table.dataSource = self
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        let nib = UINib(nibName: "TrackCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
    }
}

 // MARK: - Table View Data Source
extension LibraryMusicViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchViewModel.cells.count
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: TrackCell.reuseId, for: indexPath) as! TrackCell
//        let cellModel = searchViewModel.cells[indexPath.row]
        let cellModel = tracks[indexPath.row]
        cell.set(viewModel: cellModel)
        return cell
    }
    
   
}

// MARK: - Table View Delegate
extension LibraryMusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tabBar.trackDetailView.trackMovingDelegate = self
        table.deselectRow(at: indexPath, animated: true)
        
//        track = searchViewModel.cells[indexPath.row]
        track = tracks[indexPath.row]
        
        tabBarDelegate?.maximazeTrackViewController(viewModel: track)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(track: indexPath.row)
            table.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func delete(track: Int) {
        tracks.remove(at: track)
        
        let defaults = UserDefaults.standard
        if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: tracks as Any, requiringSecureCoding: false) {
            defaults.setValue(saveData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
}

// MARK: - TrackMmovingDelegate
extension LibraryMusicViewController: TrackMmovingDelegate {
    func moveBackTrack() -> SearchViewModel.Cell? {
//        let index = searchViewModel.cells.firstIndex(of: track)
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex - 1 == -1 {
//            nextTrack = searchViewModel.cells[searchViewModel.cells.count - 1]
            nextTrack = tracks[tracks.count - 1]
        } else {
//            nextTrack = searchViewModel.cells[myIndex - 1]
            nextTrack = tracks[myIndex - 1]
        }
        self.track = nextTrack
        return nextTrack
    }

    func moveForwardTrack() -> SearchViewModel.Cell? {
//        let index = searchViewModel.cells.firstIndex(of: track)
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
//        if myIndex + 1 == searchViewModel.cells.count {
        if myIndex + 1 == tracks.count {
//            nextTrack = searchViewModel.cells[0]
            nextTrack = tracks[0]
        } else {
//            nextTrack = searchViewModel.cells[myIndex + 1]
            nextTrack = tracks[myIndex + 1]
        }
        self.track = nextTrack
        return nextTrack
    }
}
