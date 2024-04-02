//
//  StocksTests.swift
//  StocksTests
//
//  Created by Andrei Harnashevich on 2.04.24.
//

@testable import Stocks

import XCTest

final class StocksTests: XCTestCase {

    func testSomeing() {
        let number = 1
        let string = "1"
        
        XCTAssertEqual(number, Int(string), "Number do not metch")
    }
    
    func testCandleStickDataConversion() {
        let doubles: [Double] = Array(repeating: 12.2, count: 10)
        var timestamps: [TimeInterval] = []
        
        for x in 0..<12 {
            let interval = Date().addingTimeInterval(3600 * TimeInterval(x)).timeIntervalSince1970
            timestamps.append(interval)
        }
        
        timestamps.shuffle()
        
        let marketData = MarketDataResponse(
            open: doubles,
            close: doubles,
            high: doubles,
            low: doubles,
            status: "success",
            timestamps: timestamps
        )
        
        let candleStick = marketData.candleSticks
        
        XCTAssertEqual(candleStick.count, marketData.open.count)
        XCTAssertEqual(candleStick.count, marketData.close.count)
        XCTAssertEqual(candleStick.count, marketData.high.count)
        XCTAssertEqual(candleStick.count, marketData.low.count)
        
        //Vefify sort
        let dates = candleStick.map { $0.date }
        for x in 0..<dates.count - 1 {
            let current = dates[x]
            let next = dates[x + 1]
            
            XCTAssertTrue(current >= next, "\(current) date should be greather then \(next) date")
        }
    }
}
