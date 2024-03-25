//
//  MarketDataResponse.swift
//  Stocks
//
//  Created by Andrei Harnashevich on 25.03.24.
//

import Foundation

/// Market data response
struct MarketDataResponse: Codable {
    let open: [Double]
    let close: [Double]
    let high: [Double]
    let low: [Double]
    let status: String
    let timestamps: [TimeInterval]

    enum CodingKeys: String, CodingKey {
        case open = "o"
        case low = "l"
        case close = "c"
        case high = "h"
        case status = "s"
        case timestamps = "t"
    }

    /// Convert market data to array of candle stick models
    var candleSticks: [CandleStick] {
        var result = [CandleStick]()

        for index in 0..<open.count {
            result.append(
                .init(
                    date: Date(timeIntervalSince1970: timestamps[index]),
                    high: high[index],
                    low: low[index],
                    open: open[index],
                    close: close[index]
                )
            )
        }

        let sortedData = result.sorted(by: { $0.date > $1.date })
        return sortedData
    }
}

/// Model to represent data for single day
struct CandleStick {
    let date: Date
    let high: Double
    let low: Double
    let open: Double
    let close: Double
}

