//
//  SearchMusicViewController.swift
//  IMusic
//
//  Created by Alexandr on 27.03.2021.
//

import UIKit
import Alamofire

struct TrackModel {
    let artist: String
    let song: String
}

class SearchMusicViewController: UITableViewController {
    var tracks: [Track] = []
    private var timer: Timer?
    let networkService = NetworkService()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let track = tracks[indexPath.row]
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "\(track.artistName)\n\(track.trackName)"
        cell.imageView?.image = #imageLiteral(resourceName: "Image")
        return cell
    }
}

extension SearchMusicViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.networkService.fetchTracks(searchText: searchText) {[weak self] (searchResult) in
                self?.tracks = searchResult?.results ?? []
                self?.tableView.reloadData()
            }
           
        }
    }
}
