//
//  NewsStory.swift
//  Stocks
//
//  Created by Andrei Harnashevich on 22.03.24.
//

import Foundation

/// Represent news story
struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
