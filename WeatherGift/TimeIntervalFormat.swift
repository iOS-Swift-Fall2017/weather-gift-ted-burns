//
//  TimeIntervalFormat.swift
//  WeatherGift
//
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import Foundation

extension TimeInterval {
    func format(timeZone: String, dateFormatter: DateFormatter) -> String {
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        return dateFormatter.string(from: Date(timeIntervalSince1970: self))
    }
}
