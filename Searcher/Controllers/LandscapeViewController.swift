//
//  LandscapeViewController.swift
//  Searcher
//
//  Created by Boris Bolshakov on 24.11.21.
//

import UIKit

final class LandscapeViewController: UIViewController {
    
    var searchResults = [SearchResult]()
    
    // MARK: - UI
    
    private let activityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .yellow
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(activityView)
        return scrollView
    }()
    
    private var nameLabel: UILabel = {
        let nl = UILabel()
        nl.translatesAutoresizingMaskIntoConstraints = false
        nl.numberOfLines = 0
        nl.textAlignment = .left
        nl.text = "Landscape"
        nl.font = .systemFont(ofSize: 15, weight: .regular)
        return nl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    
}

extension LandscapeViewController {
    
    func setup() {
        
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            
            nameLabel.centerXAnchor.constraint(equalTo:  view.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
}
