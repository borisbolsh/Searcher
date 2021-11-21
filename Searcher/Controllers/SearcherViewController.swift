//
//  SearcherViewController.swift
//  Searcher
//
//  Created by Boris Bolshakov on 20.11.21.
//

import UIKit

final class SearcherViewController: UIViewController {

    private var searchResults = [SearchResult]()
    private var hasSearched = false
    
    struct TableView {
      struct CellIdentifiers {
        static let searcherResultCell = "SearcherResultCell"
        static let nothingFoundCell = "NothingFoundCell"
      }
    }
    
    // MARK: - UI
    
    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        
        return sb
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(SearcherResultCell.self, forCellReuseIdentifier: SearcherResultCell.identifier)
        tv.register(NothingFoundCell.self, forCellReuseIdentifier: NothingFoundCell.identifier)
        
        return tv
    }()
   
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        searchBar.becomeFirstResponder()
    }

}

extension SearcherViewController {
    
    func setup() {
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: searchBar.safeAreaLayoutGuide.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SearcherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if searchResults.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier:
            TableView.CellIdentifiers.nothingFoundCell,
            for: indexPath) as! NothingFoundCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:
            TableView.CellIdentifiers.searcherResultCell,
            for: indexPath) as! SearcherResultCell
            
            let searchResult = searchResults[indexPath.row]
           
            cell.configure(with: SearchResult(name: "1", artistName: searchResult.artistName))
//            cell.nameLabel.text = searchResult.name
//            cell.artistNameLabel.text = searchResult.artistName
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
}

// MARK: - Searcher Bar Delegate
extension SearcherViewController: UISearchBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchResults = []
        if searchBar.text! != "Test" {
            for i in 0...2 {
                var searchResult = SearchResult()
                searchResult.name = String(format: "Fake Result %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        hasSearched = true
        tableView.reloadData()
        
    }
    
}
