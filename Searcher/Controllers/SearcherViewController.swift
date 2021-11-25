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
    private var dataTask: URLSessionDataTask?
    
    private var landscapeVC: LandscapeViewController?
    
    struct TableView {
        struct CellIdentifiers {
            static let searcherResultCell = "SearcherResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    // MARK: - UI
    
    private var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.placeholder = "Artist name, song or album..."
        
        return sb
    }()
    
    private var segmentedControl: UISegmentedControl = {
        let items = ["All", "Music", "Software", "Books"]
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        return sc
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = .systemBackground
        self.title = "Searcher"
        searchBar.becomeFirstResponder()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
      ) {
        super.willTransition(to: newCollection, with: coordinator)

        switch newCollection.verticalSizeClass {
        case .compact:
          showLandscape(with: coordinator)
        case .regular, .unspecified:
          hideLandscape(with: coordinator)
        @unknown default:
          break
        }
      }
    
    @objc func segmentChanged(_ segmentedControl: UISegmentedControl) {
        performSearch()
    }
    
    // MARK: - Helper Methods
    func iTunesURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category {
            case 1: kind = "musicTrack"
            case 2: kind = "software"
            case 3: kind = "ebook"
            default: kind = ""
        }
        let encodedText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?" +
              "term=\(encodedText)&limit=200&entity=\(kind)"
        let url = URL(string: urlString)
        return url!
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
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
       guard landscapeVC == nil else { return }
       landscapeVC = LandscapeViewController()
       if let controller = landscapeVC {
         controller.searchResults = searchResults
         controller.view.frame = view.bounds
         controller.view.alpha = 0
         view.addSubview(controller.view)
         addChild(controller)
         coordinator.animate(
           alongsideTransition: { _ in
             controller.view.alpha = 1
             self.searchBar.resignFirstResponder()
             if self.presentedViewController != nil {
               self.dismiss(animated: true, completion: nil)
             }
           }, completion: { _ in
             controller.didMove(toParent: self)
           })
       }
     }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
          controller.willMove(toParent: nil)
          coordinator.animate(
            alongsideTransition: { _ in
              controller.view.alpha = 0
            }, completion: { _ in
              controller.view.removeFromSuperview()
              controller.removeFromParent()
              self.landscapeVC = nil
            })
        }
      }
    
}

extension SearcherViewController {
    
    func setup() {
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            //            segmentedControl.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
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
            return cell
        } else if searchResults.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath) as! NothingFoundCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searcherResultCell, for: indexPath) as! SearcherResultCell
            
            let searchResult = searchResults[indexPath.row]
         
            cell.configure(for: searchResult)
           
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = DetailViewController()
        vc.modalPresentationStyle = .overFullScreen
       
        vc.searchResult = { [weak self] in
            self?.searchResults[indexPath.row]
        }()
        
//        navigationController?.pushViewController(vc, animated: true)
        present(vc, animated: true)
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
        performSearch()
    }
    
    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: url) {data, response,
                error in
                if let error = error as NSError?, error.code == -999 {
                    return  // Search was cancelled
                } else if let data = data {
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort(by: <)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                } else {
                    print("Failure! \(response!)")
                }
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            }
            dataTask.resume()
        }
        
        
    }
    
}
