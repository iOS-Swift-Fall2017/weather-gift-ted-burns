//
//  WeatherLocation.swift
//  WeatherGift
//
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var coordinates: String
    
    init(name: String, coordinates: String) {
        self.name = name
        self.coordinates = coordinates
    }
}
