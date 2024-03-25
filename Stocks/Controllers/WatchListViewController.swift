//
//  WatchListViewController.swift
//  Stocks
//
//  Created by Andrei Harnashevich on 20.03.24.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    /// Timer to optimize searching
    private var searchTimer: Timer?
    
    /// Floating news panel
    private var panel: FloatingPanelController?
    
    /// Model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    private var viewModels: [String] = []
    
    /// Main view to render watch list
    private let tableView: UITableView = {
        let table = UITableView()
//        table.register(
//            WatchListTableViewCell.self,
//            forCellReuseIdentifier: WatchListTableViewCell.identifier
//        )
        return table
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTableView()
        fetchWatchListData()
        setUpTitleView()
        setUpFloatingPanel()
    }
    
    // MARK: - Private
    
    private func fetchWatchListData() {
        let symbols = PersistenceManager.shared.watchlist
        
        let group = DispatchGroup()
        
        
        for symbol in symbols {
            group.enter()
            
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                guard let self else { return }
                defer {
                    group.leave()
                }
                
                switch result {
                case  .success(let data):
                    print(data)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
        }
    }

    /// Sets up tableview
    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
    /// Sets up floating news panel
    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }

    private func setUpTitleView() {
        let titleView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: navigationController?.navigationBar.height ?? 100
            )
        )

        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width-20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        titleView.addSubview(label)

        navigationItem.titleView = titleView
    }
    
    /// Sets up tableview
    private func setUpTableView() {
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension WatchListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let query = searchController.searchBar.text,
            let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
            !query.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return
        }
        // Reset timer
        searchTimer?.invalidate()
        
        // Kick off new timer
        // Optimize to reduce number of searches for when user stops typing
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            // Call API to search
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    print(response)
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                    print(error)
                }
            }
        })
    }
}

// MARK: - SearchResultsViewControllerDelegate

extension WatchListViewController: SearchResultsViewControllerDelegate {
    /// Notify of search result selection
    /// - Parameter searchResult: Search result that was selected
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        HapticsManager.shared.vibrateForSelection()

        let vc = StockDetailsViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension WatchListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        watchlistMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension WatchListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: -FloatingPanelControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
    /// Gets floating panel state change
    /// - Parameter fpc: Ref of controller
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}
