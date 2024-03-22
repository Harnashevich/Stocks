//
//  APICaller.swift
//  Stocks
//
//  Created by Andrei Harnashevich on 20.03.24.
//

import Foundation

/// Object to manage api calls
final class APICaller {
    /// Singleton
    static let shared = APICaller()
    
    /// Constants
    private struct Constants {
        static let apiKey = "cnu0gn1r01qt3uhjpi0gcnu0gn1r01qt3uhjpi10"
        static let sanboxApiKey = ""
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    /// Private constructor
    private init() {}
    
    // MARK: - Public
    
    /// Search for a company
    /// - Parameters:
    ///   - query: Query string (symbol or name)
    ///   - completion: Callback for result
    public func search(
        query: String,
        completion: @escaping (Result<SearchResponse, Error>) -> Void
    ) {
        guard let safeQuery = query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) else {
            return
        }
        
        request(
            url: url(
                for: .search,
                queryParams: ["q": safeQuery]
            ),
            expecting: SearchResponse.self,
            completion: completion
        )
    }
    
    /// Get news for type
    /// - Parameters:
    ///   - type: Company or top stories
    ///   - completion: Result callback
    public func news(
        for type: NewsViewController.`Type`,
        completion: @escaping (Result<[NewsStory], Error>) -> Void
    ) {
        switch type {
        case .topStories:
            request(
                url: url(for: .topStories, queryParams: ["category": "general"]),
                expecting: [NewsStory].self,
                completion: completion
            )
        case .compan(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            request(
                url: url(
                    for: .companyNews,
                    queryParams: [
                        "symbol": symbol,
                        "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                        "to": DateFormatter.newsDateFormatter.string(from: today)
                    ]
                ),
                expecting: [NewsStory].self,
                completion: completion
            )
        }
    }
    
    // get stock info
    
    // search stocks
    
    // MARK: - Private
    
    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
    
    private func url(
        for endpoint: Endpoint,
        queryParams: [String: String] = [:]
    ) -> URL? {
        
        var urlString = Constants.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        // Add any parameters
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        // Add token
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        // Convert queri items to suffix string
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        
        print("\n\(urlString)\n")
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url else {
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data, error == nil else {
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            
            catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
