//
//  NewsViewController.swift
//  Stocks
//
//  Created by Andrei Harnashevich on 20.03.24.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    /// Primary news view
    let tableView: UITableView = {
        let table = UITableView()
        // Register cell, header
        table.register(
            NewsStoryTableViewCell.self,
            forCellReuseIdentifier: NewsStoryTableViewCell.identfier
        )
        table.register(
            NewsHeaderView.self,
            forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier
        )
        table.backgroundColor = .clear
        return table
    }()
    
    /// Collection of news stories
    private var stories = [NewsStory]()
    
    /// Type of news
    enum `Type` {
        case topStories
        case compan(symbol: String)

        /// Title for given type
        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .compan(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: - Properties
    
    /// Instance of a type
    private let type: Type
    
    // MARK: - Init

    /// Create VC with type
    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        fetchNews()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private

    /// Sets up tableView
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// Fetch news models
    private func fetchNews() {
        APICaller.shared.news(for: type) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Open a story
    /// - Parameter url: URL to open
    private func open(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}


extension NewsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsStoryTableViewCell.identfier,
            for: indexPath
        ) as? NewsStoryTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
}

extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NewsHeaderView.identifier
        ) as? NewsHeaderView else {
            return nil
        }
        header.configure(with: .init(
            title: self.type.title,
            shouldShowAddButton: false
        ))
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        HapticsManager.shared.vibrateForSelection()

        // Open news story
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
        open(url: url)
    }
    
    /// Present an alert to show an error occurred when opening story
    private func presentFailedToOpenAlert() {
        HapticsManager.shared.vibrate(for: .error)

        let alert = UIAlertController(
            title: "Unable to Open",
            message: "We were unable to open the article.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
