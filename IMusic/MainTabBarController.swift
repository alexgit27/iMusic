//
//  MainTabBarController.swift
//  IMusic
//
//  Created by Alexandr on 27.03.2021.
//

import UIKit
import SwiftUI

protocol MainTabBarControllerDelegate: class {
    func minimazeTrackViewController()
    func maximazeTrackViewController(viewModel: SearchViewModel.Cell?)
}

class MainTabBarController: UITabBarController {
    let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
    let libraryMusicVC: LibraryMusicViewController = LibraryMusicViewController.loadFromStoryboard()
    
    var minimizedTopAnchorConstraints: NSLayoutConstraint!
    var maximizedTopAnchorConstraints: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchVC.tabBarDelegate = self
        libraryMusicVC.tabBarDelegate = self
        
        setupTrackDetailView()
        
        view.backgroundColor = .white
        tabBar.tintColor = .systemPink

        var library = Library()
        library.tabBarDelegate = self
        let hostingVC = UIHostingController(rootView: library)
        hostingVC.tabBarItem.image = #imageLiteral(resourceName: "library")
        hostingVC.tabBarItem.title = "Library"

        viewControllers = [
            generateViewController(rootViewController: searchVC, image: UIImage(named: "search")!, title: "Search"),
           generateViewController(rootViewController: libraryMusicVC, image: UIImage(named: "library")!, title: "Library")
        ]
    }

    private func generateViewController(rootViewController: UIViewController, image: UIImage, title: String) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }

    
    private func setupTrackDetailView() {

        trackDetailView.backgroundColor = .white
        trackDetailView.tabBarDelegate = self
        trackDetailView.trackMovingDelegate = searchVC
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraints = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraints = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        
        maximizedTopAnchorConstraints.isActive = true
        bottomAnchorConstraint.isActive = true
        
//        trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        view.addSubview(trackDetailView)
    }
}

extension MainTabBarController: MainTabBarControllerDelegate {
    func maximazeTrackViewController(viewModel: SearchViewModel.Cell?) {
        
        minimizedTopAnchorConstraints.isActive = false
        maximizedTopAnchorConstraints.isActive = true
        maximizedTopAnchorConstraints.constant = 0
        bottomAnchorConstraint.constant = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
                        self.tabBar.alpha = 0
                        self.trackDetailView.miniTrackPlayer.alpha = 0
                        self.trackDetailView.maximizedStackView.alpha = 1
                       },
                       completion: nil)
        
        guard let viewModel = viewModel else { return }
        trackDetailView.set(viewModel: viewModel)
    }
    
    func minimazeTrackViewController() {
        maximizedTopAnchorConstraints.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraints.isActive = true

        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
                        self.tabBar.alpha = 1
                        self.trackDetailView.miniTrackPlayer.alpha = 1
                        self.trackDetailView.maximizedStackView.alpha = 0
                       },
                       completion: nil)
    }
}
