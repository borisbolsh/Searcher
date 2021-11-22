//
//  LoadingCell.swift
//  Searcher
//
//  Created by Boris Bolshakov on 21.11.21.
//

import UIKit

class LoadingCell: UITableViewCell {

    static let identifier = "LoadingCell"
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Loading…"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIV = UIActivityIndicatorView(style: .medium)
        activityIV.translatesAutoresizingMaskIntoConstraints = false
        activityIV.startAnimating()
        activityIV.tag = 99
        
        return activityIV
    }()
    
    private lazy var loadingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [loadingLabel, activityIndicatorView])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
        
    }

    func configureLayout() {
        contentView.addSubview(loadingStackView)
        
        loadingStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingStackView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
