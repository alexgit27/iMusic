//
//  TrackDetailView.swift
//  IMusic
//
//  Created by Alexandr on 29.03.2021.
//

import UIKit
import SDWebImage
import AVKit

protocol TrackMmovingDelegate {
    func moveBackTrack() -> SearchViewModel.Cell?
    func moveForwardTrack() -> SearchViewModel.Cell?
}

class TrackDetailView: UIView {
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var authorTitleLAbel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var voluemSlider: UISlider!
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    @IBOutlet weak var miniTrackPlayer: UIView!
    @IBOutlet weak var miniGoForwardButton: UIButton!
    @IBOutlet weak var miniTrackImageView: UIImageView!
    @IBOutlet weak var miniTrackTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    // MARK: - awakeFromNib
    
    override  func awakeFromNib() {
        super.awakeFromNib()

        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 5
        miniPlayPauseButton.imageEdgeInsets = .init(top: 11, left: 11, bottom: 11, right: 11)
        setupGetures()
    }
    
    
    var delegate: TrackMmovingDelegate?
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    // MARK: - Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        trackTitleLabel.text = viewModel.trackName
        authorTitleLAbel.text = viewModel.artistName
        
        miniTrackTitleLabel.text = viewModel.trackName
        
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let url = URL(string: string600 ?? "") else {return}
        trackImageView.sd_setImage(with: url, completed: nil)
        miniTrackImageView.sd_setImage(with: url, completed: nil)
        
        playTrack(previewUrl: viewModel.previewUrl)
        monitorStartTime()
        obeservePlayerCurrentTime()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        
    }
    
    private func setupGetures() {
        miniTrackPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlerTapMaximized)))
        
        miniTrackPlayer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDissmsalPan)))
    }
    
    private func playTrack(previewUrl: String?) {
        guard let url = URL(string: previewUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func monitorStartTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    func obeservePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationTimeLabel.text = "-\(currentDurationText)"
            self?.updateCurrentTimeSlider()
            
            if self?.player.currentTime() == self?.player.currentItem?.duration {
                let cellViewModel = self?.delegate?.moveForwardTrack()
                guard let viewModel = cellViewModel else { return }
                self?.set(viewModel: viewModel)
            }
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    // MARK: - Maximizing and minimizing gestures
    
    @objc private func handlerTapMaximized() {
     self.tabBarDelegate?.maximazeTrackViewController(viewModel: nil)
     }
     
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            break
        case .changed:
            handlePanChaneged(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        @unknown default:
           break
        }
     }
     
    
    private func handlePanChaneged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniTrackPlayer.alpha = newAlpha < 0 ? 0:  newAlpha
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.tabBarDelegate?.maximazeTrackViewController(viewModel: nil)
            } else {
                self.miniTrackPlayer.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        }, completion: nil)
    }
    
    @objc private func handleDissmsalPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self.superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.maximizedStackView.transform = .identity
                if translation.y > 50 {
                    self.tabBarDelegate?.minimazeTrackViewController()
                }
            }, completion: nil)
        @unknown default:
            break
        }
    }
    // MARK: - Animation
    private func enlargeTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.trackImageView.transform = .identity
        }, completion: nil)
    }
    
    private func reduceTarckImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            let scale: CGFloat = 0.8
            self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
    
    
    // MARK: - IBACTIONs
    
    @IBAction func dragDownButtonTapped(_ sender: Any) {
        
        self.tabBarDelegate?.minimazeTrackViewController()
//        self.removeFromSuperview()
    }
    
    @IBAction func handleCurrentTimeSlider(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = voluemSlider.value
    }
    @IBAction func previousTrack(_ sender: Any) {
        let cellViewModel = delegate?.moveBackTrack()
        guard let viewModel = cellViewModel else { return }
        self.set(viewModel: viewModel)
    }
    @IBAction func nextTrack(_ sender: Any) {
        let cellViewModel = delegate?.moveForwardTrack()
        guard let viewModel = cellViewModel else { return }
        self.set(viewModel: viewModel)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            reduceTarckImageView()
        }
    }
    
}
