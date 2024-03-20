//
//  APICaller.swift
//  Stocks
//
//  Created by Andrei Harnashevich on 20.03.24.
//

import Foundation

final class APICaller {

    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = ""
        static let sanboxApiKey = ""
        static let baseUrl = ""
    }
    
    private init() {}
    
    // MARK: - Public
    
    // get stock info
    
    // search stocks
    
    // MARK: - Private
    
    private enum Endpoint: String {
        case search
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
    
    private func url(
        for endpoint: Endpoint,
        queryParams: [String: String] = [:]
    ) -> URL? {
        
        return nil
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
