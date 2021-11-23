//
//  DetailViewController.swift
//  Searcher
//
//  Created by Boris Bolshakov on 23.11.21.
//

import UIKit

final class DetailViewController: UIViewController {
    
    var searchResult: (()->())?
    
    // MARK: - UI
    private var newView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        
        return view
    }()
    
    private var closeBtn: UIButton = {
        let closeBtn = UIButton()
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        closeBtn.setImage(UIImage(systemName: "xmark.circle.fill") , for: .normal)
        closeBtn.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
    
        return closeBtn
    }()
    
    private lazy var modalInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ nameLabel, artistNameLabel, kindLabel, genreLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var artworkImageView: UIImageView = {
        let itemImage = UIImageView()
        itemImage.translatesAutoresizingMaskIntoConstraints = false
        itemImage.layer.masksToBounds = true
        itemImage.clipsToBounds = true
        itemImage.layer.cornerRadius = 4
        itemImage.image = UIImage(systemName: "square")
        itemImage.contentMode = .scaleAspectFit
        
        return itemImage
    }()
    private var nameLabel: UILabel = {
        let nl = UILabel()
        nl.translatesAutoresizingMaskIntoConstraints = false
        nl.numberOfLines = 0
        nl.textAlignment = .left
        nl.text = "Name"
        nl.font = .systemFont(ofSize: 18, weight: .bold)
        return nl
    }()
    private var artistNameLabel: UILabel = {
        let art = UILabel()
        art.translatesAutoresizingMaskIntoConstraints = false
        art.numberOfLines = 0
        art.textAlignment = .left
        art.text = "Artist Name"
        art.font = .systemFont(ofSize: 15, weight: .regular)
        return art
    }()
    private var kindLabel: UILabel = {
        let kind = UILabel()
        kind.translatesAutoresizingMaskIntoConstraints = false
        kind.numberOfLines = 0
        kind.textAlignment = .left
        kind.text = "Kind value"
        kind.font = .systemFont(ofSize: 15, weight: .regular)
        return kind
    }()
    private var genreLabel: UILabel = {
        let genre = UILabel()
        genre.translatesAutoresizingMaskIntoConstraints = false
        genre.numberOfLines = 0
        genre.textAlignment = .left
        genre.text = "Genre value"
        genre.font = .systemFont(ofSize: 15, weight: .regular)
        return genre
    }()
    private var priceButton: UIButton = {
        let price = UIButton()
        price.translatesAutoresizingMaskIntoConstraints = false
        price.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        price.setTitle("9.99$", for: .normal)
        price.setTitleColor(.systemBlue, for: .normal)
  
        price.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        price.backgroundColor = .clear
        price.layer.cornerRadius = 5
        price.layer.borderWidth = 1
        price.layer.borderColor = UIColor.systemBlue.cgColor
        return price
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "ArtistName")
        setup()
    }
    
  
    // MARK: - Actions
    @objc func closeWindow() {
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController {
    
    func setup() {
        
        view.addSubview(newView)
        view.addSubview(closeBtn)
        view.addSubview(artworkImageView)
        view.addSubview(modalInfoStackView)
        view.addSubview(priceButton)
        
        NSLayoutConstraint.activate([
            
            newView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            newView.heightAnchor.constraint(equalToConstant: 280),
            newView.widthAnchor.constraint(equalToConstant: 280),
            
            closeBtn.topAnchor.constraint(equalTo: newView.topAnchor),
            closeBtn.trailingAnchor.constraint(equalTo: newView.trailingAnchor),
            closeBtn.heightAnchor.constraint(equalToConstant: 40),
            
            
            artworkImageView.topAnchor.constraint(equalTo: closeBtn.bottomAnchor),
            artworkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artworkImageView.heightAnchor.constraint(equalToConstant: 100),
            artworkImageView.widthAnchor.constraint(equalToConstant: 100),
            
            modalInfoStackView.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor),
            modalInfoStackView.leadingAnchor.constraint(equalTo: newView.leadingAnchor,constant: 16),
            modalInfoStackView.trailingAnchor.constraint(equalTo: newView.trailingAnchor, constant: -10),
            
            priceButton.topAnchor.constraint(equalTo: modalInfoStackView.bottomAnchor),
            priceButton.trailingAnchor.constraint(equalTo: newView.trailingAnchor, constant: -16),
        ])
    }
}
