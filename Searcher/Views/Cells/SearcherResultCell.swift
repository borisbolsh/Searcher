//
//  SearcherResultCell.swift
//  Searcher
//
//  Created by Boris Bolshakov on 20.11.21.
//

import UIKit

final class SearcherResultCell: UITableViewCell {

    static let identifier = "SearcherResultCell"
    
    private let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.image = UIImage(systemName: "square")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()

    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }

    func configureLayout() {
        contentView.addSubview(artistImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        artistImageView.frame = CGRect(
            x: 16,
            y: 10,
            width: 60,
            height: 60
        )
        nameLabel.frame = CGRect(
            x: 84,
            y: 16,
            width: 275,
            height: 22
        )
        artistNameLabel.frame = CGRect(
            x: 84,
            y: 44,
            width: 275,
            height: 18
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        artistImageView.image = nil
        nameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    func configure(with model: SearchResult) {
//        artistImageView.image = nil
        nameLabel.text = model.name
        artistNameLabel.text = model.artistName
    }
    
}
