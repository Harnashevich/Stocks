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
    
    /// Width to track change label geometry
    static var maxChangeWidth: CGFloat = 0
    
    /// Model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    /// Main view to render watch list
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(
            WatchListTableViewCell.self,
            forCellReuseIdentifier: WatchListTableViewCell.identifier
        )
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
    
    /// Layout subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private
    
    private func fetchWatchListData() {
        let symbols = PersistenceManager.shared.watchlist

//        createPlaceholderViewModels()

        let group = DispatchGroup()

        for symbol in symbols {
            group.enter()

            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }

                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    /// Creates view models from models
    private func createViewModels() {
       
        for (symbol, candleSticks) in watchlistMap {
//            let changePercentage = candleSticks.getPercentage()
            let changePercentage = Double.random(in: -1...1)
            
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: .percentage(from: changePercentage), 
                    chartViewModel: .init(
                        data: candleSticks.reversed().map { $0.close },
                        showLegend: false,
                        showAxis: false,
                        fillColor: changePercentage < 0 ? .systemRed : .systemGreen
                    )
                )
            )
        }
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
    }
    
    /// Gets latest closing price
    /// - Parameter data: Collection of data
    /// - Returns: String
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        return .formatted(number: closingPrice)
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
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: WatchListTableViewCell.identifier,
                for: indexPath
        ) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WatchListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
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

// MARK: - WatchListTableViewCellDelegate

extension WatchListViewController: WatchListTableViewCellDelegate {
    /// Notify delegate of change label width
    func didUpdateMaxWidth() {
        // Optimize: Only refresh rows prior to the current row that changes the max width
        tableView.reloadData()
    }
}
