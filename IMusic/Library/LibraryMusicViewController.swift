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
    private var tabBar: MainTabBarController!
    
    private var track: SearchViewModel.Cell!
    private var tracks: [SearchViewModel.Cell]!

    var interactor: LibraryMusicBusinessLogic?
    var router: (NSObjectProtocol & LibraryMusicRoutingLogic)?

    
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
    setupTableView()
    setupButtons()
    
    interactor?.makeRequest(request: LibraryMusic.Model.Request.RequestType.getTracksFromUserDefaults)
    
    let keyWindow = UIApplication.shared.connectedScenes.filter ({
        $0.activationState == .foregroundActive
    }).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
    tabBar = keyWindow?.rootViewController as? MainTabBarController
  }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        tabBar.trackDetailView.trackMovingDelegate = self
//    }
  
  func displayData(viewModel: LibraryMusic.Model.ViewModel.ViewModelData) {
    switch viewModel {
    case .displayTracks(let searchViewModel):
        self.tracks = searchViewModel.cells
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
    
    // MARK: IBAction's
    @IBAction func playButtonAction(_ sender: UIButton) {
        tabBar.trackDetailView.trackMovingDelegate = self
        track = tracks[0]
        tabBarDelegate?.maximazeTrackViewController(viewModel: track)
    }
    
    @IBAction func refreshButtonAction(_ sender: UIButton) {
        interactor?.makeRequest(request: LibraryMusic.Model.Request.RequestType.getTracksFromUserDefaults)
        table.reloadData()
        table.scrollToRow(at: IndexPath(row: tracks.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
}

// MARK: -Setup TableView
extension LibraryMusicViewController {
    private func setupTableView() {
        table.delegate = self
        table.dataSource = self
        let nib = UINib(nibName: "TrackCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
    }
}

 // MARK: -Table View Data Source
extension LibraryMusicViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: TrackCell.reuseId, for: indexPath) as! TrackCell
        let cellModel = tracks[indexPath.row]
        cell.set(viewModel: cellModel)
        return cell
    }
}

// MARK: -Table View Delegate
extension LibraryMusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tabBar.trackDetailView.trackMovingDelegate = self
        table.deselectRow(at: indexPath, animated: true)
        track = tracks[indexPath.row]
        
        tabBarDelegate?.maximazeTrackViewController(viewModel: track)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(index: indexPath.row)
            table.reloadData()
        }
    }
    
    private func delete(index: Int) {
        tracks.remove(at: index)
        
        let defaults = UserDefaults.standard
        if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: tracks as Any, requiringSecureCoding: false) {
            defaults.setValue(saveData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
}

// MARK: -TrackMmovingDelegate
extension LibraryMusicViewController: TrackMmovingDelegate {
    func moveBackTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        
        if myIndex - 1 == -1 {
            nextTrack = tracks[tracks.count - 1]
        } else {
            nextTrack = tracks[myIndex - 1]
        }
        
        self.track = nextTrack
        return nextTrack
    }

    func moveForwardTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        
        if myIndex + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[myIndex + 1]
        }
        
        self.track = nextTrack
        return nextTrack
    }
}
