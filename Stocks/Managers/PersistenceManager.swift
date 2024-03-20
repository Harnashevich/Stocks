//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Andrei Harnashevich on 20.03.24.
//

import Foundation

final class PersistenceManager {
    
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        
    }
    
    private init () {}
    
    // MARK: - Public
    
    public var watchlist: [String] {
        return []
    }
    
    public func addToWatchList() {
        
    }
    
    public func removeToWatchList() {
        
    }
    
    // MARK: - Private
    
    public var hasOnboarded: Bool {
        return false
    }
}
