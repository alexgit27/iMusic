//
//  TrackCell.swift
//  IMusic
//
//  Created by Alexandr on 28.03.2021.
//

import UIKit
import SDWebImage

protocol TrackCellViewModel {
    var iconUrlString: String? { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
}

class TrackCell: UITableViewCell {
    static let reuseId = "TrackCell"
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var addTrackButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        trackImageView.image = nil
    }
    
//    func set(viewModel: TrackCellViewModel) {
//        trackNameLabel.text = viewModel.trackName
//        artistNameLabel.text = viewModel.artistName
//        collectionNameLabel.text = viewModel.collectionName
//
//        guard let url = URL(string: viewModel.iconUrlString ?? "") else { return }
//        trackImageView.sd_setImage(with: url, completed: nil)
//    }
    
    var cell: SearchViewModel.Cell?
    func set(viewModel: SearchViewModel.Cell) {
        self.cell = viewModel
        
        let savedTracks = UserDefaults.standard.getTracks()
        let hasFavourite = savedTracks.firstIndex {
            $0.trackName == self.cell?.trackName && $0.artistName == self.cell?.artistName
        } != nil
        
        if hasFavourite {
            addTrackButton.isHidden = true
        } else {
            addTrackButton.isHidden = false
        }
        
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        collectionNameLabel.text = viewModel.collectionName
        
        guard let url = URL(string: viewModel.iconUrlString ?? "") else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    @IBAction func addTrackAcion(_ sender: UIButton) {
        addTrackButton.isHidden = true
        
        let defaults = UserDefaults.standard
        var listTracks: [SearchViewModel.Cell] = defaults.getTracks()
        
        
        
        guard let cell = cell else { return }
        
        listTracks.append(cell)
        
        if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: listTracks, requiringSecureCoding: false) {
            defaults.setValue(saveData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
}
