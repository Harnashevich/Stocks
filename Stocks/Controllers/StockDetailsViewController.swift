//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Andrei Harnashevich on 20.03.24.
//

import UIKit

class StockDetailsViewController: UIViewController {
    
    // MARK: - Properties

    /// Stock symbol
    private let symbol: String

    /// Company name
    private let companyName: String

    /// Collection of data
    private var candleStickData: [CandleStick]

    /// Primary view
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self,
                       forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsStoryTableViewCell.self,
                       forCellReuseIdentifier: NewsStoryTableViewCell.identfier)
        return table
    }()

    /// Collection of news stories
    private var stories: [NewsStory] = []

    /// Company metrics
//    private var metrics: Metrics?
    
    // MARK: - Init

    init(
        symbol: String,
        companyName: String,
        candleStickData: [CandleStick] = []
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
}
 
