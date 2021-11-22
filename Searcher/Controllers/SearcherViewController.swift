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
    private var isLoading = false
    
    struct TableView {
        struct CellIdentifiers {
            static let searcherResultCell = "SearcherResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
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
        tv.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.identifier)
        
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
    
    // MARK: - Helper Methods
    func iTunesURL(searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
    func performStoreRequest(with url: URL) -> Data? {
        do {
            return try Data(contentsOf:url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }
    
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(
                ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message: "There was an error accessing the iTunes Store." +
            " Please try again.",
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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
        
        if isLoading {
            return 1
        } else if !hasSearched {
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
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.loadingCell,
                for: indexPath) as! LoadingCell
            
//            let spinner = cell.viewWithTag(99) as!
//            UIActivityIndicatorView
//             spinner.startAnimating()
            return cell
        } else if searchResults.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath) as! NothingFoundCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searcherResultCell, for: indexPath) as! SearcherResultCell
            
            let searchResult = searchResults[indexPath.row]
            
            cell.configure(with: SearchResult(artistName: searchResult.artistName, trackName: searchResult.trackName))
            //      cell.nameLabel.text = searchResult.name
            //      cell.artistNameLabel.text = searchResult.artistName
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if searchResults.count == 0 || isLoading {
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
        
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let queue = DispatchQueue.global()
            let url = self.iTunesURL(searchText: searchBar.text!)
            
            queue.async {
               if let data = self.performStoreRequest(with: url) {
                 self.searchResults = self.parse(data: data)
                 self.searchResults.sort(by: <)
                    
                 DispatchQueue.main.async {
                   self.isLoading = false
                   self.tableView.reloadData()
                 }

                 return
               }
            }
        }
        
        
    }
    
}
