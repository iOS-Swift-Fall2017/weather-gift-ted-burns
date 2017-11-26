//
//  HourlyCell.swift
//  WeatherGift
//
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "ha"
    return dateFormatter
}()

class HourlyCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var raindropImage: UIImageView!
    @IBOutlet weak var precipPercentageLabel: UILabel!
    
    func update(with hourlyForecast: WeatherDetail.HourlyForecast, timeZone: String) {
        weatherIcon.image = UIImage(named: hourlyForecast.hourlyIcon)
        let time = hourlyForecast.hourlyTime.format(timeZone: timeZone, dateFormatter: dateFormatter)
        print(time)
        timeLabel.text = time
        temperatureLabel.text = String(format: "%2.f°", hourlyForecast.hourlyTemperature)
        let precipChance = hourlyForecast.hourlyPrecipProb * 100
        if precipChance > 30.0 {
            raindropImage.isHidden = false
            precipPercentageLabel.isHidden = false
            precipPercentageLabel.text = String(format: "%2.f", precipChance) + "%"
        } else {
            raindropImage.isHidden = true
            precipPercentageLabel.isHidden = true
        }
        
    }
}
