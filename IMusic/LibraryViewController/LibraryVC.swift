//
//  LibraryViewController.swift
//  IMusic
//
//  Created by Alexandr on 01.06.2021.
//

import UIKit

class LibraryVC: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    var searchViewModel = SearchViewModel.init(cells: [])
    var tracks = UserDefaults.standard.getTracks()
//    var fakeTracks = [12, 12, 12]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        

        
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
    
// MARK: Configure TableView
    private func setupTableView() {
        table.delegate = self
        table.dataSource = self
        
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "libCell")
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")

        let nib = UINib(nibName: "TrackCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
    }
}



// MARK: - TableView Delegate
extension LibraryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
}

// MARK: - TableView DataSource
extension LibraryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: TrackCell.reuseId, for: indexPath) as! TrackCell
//        let cell = table.dequeueReusableCell(withIdentifier: "libCell", for: indexPath)
        let track = tracks[indexPath.row]
        let cellViewModel = SearchViewModel.Cell(iconUrlString: track.iconUrlString, trackName: track.trackName, collectionName: track.collectionName, artistName: track.artistName, previewUrl: track.previewUrl)
    
        cell.set(viewModel: cellViewModel)
        
        return cell
    }
    
//    func deselectSelectedRow(animated: Bool) {
//        if let indexPathForSelectedRow = table.indexPathForSelectedRow {
//            table.deselectRow(at: indexPathForSelectedRow, animated: animated)
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
    }
}
